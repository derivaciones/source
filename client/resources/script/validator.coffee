validator = {}

do ->
  
  error =
    reference_later:(ast)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'REFERENCES_ERROR'
        content: [
          'Deben utilizarse referencias a'
          'lineas anteriores a la actual'
          ]
    conjunction_unique_reference:(ast)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'CONJUNCTION_ELIMINATION_ERROR'
        content: [
          'La eliminacion de la conjunción'
          'debe tener una única referencia'
          ]
    conjunction_elimination: (ast, expression)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'CONJUNCTION_ELIMINATION_ERROR'
        content: [
          'Para generar ' + print(expression)
          'mediante la eliminación de'
          'la conjunciónse debe partir'
          'de otra fórmula de la forma'
          print(expression) + ' Λ X' 
          ]
    conjunction_connector:(ast)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'CONJUNCTION_CONNECTOR_ERROR'
        content: [
          'La intruducción de la'
          'conjunción permite generar'
          'una formula con un conector Λ'
          ]
    invalid_iteration_reference:(ast, first, last)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'ITERATION_REFERENCES_ERROR'
        content: [
          'La referencias no se corresponden'
          'con el contexto de suposición.'
          'Se esperaba ('+first+'-'+last+')'
          ]
    conjunction_introduction_references: (ast, left, right)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'CONJUNCTION_INTRODUCTION_REFERENCE_ERROR'
        content: [
          'Para introducir una'
          'conjunción deben estar'
          'afirmadas sus dos partes'
          print left
          print right
          'Asegurece también de'
          'indicar las referencias'
          'correctamente'
          ]
    disjunction_connector: (ast)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'DISJUNCTION_INTRODUCTION_ERROR'
        content: [
          'La intruducción de la'
          'disyunción permite generar '
          'una formula con un conector V'
          ]
    disjunction_introduction: (ast, left, right)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'DISJUNCTION_INTRODUCTION_REFERENCE_ERROR'
        content: [
          'Para introducir una disyunción'
          'debe estar afirmada al menos '
          'una de sus dos partes'
          print left
          print right
          'Asegurece también de indicar'
          'las referencias correctamente'
          ]
    conditional_connector: (ast)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'CONDITIONAL_INTRODUCTION_ERROR'
        content: [
          'La intruducción del'
          'condicional permite'
          'generar una formula'
          'con un conector →'
          ]
    conditional_iteration_lack: (ast)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'CONDITIONAL_INTRODUCTION_ERROR'
        content: [
          'La introducción de un'
          'condicional debe suceder'
          'a un contexto de suposición'
          ]
    conditional_introduction: (ast, left, right)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'CONDITIONAL_INTRODUCTION_ERROR'
        content: [
          'Para introducir este'
          'condicional se'
          'debería suponer'
          print left
          'y obtener como resultado'
          print right
          ]
    negation_type: (ast)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'NEGATION_INTRODUCTION_ERROR'
        content: [
          'La intruducción de'
          'la negación permite'
          'generar una formula'
          'con un simbolo ¬'
          ]
    negation_iteration_lack: (ast)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'NEGATION_INTRODUCTION_ERROR'
        content: [
          'La introducción de la'
          'negación debe suceder a'
          'un contexto de suposición'
          ]
    
    negation_introduction: (ast, expression)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'NEGATION_INTRODUCTION_ERROR'
        content: [
          'Para introducir esta negación'
          'se debería suponer'
          print expression
          'y obtener como resultado'
          'una contradicción (⊥)'
          ]
    negation_isnt_contradiction: (ast)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'NEGATION_ELIMINATION_ERROR'
        content: [
          'La eliminación de'
          'la negación genera'
          'una contradicción (⊥)'
          ]
    negation_elimination_references: (ast)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'NEGATION_ELIMINATION_ERROR'
        content: [
          'La eliminación de la'
          'negación espera dos elementos'
          'opuestos, Por ejemplo:'
          '1:(pVq)'
          '2:¬(pVq)'
          '3:⊥ E¬(1,2)'
          'Asegurece también de indicar'
          'las referencias correctamente'
          ]    
    conditional_elimination_references: (ast)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'CONDITIONAL_ELIMINATION_ERROR'
        content: [
          'La eliminación del'
          'condicional espera dos'
          'elementos, de los cuales,'
          'uno es una implicación y el' 
          'otro el antecedente del'
          'primero. Por ejemplo:'
          '1:(pVq)→p premisa'
          '2:(pVq) premisa'
          '3:p E→(1,2)'
          'Asegurece también de indicar'
          'las referencias correctamente'
          ]
    disjunction_elimination_references: (ast)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'DISJUNCTION_ELIMINATION_ERROR'
        content: [
          'La eliminación de la'
          'disyunción espera tres'
          'elementos, de los cuales,'
          'uno es una disyunción y los' 
          'otros dos, son condicionales'
          'que tienen como premisa las'
          'partes del primero. Y permite'
          'extraer el consecuente de los'
          'últimos. Por ejemplo:'
          '1:pVq premisa'
          '2:p→s premisa'
          '3:q→s premisa'
          '4:s EV(1,2,3)'
          'Asegurece también de indicar'
          'las referencias correctamente'
          ]
    double_negation_unique_reference:(ast)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'DOUBLE_NEGATION_ERROR'
        content: [
          'La eliminacion de la '
          'negación doble debe tener'
          'una única referencia'
          ]
    double_negation_references: (ast)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'DOUBLE_NEGATION_ERROR'
        content: [
          'La regla de la doble'
          'negación espera un'
          'elemento negado dos'
          'veces. Por ejemplo:'
          '1:¬¬(pVq) premisa'
          '2:(pVq) ¬¬(1)'
          'Asegurece también de indicar'
          'las referencias correctamente'
          ]
    double_negation_equal: (ast, first_ref, second_nested)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'DOUBLE_NEGATION_ERROR'
        content: [
          'Eliminar la doble'
          'negación en'
          print first_ref
          'produce'
          print second_nested
          ]
    repeat_unique_reference:(ast)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'REPEAT_ERROR'
        content: [
          'La repetición espera'
          'una única referencia'
          ]
    repeat_reference:(ast)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'REPEAT_ERROR'
        content: [
          'La repetición espera'
          'una referencia a un'
          'elemento equivalente'
          ]
    efsq_unique_reference:(ast)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'EFSQ_ERROR'
        content: [
          'EFSQ espera una'
          'única referencia'
          ]
    efsq_reference:(ast)->
      ast.error = true
      ast.current.children.push
        type: 'ERROR'
        error_key: 'EFSQ_ERROR'
        content: [
          'EFSQ espera una contradicción'
          'como referencia'
          ]
    unexpected_close_iteration:(ast)->
      ast.error = true
      ast.current.children.push
        type: 'CLOSE_ITERATION_ERROR'
      ast.current.children.push
        type: 'ERROR'
        error_key: 'ITERATION_CLOSE_ERROR'
        content: [
          'Para cerrar una iteracion con <<'
          'se debe partir de un supuesto'
          ]     
     unexpected_after_iteration:(ast, parsed)->
        ast.error = true
        ast.current.children.push parsed
        ast.current.children.push
          type: 'ERROR'
          error_key: 'ITERATION_CONCLUSION_ERROR'
          content: [
            'Luego de una iteración'
            'se espera una introducción'
            'de condicional o una'
            'intruducción de negación'
            ]     
          
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
      console.log classified
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
          parsed.ok = true
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
        return error.double_negation_references ast
      first_nested = extract(unique_ref.expression)
      if first_nested.type isnt NEGATION
        return error.double_negation_references ast
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
      ast.root.children.push
        type: 'ERROR'
        error_key: 'STRUCTURE_ERROR'
        content: [
          'La derivación no puede'
          'finalizar dentro de un'
          'contexto de supuesto'
        ]
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
      catch evnt
        ast.error = true
        ast.current.children.push
          type: 'ERROR'
          error_key: 'PARSE_ERROR'
          content: [
              line.trim()
              'Error en la estructura de la linea'
              'Revise la sintaxis'
            ].concat evnt.message.split('\n')
        return clean ast
      if parsed.type is 'SUPPOSED_END'
        if ast.supposed_end
          ast.error = true
          #prevents closes without supposed context
          parent = ast.current.parent or ast.current
          parent.children.push
            type: 'CLOSE_ITERATION_ERROR'
          parent.children.push
            type: 'ERROR'
            error_key: 'SUPPOSED_ERROR'
            parsed: parsed
            content: [
              'No se pueden realizar'
              'dos cierres de contextos'
              'de suposición consecutivos'
            ]
          return clean ast
        else
          ast.supposed_end = true
      else
        if ast.index isnt parsed.index
          ast.error = true
          ast.current.children.push
            type: 'ERROR'
            error_key: 'INDEX_ERROR'
            parsed: parsed
            content: [
              line.trim()
              'Se esperaba el numero de linea ' + ast.index
            ]
          return clean ast
        if ast.supposed_end
          processors.SUPPOSED_END.process(ast, parsed)
        else
          processors[parsed.type].process(ast, parsed)
        ast.index += 1
        if ast.error then return clean ast
    if ast.supposed_end
      ast.root.children.push
        type: 'CLOSE_ITERATION_ERROR'
      ast.root.children.push
        type: 'ERROR'
        error_key: 'STRUCTURE_ERROR'
        content: [
          'La derivación no puede'
          'finalizar con el cierre de'
          'un contexto de suposición'
        ]
    return clean ast
      

      