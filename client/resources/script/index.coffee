load       = -> ''
save       = ->
save_code  = ->
fill_code  = ->
write_char = ->
  
window.onload = ->
  
  input    = document.querySelector('#codeInput')
  output   = document.querySelector('#codeOutput')
  pretty   = document.querySelector('#codePreety')
  iterator = document.querySelector('#iterator')
  board_width    = iterator.querySelector('#boardWidth')
  board_height   = iterator.querySelector('#boardHeight')
  boardContainer = document.querySelector('#boardContainer')
  error_text     = document.querySelector('#error')
  execcode       = document.querySelector('#execCode')
  action_text    = execcode.querySelector('#action')
  timeout_text   = execcode.querySelector('#timeout')
  
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
    save_code()
    input.focus()
    
  
  allow_execute_change = ->
    if scope.allow_execute 
      action_text.innerHTML = 'Ejecutar'
    else
      action_text.innerHTML = 'Restante: '
  time_left_change = ->
    if scope.time_left > 0 
      timeout_text.innerHTML = scope.time_left
    else
      timeout_text.innerHTML = ''
  processing_change = ->
    PROCESSING = 'processing'
    if scope.processing
      iterator.classList.add PROCESSING
    else
      iterator.classList.remove PROCESSING
  show_processing_change = ->
    SHOW_PROCESSING = 'show-processing'
    if scope.show_processing
      iterator.classList.add SHOW_PROCESSING
    else
      iterator.classList.remove SHOW_PROCESSING
  stopped_change = ->
    STOPPED = 'stopped'
    if scope.stopped
      iterator.classList.add STOPPED
    else
      iterator.classList.remove STOPPED
  error_change = ->
    ERROR = 'error'
    if scope.error
      iterator.classList.add ERROR
    else
      iterator.classList.remove ERROR
    
  scope = {}
  
  second_pass = ->
    scope.time_left -= 1
    unless scope.allow_execute 
      countdown()
    
  countdown = ->
    window.setTimeout second_pass , 1000
  
  reset_count_down = ->
    scope.reset_time_left()
    countdown()
  
  do ->
    processing = null
    Object.defineProperty scope, 'processing',
      get:()->
        processing
      set:(next)->
        if next isnt processing
          processing = next
          processing_change()
    show_processing = null
    Object.defineProperty scope, 'show_processing',
      get:()->
        show_processing
      set:(next)->
        if next isnt show_processing
          show_processing = next
          show_processing_change()
    stopped = null
    Object.defineProperty scope, 'stopped',
      get:()->
        stopped
      set:(next)->
        if next isnt stopped
          stopped = next
          stopped_change()
    has_error = null
    Object.defineProperty scope, 'error',
      get:()->
        has_error
      set:(next)->
        if next isnt has_error
          has_error = next
          error_change()
    WAIT_TIME = 1
    time_left = WAIT_TIME
    allow_execute = false
    Object.defineProperty scope, 'time_left',
      get:()->
        time_left
      set:(next)->
        time_left = next
        time_left_change()
        if time_left > 0 and allow_execute
          allow_execute = false
          allow_execute_change()
        if time_left is 0 and not allow_execute
          allow_execute = true
          allow_execute_change()
    Object.defineProperty scope, 'allow_execute',
      get:()->
        allow_execute 
      set:(next)->
        throw new Error('cannot set allow_execute property')
    scope.reset_time_left = ->
      scope.time_left = WAIT_TIME

  MODE =
    INPUT:   'input-mode'
    PRETTY:  'pretty-mode'
    ITERATE: 'iterate-mode'
  MODE.CURRENT = MODE.INPUT
  ast = null
  
  swap_state = (state)->
    document.body.classList.remove MODE.CURRENT
    MODE.CURRENT = state
    document.body.classList.add state

  vh_support = ->
    testvh = document.createElement 'div'
    vh_val = '10vh'
    unexpected = '1px'
    testvh.style.height = unexpected
    testvh.style.height = vh_val
    document.body.appendChild testvh
    actual = window.getComputedStyle(testvh).height
    support = actual isnt unexpected
    document.body.removeChild testvh
    support

  fix_body_css = ->
    if not vh_support()
      document.body.classList.add 'force-vh-support'

  if typeof Storage isnt 'undefined'
    storage_key = 'elementos.code'
    save      = (code) -> localStorage.setItem storage_key, code
    load      = (code) -> localStorage.getItem storage_key
    save_code =        -> save input.value
  
  input.value = load()

  fix_body_css()

  fill_code = ->
    console.log 'parsing'
    while pretty.firstChild
      pretty.removeChild pretty.firstChild
    parser = new elementos.Parser
    ast = validator.validate(input.value, parser)
    if ast
      viewer.process(ast)
      pretty.appendChild ast.root.view
    swap_state(MODE.PRETTY)
    
  boardContainer.appendChild environment.view
  
  show_error = (error)->
    error_text.innerHTML = error
    scope.error = true
    scope.stopped = true
  
  window.exec_code = ()->
    if ast and scope.allow_execute
      scope.error = false
      scope.stopped = false
      swap_state(MODE.ITERATE)
      try
        interpreter.load ast, environment
      catch evnt
        show_error evnt
      reset_count_down()
    document.activeElement.blur();
  
  asynk = (callback)->
    window.setTimeout callback, 1
  
  synk = (callback)->
    callback()
      
  window.step = ->
    document.activeElement.blur();
    local_step()
    
  local_step = ->
    unless scope.processing or scope.error or (MODE.CURRENT isnt MODE.ITERATE)
      scope.processing = true
      asynk ->
        interpreter.step()
          .success (end)->
             scope.processing = false
             if end then scope.stopped = true
          .error (error)->
            scope.processing = false
            show_error error
          
  makeloop = ->
    on_error = (error)->
     scope.processing = false
     show_error error
    on_success = (end)->
     if end 
       scope.processing = false
       scope.stopped = true
     else
       asynk -> interpreter.step().success(on_success).error(on_error)
    asynk -> interpreter.step().success(on_success).error(on_error)
    
  makeloop_synk = ->
    stack_safe_counter = 0
    on_error = (error)->
     scope.processing = false
     scope.show_processing = false
     show_error error
    on_success = (end)->
     stack_safe_counter += 1
     caller_next = synk
     if stack_safe_counter > 5000
       stack_safe_counter = 0
       caller_next = asynk
     caller_next ->  
       if end 
         scope.processing = false
         scope.show_processing = false
         scope.stopped = true
       else
         interpreter.step().success(on_success).error(on_error)
    interpreter.step().success(on_success).error(on_error)
           
  window.run = ->
    document.activeElement.blur();
    unless scope.processing or scope.error
      scope.processing = true
      makeloop()
  
  window.run_all = ->
    document.activeElement.blur();
    unless scope.processing or scope.error
      scope.processing = true
      scope.show_processing = true
      asynk makeloop_synk
      
  window.reset = ->
    document.activeElement.blur();
    unless scope.processing or (MODE.CURRENT isnt MODE.ITERATE)
      scope.processing = true
      scope.stopped = false
      scope.error = false
      interpreter.deactivate()
      interpreter.load ast, environment
      scope.processing = false
      
  window.resize = ->
    document.activeElement.blur();
    w_val = board_width.value
    h_val = board_height.value
    w = if w_val and w_val > 0 then w_val else 1
    h = if h_val and h_val > 0 then h_val else 1
    environment.resize(w, h)
    
  window.input_mode = -> 
    interpreter.deactivate()
    swap_state(MODE.INPUT)
    
  window.pretty_mode = -> 
    if MODE.CURRENT is MODE.ITERATE 
      interpreter.deactivate()
      swap_state(MODE.PRETTY)

  handle_key = (evnt)->
    keyCode = evnt.keyCode;
    if keyCode is 13
      local_step()
    if keyCode is 37
      environment.left()
    if keyCode is 39
      environment.right()
    if keyCode is 38
      environment.up()
    if keyCode is 40
      environment.down()
    
  document.addEventListener 'keydown', handle_key, false
  
  reset_count_down()
  
  window.resize()

