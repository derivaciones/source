
viewer = {};
do ->
  mk_expression = 
    BINARY:  (expression)->
      root = mk_div ['binary'] 
      root.appendChild process_expression expression.left
      root.appendChild mk_span expression.connector.content, ['connector'] 
      root.appendChild process_expression expression.right
      root
    ELEMENT: (expression)->
      mk_span expression.identifier, ['element'] 
    NEGATE: (expression)->
      root = mk_div ['negate'] 
      root.appendChild mk_span expression.content, ['negation'] 
      root.appendChild process_expression expression.expression
      root
    CLOSE_EXP: (expression)->
      root = mk_div ['close-exp'] 
      root.appendChild mk_span '(', ['parenthesis', 'start'] 
      root.appendChild process_expression expression.expression
      root.appendChild mk_span ')', ['parenthesis', 'end'] 
      root
      
      
  mk = 
    PREMISE:   (node)->
      node.view = mk_div ['premise']
      node.view.appendChild process_expression node.expression
      node.view.appendChild mk_span 'premisa', ['premise-text'] 
    SUPPOSED:  (node)->
      node.view = mk_div ['supposed']
      node.view.appendChild process_expression node.expression
      node.view.appendChild mk_span 'supuesto', ['supposed-text'] 
    ASSERTION: (node)->
      node.view = mk_div ['assertion']
      node.view.appendChild process_expression node.expression
      mk_rule node.rule
      node.view.appendChild node.rule.view
    ITERATION: (node)->
      node.view = mk_div ['iteration']
      process_children node
    ERROR:     (node)->
      node.view = mk_div ['errors']
  
  mk_rule = (rule)->
    rule.view = mk_div ['rule']
    if rule.type is 'DOUBLE_NOT'
      rule.view.appendChild mk_span '¬¬', ['rule-type'] 
    else
      rule.view.appendChild mk_span rule.action, ['rule-type']
      rule.view.appendChild mk_span rule.connector.content, ['rule-connector']
    mk_ref rule
      
  mk_ref = (rule)->
    rule.view.appendChild mk_span '(', ['parenthesis', 'ref'] 
    if rule.references.type is 'ARRAY'
      references = rule.references.references
      console.log references
      for index in [0 ... references.length-1]
        console.log 'index' + index
        rule.view.appendChild mk_span references[index], ['reference-index']
        rule.view.appendChild mk_span ',', ['reference-reparator']
      rule.view.appendChild mk_span references[references.length-1], ['reference-index']
    else
       rule.view.appendChild mk_span rule.references.first, ['reference-index']
       rule.view.appendChild mk_span '-', ['reference-reparator']
       rule.view.appendChild mk_span rule.references.last, ['reference-index']
    rule.view.appendChild mk_span ')', ['parenthesis', 'ref'] 
      
  process_expression = (expression)->
    mk_expression[expression.type](expression)
      
  process_children = (parent)->
    for node in parent.children
      mk[node.type] node
      parent.view.appendChild node.view
      
  mk_index = (ast)->
    width_klass = 'index-container-' + ast.length.toString().length
    rules = mk_div ['index-container',width_klass]
    ast.root.view.appendChild rules
    for index in [1 .. ast.length]
      rules.appendChild mk_span index, ['index']  
    
  viewer.process = (ast)->
    ast.root.view = mk_div ['root']
    mk_index ast
    lines = mk_div ['lines']
    for node in ast.root.children
      mk[node.type] node
      lines.appendChild node.view
      add_classes(node.view, ['first-level'])
    ast.root.view.appendChild lines

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
  