load         = -> ''
save         = ->
inputChange  = ->
process      = ->
writeInput   = ->
inputMode    = ->

window.addLoadListener ->

  input        = document.querySelector('#input')
  process      = document.querySelector('#process')
  output       = document.querySelector('#output')

  writeInput = (text)->
    text = text or ''
    #IE support
    if document.selection
      input.focus()
      sel = document.selection.createRange()
      sel.text = text
    #MOZILLA and others
    else if (input.selectionStart or input.selectionStart is '0')
      startPos = input.selectionStart
      endPos = input.selectionEnd
      input.value = input.value.substring(0, startPos) + text + input.value.substring(endPos, input.value.length)
      input.selectionEnd = endPos + text.length
    else
      input.value += text
    inputChange()
    input.focus()

  MODE =
    INPUT:   'input-mode'
    OUTPUT:  'output-mode'
  MODE.CURRENT = MODE.INPUT
  ast = null

  swapMode = (state)->
    document.body.classList.remove MODE.CURRENT
    MODE.CURRENT = state
    document.body.classList.add MODE.CURRENT

  firstTime = ->
    window.location = 'first.html'
  fullView = ->
    document.body.classList.add('full')

  if typeof window.localStorage isnt 'undefined'
    storageKey  = 'derivation.code'
    save        = (code) -> localStorage.setItem storageKey, code
    load        = (code) -> localStorage.getItem storageKey
    inputChange =        -> save input.value
    visitKey    = 'derivation.visit'
    if not localStorage.getItem visitKey
      localStorage.setItem visitKey, true
      firstTime()
    fullKey     = 'derivation.full'
    if not localStorage.getItem fullKey
      listener = ()->
        document.removeEventListener("click", listener)
        localStorage.setItem fullKey, true
        fullView()
      document.addEventListener("click", listener);
    else
      fullView()
  else
    firstTime()

  input.value = load()

  previousActiveElement = null

  mousedownHandler = (evn)->
    previousActiveElement = document.activeElement
  process.addEventListener 'mousedown', mousedownHandler, false

  processHandler = (evn)->
    while output.firstChild
      output.removeChild output.firstChild
    parser = new derivaciones.Parser
    ast = validator.validate(input.value, parser)
    if ast
      console.log ast
      viewer.process(ast)
      output.appendChild ast.root.view
    previousActiveElement.focus()
    evn.preventDefault()
    swapMode(MODE.OUTPUT)

  process.addEventListener 'click', processHandler, false


  window.inputMode = ->
    swapMode(MODE.INPUT)

  window.outputMode = ->
    swapMode(MODE.OUTPUT)

  actions = [
    keyCode: 81 #q
    char: 'Λ'
  ,
    keyCode: 68 #d
    char: 'V'
  ,
    keyCode: 72 #h
    char: '∀'
  ,
    keyCode: 89 #y
    char: '∃'
  ,
    keyCode: 79 #o
    char: '→'
  ,
    keyCode: 74 #j
    char: '⊥'
  ,
    keyCode: 71 #g
    char: '¬'
  ]

  handleKey = (evnt)->
    unless evnt.ctrlKey then return true
    keyCode = evnt.keyCode
    for action in actions
      if action.keyCode is keyCode
        writeInput action.char
        evnt.preventDefault()
        evnt.stopPropagation()
        return true

  input.addEventListener 'keydown', handleKey, false
