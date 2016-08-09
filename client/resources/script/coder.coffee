
coder = {};
do ->
  indent = '  '
  mkstatement = 
    INVOCATION:  (invocation,level)->
      view = invocation.view = mk_div ['invocation']
      view.appendChild(mk_span(mkindent(level)))
      view.appendChild(mk_span('[',['bracket-start']))
      view.appendChild(mk_span(invocation.name,['name']))
      if args = invocation.args
        view.appendChild(mk_span(' {',['brace-start']))
        last = args.length - 1
        for arg, index in args
          view.appendChild(mk_span(arg.name,['arg-name']))
          view.appendChild(mk_span(':'))
          for arg_node in exp_nodes(arg.value)
            view.appendChild(arg_node)
          if index < last
            view.appendChild(mk_span(', '))
        view.appendChild(mk_span('}',['brace-end']))
      view.appendChild(mk_span(']',['bracket-end']))
      view
      
    CONDITIONAL: (conditional,level)->
      view = conditional.view = mk_div ['conditional']
      condition_row = mk_div ['condition-row']
      condition_row.appendChild mk_span(mkindent(level))
      condition_row.appendChild mk_span('Si',['conditional-if'])
      condition_row.appendChild mk_span('(',['semi-start'])
      if conditional.negate
        condition_row.appendChild mk_span('no ',['negation'])
      condition_row.appendChild mk_span(conditional.condition,['condition'])
      condition_row.appendChild mk_span(')',['semi-end'])
      condition_row.appendChild mk_span('Entonces',['conditional-then'])
      view.appendChild condition_row
      view.appendChild mk_block(conditional.positive, level)
      if conditional.negative
        view.appendChild mk_single('Sino', level, ['conditional-else'])
        view.appendChild mk_block(conditional.negative, level)
      view
      
    REPEAT: (repeat,level)->
      view = repeat.view = mk_div ['repeat']
      view.appendChild mk_single('(', level, ['repeat-start'])
      for statement in repeat.statements
        view.appendChild mkstatement[statement.TYPE](statement, level + 1)  
      end_row = mk_div ['end-row']
      end_row.appendChild mk_span(mkindent(level))
      end_row.appendChild mk_span(')',['repeat-end'])
      for exp_node in exp_nodes(repeat.index)
        end_row.appendChild(exp_node)
      view.appendChild end_row
      view
      
    ACTION: (action,level)->
      view = action.view = mk_div ['action']
      view.appendChild mk_single(action.name, level, ['action-name'])
      view
      
  exp_nodes = (value)->
    switch value.TYPE
      when 'IDENTIFIER' then [mk_span(value.name,['arg-identifier'])]
      when 'NUMERIC'    then [mk_span(value.value,['arg-number'])]
      when 'ADD'
        plus = mk_span(' + ',['arg-add'])
        exp_nodes(value.left).concat([plus]).concat(exp_nodes(value.right))
      when 'SUB'
        plus = mk_span(' - ',['arg-sub'])
        exp_nodes(value.left).concat([plus]).concat(exp_nodes(value.right))
      
  add_classes = (element, classes)->
    classes ?= []
    for klass in classes
      element.classList.add klass
    element
    
  mk_span = (text, classes)->
    view = document.createElement 'span'
    text = document.createTextNode text
    view.appendChild text
    add_classes view, classes
    
  mk_div = (classes)->
    add_classes (document.createElement 'div'), classes
      
  mk_pre = (classes)->
    add_classes (document.createElement 'pre'), classes
  
  mk_single = (text, level, classes)->
    single = mk_div(classes)
    single.appendChild mk_span(mkindent(level) + text)
    single
  
  mk_block = (statements, level)->
    block = mk_div(['block'])
    block.appendChild mk_single('Inicio', level, ['block-start'])
    for statement in statements
      block.appendChild mkstatement[statement.TYPE](statement, level + 1)      
    block.appendChild mk_single('Fin', level, ['block-end'])
    block
    
  mk_signature = (procedure)->
    procedure.view.params = []
    signature = mk_div(['signature'])
    signature.appendChild mk_span(mkindent(0) + procedure.name, ['name'])
    if params = procedure.params
      signature.appendChild(mk_span(' {',['brace-start']))
      last = params.length - 1
      for param, index in params
        param_text = mk_span(param,['param-name'])
        param_text.param_name = param
        procedure.view.params.push param_text
        signature.appendChild(param_text)
        if index < last
          signature.appendChild(mk_span(', '))
      signature.appendChild(mk_span('}',['brace-end']))
    signature.appendChild mk_span(':')
    signature
  
  fill_procedure = (procedure)->
    view = procedure.view = mk_div(['procedure'])   
    for comment in procedure.comments or []
      view.appendChild mk_single(comment, 0, ['comment'])
    view.appendChild mk_signature(procedure)
    view.appendChild mk_block(procedure.statements, 0)
      
  mkindent = (level)->
    level = if level > 0 then level else 0
    space  = ''
    while level--
      space += indent
    space
    
  coder.process = (ast)-> 
    main = mk_pre(['ast'])
    for procedure in ast
      fill_procedure procedure
      main.appendChild procedure.view
      main.appendChild mk_single(' ', 0)
    ast.view = main


