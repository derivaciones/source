load         = -> ''
save         = ->
inputChange  = ->
process      = ->
writeChar    = ->
inputMode    = ->
  
window.onload = ->
  
  input        = document.querySelector('#input')
  process      = document.querySelector('#process')
  output       = document.querySelector('#output')
  
  writeChar = (character)->
    focused = document.activeElement is input
    #IE support
    if document.selection
      input.focus()
      sel = document.selection.createRange()
      sel.text = character
    #MOZILLA and others
    else if (input.selectionStart or input.selectionStart is '0')
      startPos = input.selectionStart
      endPos = input.selectionEnd
      input.value = input.value.substring(0, startPos) + character + input.value.substring(endPos, input.value.length)
      input.selectionEnd = endPos + 1
    else 
      input.value += character
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
  
  if typeof window.localStorage isnt 'undefined'
    storage_key = 'derivation.code'
    save        = (code) -> localStorage.setItem storage_key, code
    load        = (code) -> localStorage.getItem storage_key
    inputChange =        -> save input.value
  
  input.value = load()
  
  previosActiveElement = null
  
  mousedownHandler = (evn)->
    previosActiveElement = document.activeElement  
  process.addEventListener 'mousedown', mousedownHandler, false  
  
  processHandler = (evn)->
    while output.firstChild
      output.removeChild output.firstChild
    parser = new derivaciones.Parser
    ast = validator.validate(input.value, parser)
    if ast
      viewer.process(ast)
      output.appendChild ast.root.view
    swapMode(MODE.OUTPUT)
    previosActiveElement.focus()
    evn.preventDefault()
    
  process.addEventListener 'click', processHandler, false  
  
  
  window.inputMode = -> 
    swapMode(MODE.INPUT)
    
  window.outputMode = -> 
    swapMode(MODE.OUTPUT)
    
  actions = [
    keyCode: 69 #e
    char: '→'
  ,
    keyCode: 82 #r
    char: '⊥'
  ,
    keyCode: 68 #d
    char: 'V'
  ,
    keyCode: 70 #f
    char: 'Λ'
  ]

  handleKey = (evnt)->
    unless evnt.ctrlKey then return true
    keyCode = evnt.keyCode
    for action in actions
      if action.keyCode is keyCode
        writeChar action.char
        evnt.preventDefault()
        evnt.stopPropagation()
        return true
      
  input.addEventListener 'keydown', handleKey, false  

