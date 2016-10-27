load       = -> ''
save       = ->
save_code  = ->
check_code = ->
fill_code  = ->
write_char = ->
  
window.onload = ->
  input = document.querySelector('#codeInput')
  output = document.querySelector('#codeOutput')
  pretty = document.querySelector('#codePreety')
  if typeof Storage isnt 'undefined'
    storage_key = 'elementos.code'
    save      = (code) -> localStorage.setItem storage_key, code
    load      = (code) -> localStorage.getItem storage_key
    save_code =        -> save input.value

  input.value = load()

  check_code = ->
    parser = new (elementos.Parser)
    try
      ast = parser.parse(input.value)
      parsed = JSON.stringify(ast, null, 2)
    catch evnt
      parsed = evnt.message
    output.value = parsed
    
  write_char = (character)->
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
    input.focus()
    
  fill_code = ->
    while pretty.firstChild
      pretty.removeChild pretty.firstChild
    parser = new (elementos.Parser)
    try
      ast = parser.parse(input.value)
      coder.process(ast)
      pretty.appendChild ast.view
    catch evnt
      pretty.innerHTML = evnt.message.replace /\n/g, '</br>'
    
