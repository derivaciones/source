
viewer = {};
do ->

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

  mk_paragraph = (text, classes)->
    view = document.createElement 'p'
    text = document.createTextNode text
    view.appendChild text
    add_classes view, classes

  mk_div = (classes)->
    add_classes (document.createElement 'div'), classes

  mk_img = (classes, src)->
    image = add_classes (document.createElement 'IMG'), classes
    image.src = src
    image

  mk_pre = (classes)->
    add_classes (document.createElement 'pre'), classes

  mk_single = (text, level, classes)->
    single = mk_div(classes)
    single.appendChild mk_span(mkindent(level) + text)
    single

  process_errors = (node, error)->
    if not node.ok
      if error
        node.view.appendChild mk_img ['state-error'], 'asset/error.png'
      else
        node.view.appendChild mk_img ['state-not-ok'], 'asset/warning.png'

  mk_expression =
    BINARY:  (expression)->
      root = mk_div ['binary']
      root.appendChild process_expression expression.left
      root.appendChild mk_span expression.connector.content, ['connector']
      root.appendChild process_expression expression.right
      root
    APPLICATION:  (expression)->
      root = mk_div ['application']
      root.appendChild mk_span expression.identifier, ['identifier']
      for element in expression.elements
        root.appendChild mk_span element.identifier, ['element']
      root
    FORALL:  (expression)->
      root = mk_div ['forall']
      root.appendChild mk_span '∀', ['identifier']
      root.appendChild mk_span expression.element.identifier, ['element']
      root.appendChild process_expression expression.expression
      root
    EXIST:  (expression)->
      root = mk_div ['exist']
      root.appendChild mk_span '∃', ['identifier']
      root.appendChild mk_span expression.element.identifier, ['element']
      root.appendChild process_expression expression.expression
      root
    ELEMENT: (expression)->
      mk_span expression.identifier, ['element']
    NEGATION: (expression)->
      root = mk_div ['negation']
      root.appendChild mk_span expression.content, ['negation-content']
      root.appendChild process_expression expression.expression
      root
    CLOSE_EXP: (expression)->
      root = mk_div ['close-exp']
      root.appendChild mk_span '(', ['parenthesis', 'start']
      root.appendChild process_expression expression.expression
      root.appendChild mk_span ')', ['parenthesis', 'end']
      root
    CONTRADICTION: (expression)->
      mk_span expression.content, ['contradiction']

  mk_ndex = (node, level)->
    container = mk_div ['index-left']
    container.appendChild mk_span node.index, ['index-left-text']
    for index in [0 .. level]
      fixer = mk_div ['index-left-level']
      fixer.appendChild container
      container = fixer
    node.view.appendChild container

  experimental_message = 'Esta caracteristica es experimental'+
    ' y aún no se pueden realizar validaciones sobre la misma'

  contains = (item, list)->
    list.indexOf(item) isnt -1

  experimental  = (node)->
    if contains( node.expression.type, ['FORALL', 'EXIST', 'APPLICATION'] )
      container = mk_span '', ['experimental']
      icon = mk_span '', ['experimental-icon']
      icon.appendChild mk_span '', ['fa', 'fa-exclamation-triangle']
      container.appendChild icon
      container.appendChild mk_span experimental_message, []
      node.view.appendChild container

  mk =
    COMMENT:   (node, error, level)->
      node.view = mk_div ['comment']
      node.view.appendChild mk_span node.content, ['comment-text']
      node
    CLOSE_ITERATION_ERROR: (node, error, level)->
      node.view = mk_div ['iteration-close']
      node.view.appendChild mk_span '<<', ['iteration-close-text']
      process_errors node, true
    PREMISE:   (node, error, level)->
      node.view = mk_div ['premise']
      node.view.appendChild process_expression node.expression
      node.view.appendChild mk_span 'premisa', ['premise-text']
      experimental node
      mk_ndex node, level
      process_errors node, error
    SUPPOSED:  (node, error, level)->
      node.view = mk_div ['supposed']
      node.view.appendChild process_expression node.expression
      node.view.appendChild mk_span 'supuesto', ['supposed-text']
      mk_ndex node, level
      experimental node
      process_errors node, error
    ASSERTION: (node, error, level)->
      node.view = mk_div ['assertion']
      node.view.appendChild process_expression node.expression
      mk_rule node.rule
      node.view.appendChild node.rule.view
      mk_ndex node, level
      experimental node
      process_errors node, error
    ITERATION: (node, error, level)->
      node.view = mk_div ['iteration']
      process_children node, error, level+1
    ERROR:     (node, error, level)->
      if(node.name == 'FINALIZACION_DENTRO_DE_ITERACION')
        node.view = mk_div ['error-wrapper']
        node.view.appendChild mk_img ['state-error-left'], 'asset/error.png'
        container = mk_div ['errors']
        node.view.appendChild container
      else
        node.view = mk_div ['errors']
        container = node.view
      for error in node.content.split('\n')
        error_view = mk_div ['error']
        container.appendChild error_view
        error_view.appendChild mk_paragraph error, ['error-text']

  mk_rule = (rule)->
    rule.view = mk_div ['rule']
    if rule.action is 'DOUBLE_NOT'
      rule.view.appendChild mk_span '¬¬', ['rule-type']
    else if rule.action is 'EFSQ'
      rule.view.appendChild mk_span 'EFSQ', ['rule-type']
    else if rule.action is 'REPEAT'
      rule.view.appendChild mk_span 'R', ['rule-type']
    else
      rule.view.appendChild mk_span rule.action, ['rule-type']
      rule.view.appendChild mk_span rule.connector.content, ['rule-connector']
    mk_ref rule

  mk_ref = (rule)->
    rule.view.appendChild mk_span '(', ['parenthesis', 'ref']
    if rule.references.type is 'ARRAY'
      indices = rule.references.indices
      for index in [0 ... indices.length-1]
        rule.view.appendChild mk_span indices[index], ['reference-index']
        rule.view.appendChild mk_span ',', ['reference-reparator']
      rule.view.appendChild mk_span indices[indices.length-1], ['reference-index']
    else
       rule.view.appendChild mk_span rule.references.first, ['reference-index']
       rule.view.appendChild mk_span '-', ['reference-reparator']
       rule.view.appendChild mk_span rule.references.last, ['reference-index']
    rule.view.appendChild mk_span ')', ['parenthesis', 'ref']

  process_expression = (expression)->
    mk_expression[expression.type](expression)

  process_children = (parent, error, level)->
    for node in parent.children
      mk[node.type] node, error, level
      parent.view.appendChild node.view

  # mk_index = (ast)->
  #   width_klass = 'index-container-' + ast.length.toString().length
  #   rules = mk_div ['index-container',width_klass]
  #   ast.root.view.appendChild rules
  #   for elem in ast.indices
  #     rules.appendChild mk_span (elem.index || '.'), ['index', elem.klass]


  viewer.process = (ast)->
    ast.root.view = mk_div ['root']
    # mk_index ast
    lines = mk_div ['lines']
    for node in ast.root.children
      mk[node.type] node, ast.error, 0
      lines.appendChild node.view
      add_classes(node.view, ['first-level'])
    ast.root.view.appendChild lines
