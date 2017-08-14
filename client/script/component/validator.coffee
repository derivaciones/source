validator = {}

do ->

  interpolates = (errorElement, context)->
    content = errorElement.content
    for prop of context
      regExp = new RegExp('\\$(\s)*\\{' + prop + '\\}', 'g')
      content = content.replace(regExp, context[prop])
    type: errorElement.type
    content: content

  CLOSE_ITERATION_ERROR =
    type: 'CLOSE_ITERATION_ERROR'

  error =
    reference_later: (ast)->
      ast.error = true
      ast.current.children.push ERROR_ELEMENT.REFERENCIA_A_LINEA_POSTERIOR
    conjunction_unique_reference: (ast)->
      ast.error = true
      ast.current.children.push ERROR_ELEMENT.REFERENCIA_MULTIPLE_ELIMINACION_CONJUNCION
    conjunction_elimination: (ast, expression)->
      ast.error = true
      context =
        expression: print(expression)
      error_node = interpolates ERROR_ELEMENT.ELIMINACION_CONJUNCION_REFERENCIA_INVALIDA, context
      ast.current.children.push error_node
    conjunction_connector:(ast)->
      ast.error = true
      ast.current.children.push ERROR_ELEMENT.INTRODUCCION_CONJUNCION_CONECTOR_INCORRECTO
    invalid_iteration_reference:(ast, first, last)->
      ast.error = true
      context =
        firstReferenceIndex: first
        lastReferenceIndex: last
      error_node = interpolates ERROR_ELEMENT.ITERACION_REFERENCIA_INVALIDA, context
      ast.current.children.push error_node
    conjunction_introduction_references: (ast, left, right)->
      ast.error = true
      context =
        leftExpression: print(left)
        rightExpression: print(right)
      error_node = interpolates ERROR_ELEMENT.INTRODUCCION_CONJUNCION_REFERENCIA_INVALIDA, context
      ast.current.children.push error_node
    disjunction_connector: (ast)->
      ast.error = true
      ast.current.children.push ERROR_ELEMENT.INTRODUCCION_DISYUNCION_CONECTOR_INCORRECTO
    disjunction_introduction: (ast, left, right)->
      ast.error = true
      context =
        leftExpression: print(left)
        rightExpression: print(right)
      error_node = interpolates ERROR_ELEMENT.INTRODUCCION_DISYUNCION_REFERENCIA_INVALIDA, context
      ast.current.children.push error_node
    disjunction_introduction_references_aridity:(ast, parsed)->
      ast.error = true
      ast.current.children.push ERROR_ELEMENT.INTRODUCCION_DISYUNCION_REFERENCIA_EXTRA
    conjunction_introduction_references_aridity:(ast, parsed)->
      ast.error = true
      ast.current.children.push ERROR_ELEMENT.INTRODUCCION_CONJUNTION_REFERENCIA_EXTRA
    conditional_connector: (ast)->
      ast.error = true
      ast.current.children.push ERROR_ELEMENT.INTRODUCCION_CONDICIONAL_CONECTOR_INCORRECTO
    conditional_iteration_lack: (ast)->
      ast.error = true
      ast.current.children.push ERROR_ELEMENT.INTRODUCCION_CONDICIONAL_FALTA_ITERACION
    conditional_introduction: (ast, left, right)->
      ast.error = true
      context =
        leftExpression: print(left)
        rightExpression: print(right)
      error_node = interpolates ERROR_ELEMENT.INTRODUCCION_CONDICIONAL_ITERACION_INVALIDA, context
      ast.current.children.push error_node
    negation_type: (ast)->
      ast.error = true
      ast.current.children.push ERROR_ELEMENT.INTRODUCCION_NEGACION_FALTA_NAGACION
    negation_iteration_lack: (ast)->
      ast.error = true
      ast.current.children.push ERROR_ELEMENT.INTRODUCCION_NEGACION_FALTA_ITERACION
    negation_introduction: (ast, expression)->
      ast.error = true
      context = expresionNegada: print(expression)
      error_node = interpolates ERROR_ELEMENT.INTRODUCCION_NEGACION_ITERACION_INVALIDA, context
      ast.current.children.push error_node
    negation_isnt_contradiction: (ast)->
      ast.error = true
      ast.current.children.push ERROR_ELEMENT.ELIMINACION_NEGACION_NO_CONTRADICCION
    negation_elimination_references: (ast)->
      ast.error = true
      ast.current.children.push ERROR_ELEMENT.ELIMINACION_NEGACION_REFERENCIAS_INVALIDAS
    conditional_elimination_references: (ast)->
      ast.error = true
      ast.current.children.push ERROR_ELEMENT.ELIMINACION_CONDICIONAL_REFERENCIAS_INVALIDAS
    disjunction_elimination_references: (ast)->
      ast.error = true
      ast.current.children.push ERROR_ELEMENT.ELIMINACION_DISYUNCION_REFERENCIAS_INVALIDAS
    disjunction_elimination_unique_conditional: (ast, expression, conditional, disjunction)->
      ast.error = true
      context =
        conditional: print(conditional)
        disjunction: print(disjunction)
        expression:  print(expression)
      error_node = interpolates ERROR_ELEMENT.ELIMINACION_DISYUNCION_CONDICIONAL_UNICO, context
      ast.current.children.push error_node
    double_negation_unique_reference:(ast)->
      ast.error = true
      ast.current.children.push ERROR_ELEMENT.DOBLE_NEGACION_REFERENCIAS_MULTIPLES
    double_negation_references_type: (ast)->
      ast.error = true
      ast.current.children.push ERROR_ELEMENT.DOBLE_NEGACION_TIPO_REFERENCIAS_INVALIDAS
    double_negation_equal: (ast, first_ref, second_nested)->
      ast.error = true
      context =
        dobleNegacionReferida: print first_ref
        referenciaDespejado: print second_nested
      error_node = interpolates ERROR_ELEMENT.DOBLE_NEGACION_RESULTADO_INVALIDO, context
      ast.current.children.push error_node

    repeat_unique_reference:(ast)->
      ast.error = true
      ast.current.children.push ERROR_ELEMENT.REPETICION_REFERENCIAS_MULTIPLES
    repeat_reference:(ast)->
      ast.error = true
      ast.current.children.push ERROR_ELEMENT.REPETICION_REFERENCIAS_INVALIDAS
    efsq_unique_reference:(ast)->
      ast.error = true
      ast.current.children.push ERROR_ELEMENT.EFSQ_REFERENCIAS_MULTIPLES
    efsq_reference:(ast)->
      ast.error = true
      ast.current.children.push ERROR_ELEMENT.EFSQ_REFERENCIAS_INVALIDAS
    unexpected_close_iteration:(ast)->
      ast.error = true
      ast.current.children.push CLOSE_ITERATION_ERROR
      ast.current.children.push ERROR_ELEMENT.CIERRE_ITERACION_SIN_SUPUESTO
    unique_element_iteration:(ast, suposed)->
      ast.error = true
      ast.current.children.push CLOSE_ITERATION_ERROR
      context =
        suposed: print suposed
      error_node = interpolates ERROR_ELEMENT.CIERRE_ITERACION_ELEMENTO_UNICO, context
      ast.current.children.push error_node
    unexpected_after_iteration:(ast, parsed)->
      ast.error = true
      ast.current.children.push parsed
      ast.current.children.push ERROR_ELEMENT.FORMULA_INVALIDA_LUEGO_DE_ITERACION

  BINARY        = 'BINARY'
  ASSERTION     = 'ASSERTION'
  ITERATION     = 'ITERATION'
  DISJUNCTION   = 'DISJUNCTION'
  CONJUNCTION   = 'CONJUNCTION'
  CONDITIONAL   = 'CONDITIONAL'
  NEGATION      = 'NEGATION'
  CONTRADICTION = 'CONTRADICTION'
  REF =
    RANGE: 'RANGE'
    ARRAY: 'ARRAY'

  get_node = (parent, index)->
    for node in parent.children
      if node.type is ITERATION
        candidate = get_node(node, index)
        if candidate then return candidate
      else if node.index is index
        return node

  exist = (elem, previous)->
    for parsed in previous
      if equals elem, parsed.expression then return true
    return false

  get_refs =
    RANGE: (ast, references, max)->
      if max <= references.first or max <= references.last
        return error.reference_later ast
      result = []
      for index in [references.first .. references.last]
        #all references must exist
        result.push get_node ast.root, index
      return result

    ARRAY: (ast, references, max)->
      result = []
      for index in references.indices
        if max <= index
          return error.reference_later ast
        result.push get_node ast.root, index
      return result

  match_references = (first, last, ref)->
    if ref.type is REF.RANGE
      first is ref.first and last is ref.last or
      first is ref.last and last is ref.first
    else
      if ref.indices.length isnt (last-first + 1) then return false
      for expected in [first .. last]
        if ref.indices.indexOf(expected) is -1
          return false
      true

  exp_string =
    BINARY:  (expression)->
      print(expression.left)+' '+expression.connector.content+' '+print(expression.right)
    ELEMENT: (expression)->
      expression.identifier
    NEGATION: (expression)->
      expression.content + print(expression.expression)
    CLOSE_EXP: (expression)->
      '(' + print(expression.expression) + ')'
    CONTRADICTION: (expression)->
      expression.content

  print = (expression)->
    exp_string[expression.type](expression)

  extract = (expression)->
    if expression.type is 'CLOSE_EXP'
      extract expression.expression
    else
      expression

  equals = (first, second)->
    clean_first = extract first
    clean_second = extract second
    clean_first.type is clean_second.type and
    compare[clean_first.type](clean_first, clean_second)

  compare =
    BINARY: (first, second)->
      first.connector.type is second.connector.type and
      compare[first.connector.type](first, second)
    CONJUNCTION: (first, second)->
      equals(first.left, second.left) and equals(first.right, second.right) or
      equals(first.right, second.left) and equals(first.left, second.right)
    DISJUNCTION: (first, second)->
      equals(first.left, second.left) and equals(first.right, second.right) or
      equals(first.right, second.left) and equals(first.left, second.right)
    CONDITIONAL: (first, second)->
      equals(first.left, second.left) and equals(first.right, second.right)
    BICONDITIONAL: (first, second)->
      equals(first.left, second.left) and equals(first.right, second.right)
    NEGATION: (first, second)->
      equals(first.expression, second.expression)
    ELEMENT: (first, second)->
      first.identifier is second.identifier
    CONTRADICTION: (first, second)-> true

  elimination =
    CONJUNCTION: (ast, parsed)->
      expression = extract(parsed.expression)
      references = parsed.rule.references
      previous = get_refs[references.type](ast, references, parsed.index)
      if ast.error then return
      if previous.length isnt 1
        return error.conjunction_unique_reference ast
      unique_ref = previous[0]
      unique_exp = unique_ref.expression
      if not unique_exp.connector or unique_exp.connector.type isnt CONJUNCTION or
      not (equals(expression, unique_exp.left) or equals(expression, unique_exp.right))
        return error.conjunction_elimination ast, expression
      parsed.ok = true

    DISJUNCTION: (ast, parsed)->
      classify = (elements, ast)->
        classified = conditionals:[]
        for element in elements
          expression = extract(element.expression)
          if expression.type is BINARY
            if expression.connector.type is DISJUNCTION
              unless classified.disjunction
                classified.disjunction = expression
                continue
            if expression.connector.type is CONDITIONAL
              classified.conditionals.push expression
              continue
          return error.disjunction_elimination_references ast
        classified
      expression = extract(parsed.expression)
      references = parsed.rule.references
      previous = get_refs[references.type](ast, references, parsed.index)
      if ast.error then return
      classified = classify previous, ast
      if ast.error then return
      if not classified.disjunction
        return error.disjunction_elimination_references ast
      conditionals = classified.conditionals
      if conditionals.length < 1 or conditionals.length > 2
        return error.disjunction_elimination_references ast
      first_cond = conditionals[0]
      v_left = classified.disjunction.left
      v_right = classified.disjunction.right
      match_antedecent = (left, right, first, second)->
        equals(left, first.left) and equals(right, second.left)
      if conditionals.length is 1
        #case: pVp,p→s,s
        if match_antedecent(v_left, v_right, first_cond, first_cond) and
        equals(expression, first_cond.right)
          conditional = first_cond
          disjunction = classified.disjunction
          return error.disjunction_elimination_unique_conditional \
            ast, expression, conditional, disjunction
        else
          return error.disjunction_elimination_references ast
      else #conditionals.length is 2
        #case: pVq,p→s,q→s,s
        second_cond = conditionals[1]
        dynamic_match_antedecent = (left, right, first, second)->
          match_antedecent(left, right, first, second) or
          match_antedecent(left, right, second, first)
        if dynamic_match_antedecent(v_left, v_right, first_cond, second_cond) and
        equals(first_cond.right, expression) and equals(second_cond.right, expression)
          parsed.ok = true
        else
          return error.disjunction_elimination_references ast

    CONDITIONAL: (ast, parsed)->
      expression = extract(parsed.expression)
      references = parsed.rule.references
      previous = get_refs[references.type](ast, references, parsed.index)
      if ast.error then return
      if previous.length isnt 2
        return error.conditional_elimination_references ast
      first  = previous[0].expression
      second = previous[1].expression
      if (first.type is BINARY and first.connector.type is CONDITIONAL and
      equals(first.left, second) and equals(first.right, expression)) or
      (second.type is BINARY and second.connector.type is CONDITIONAL and
      equals(second.left, first) and equals(second.right, expression))
        parsed.ok = true
      else
        return error.conditional_elimination_references ast

    NEGATION: (ast, parsed)->
      expression = extract(parsed.expression)
      if expression.type isnt CONTRADICTION
        return error.negation_isnt_contradiction ast
      references = parsed.rule.references
      previous = get_refs[references.type](ast, references, parsed.index)
      if ast.error then return
      if previous.length isnt 2
        return error.negation_elimination_references ast
      first  = previous[0].expression
      second = previous[1].expression
      if (first.type is NEGATION and equals(first.expression, second)) or
      (second.type is NEGATION and equals(second.expression, first))
        parsed.ok = true
      else
        return error.negation_elimination_references ast

  introduction =
    CONJUNCTION: (ast, parsed)->
      expression = extract(parsed.expression)
      if not expression.connector or expression.connector.type isnt CONJUNCTION
        return error.conjunction_connector ast
      references = parsed.rule.references
      previous = get_refs[references.type](ast, references, parsed.index)
      if ast.error then return
      if exist(expression.left, previous) and exist(expression.right, previous)
        if previous.length isnt 2 or ( previous[0] is previous[1])
          return error.conjunction_introduction_references_aridity ast, parsed
        parsed.ok = true
      else
        error.conjunction_introduction_references ast, expression.left, expression.right

    DISJUNCTION: (ast, parsed)->
      expression = extract(parsed.expression)
      if not expression.connector or expression.connector.type isnt DISJUNCTION
        return error.disjunction_connector ast
      references = parsed.rule.references
      previous = get_refs[references.type](ast, references, parsed.index)
      if ast.error then return
      if exist(expression.left, previous) or exist(expression.right, previous)
        if previous.length isnt 1
          return error.disjunction_introduction_references_aridity ast, parsed
        parsed.ok = true
      else
        error.disjunction_introduction ast, expression.left, expression.right

    CONDITIONAL:  (ast, parsed)->
      expression = extract(parsed.expression)
      if not expression.connector or expression.connector.type isnt CONDITIONAL
        return error.conditional_connector ast
      if not parsed.iteration
        return error.conditional_iteration_lack ast
      previous = parsed.iteration.children
      first = previous[0]
      last = previous[previous.length-1]
      if not match_references(first.index, last.index, parsed.rule.references)
        return error.invalid_iteration_reference ast, first.index, last.index
      first_exp = first.expression
      last_exp = last.expression
      if not equals(first_exp, expression.left) or not equals(last_exp, expression.right)
        return error.conditional_introduction ast, expression.left, expression.right
      parsed.ok = true

    NEGATION: (ast, parsed)->
      expression = extract(parsed.expression)
      if expression.type isnt NEGATION
        return error.negation_type ast
      if not parsed.iteration
        return error.negation_iteration_lack ast
      previous = parsed.iteration.children
      first = previous[0]
      last = previous[previous.length-1]
      if not match_references(first.index, last.index, parsed.rule.references)
        return error.invalid_iteration_reference ast, first.index, last.index
      first_exp = first.expression
      last_exp = last.expression
      if not equals(first_exp, expression.expression) or last_exp.type isnt CONTRADICTION
        return error.negation_introduction ast, expression.expression
      parsed.ok = true

  assertion =
    DOUBLE_NOT: (ast, parsed)->
      expression = extract(parsed.expression)
      references = parsed.rule.references
      previous = get_refs[references.type](ast, references, parsed.index)
      if ast.error then return
      if previous.length isnt 1
        return error.double_negation_unique_reference ast
      unique_ref = extract(previous[0].expression)
      if unique_ref.type isnt NEGATION
        return error.double_negation_references_type ast
      first_nested = extract(unique_ref.expression)
      if first_nested.type isnt NEGATION
        return error.double_negation_references_type ast
      second_nested = extract(first_nested.expression)
      if not equals(second_nested, expression)
        return error.double_negation_equal ast, unique_ref, second_nested
      parsed.ok = true

    EFSQ: (ast, parsed)->
      expression = extract(parsed.expression)
      references = parsed.rule.references
      previous = get_refs[references.type](ast, references, parsed.index)
      if ast.error then return
      if previous.length isnt 1
        return error.efsq_unique_reference ast
      unique_ref = extract(previous[0].expression)
      if unique_ref.type isnt CONTRADICTION
        return error.efsq_reference ast
      parsed.ok = true

    REPEAT: (ast, parsed)->
      expression = extract(parsed.expression)
      references = parsed.rule.references
      previous = get_refs[references.type](ast, references, parsed.index)
      if ast.error then return
      if previous.length isnt 1
        return error.repeat_unique_reference ast
      unique_ref = extract(previous[0].expression)
      if not equals(unique_ref, expression)
        return error.repeat_reference ast
      parsed.ok = true

    E: (ast, parsed)->
      elimination[parsed.rule.connector.type](ast, parsed)
    I: (ast, parsed)->
      introduction[parsed.rule.connector.type](ast, parsed)

  processors =
    PREMISE:
      process: (ast, parsed)->
        ast.current.children.push parsed
        parsed.ok = true
        ast.indices.push
          index: parsed.index
          klass: 'premise'

    ASSERTION:
      process: (ast, parsed)->
        ast.current.children.push parsed
        assertion[parsed.rule.action](ast, parsed)
        ast.indices.push
          index: parsed.index
          klass: if parsed.iteration then 'supposed-end' else 'assertion'

    SUPPOSED:
      process: (ast, parsed)->
        node =
          type: ITERATION
          children: []
          parent: ast.current
        ast.current.children.push node
        ast.current = node
        parsed.ok = true
        node.children.push parsed
        ast.indices.push
          index: parsed.index
          klass: 'supposed'

    SUPPOSED_END:
      process: (ast, parsed)->
        #controlar que no sea un nuevo supuesto
        if ast.current.type isnt ITERATION
          return error.unexpected_close_iteration ast
        if ast.current.children.length < 2
          suposed = extract(ast.current.children[0].expression)
          console.log(suposed)
          return error.unique_element_iteration ast, suposed
        parsed.iteration = ast.current
        ast.current = ast.current.parent
        ast.supposed_end = false
        if parsed.type isnt ASSERTION
          return error.unexpected_after_iteration ast, parsed
        #Importante: aca es donde se puede
        #omitir la conclusión de la iteración
        processors.ASSERTION.process(ast, parsed)

  clean = (ast)->
    unless ast.current is ast.root or ast.error
      ast.error = true
      ast.current.children.push ERROR_ELEMENT.FINALIZACION_DENTRO_DE_ITERACION
    ast.length = ast.index-1
    delete ast.current
    delete ast.supposed_end
    delete ast.index
    ast

  validator.validate = (raw, parser)->
    lines = raw.split('\n')
    ast =
      root:
        type: 'ROOT'
        children: []
      index: 1
      indices: []
    ast.current = ast.root
    for line in lines
      if /^(\s)*$/.test(line) #empty line
        continue
      if /^(\s)*\*\*/.test(line) #comment line
        continue
      if /^((\s)*\|)*((\s)*\-)*((\s)*\|)*(\s)*$/.test(line) # || -------- |
        continue
      try
        parsed = parser.parse(line)
      catch err
        ast.error = true
        context =
          rawLine: line.trim()
          parseError: err.message
        error_node = interpolates ERROR_ELEMENT.NO_SE_PUEDE_PARSEAR_LA_LINEA, context
        ast.current.children.push error_node
        return clean ast
      if parsed.type is 'SUPPOSED_END'
        if ast.supposed_end
          ast.error = true
          #prevents closes without supposed context
          parent = ast.current.parent or ast.current
          parent.children.push CLOSE_ITERATION_ERROR
          parent.children.push ERROR_ELEMENT.CIERRES_DE_ITERACION_CONSECUTIVOS
          return clean ast
        else
          ast.supposed_end = true
      else
        if ast.index isnt parsed.index
          ast.error = true
          context =
            rawLine: line.trim()
            expectedLineIndex: ast.index
          error_node = interpolates ERROR_ELEMENT.LINEA_NO_ESPERADA, context
          ast.current.children.push error_node
          return clean ast
        if ast.supposed_end
          processors.SUPPOSED_END.process(ast, parsed)
        else
          processors[parsed.type].process(ast, parsed)
        ast.index += 1
        if ast.error then return clean ast
    if ast.supposed_end
      ast.error = true
      ast.root.children.push CLOSE_ITERATION_ERROR
      ast.root.children.push ERROR_ELEMENT.FINALIZACION_EN_CIERRE_DE_ITERACION

    return clean ast
