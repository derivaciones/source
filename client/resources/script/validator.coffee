validator = {}


do ->
  processors =  
    PREMISE:
      process: (ast, parsed)->
        ast.current.children.push parsed
        
    ASSERTION:
      process: (ast, parsed)->
        ast.current.children.push parsed
        
    SUPPOSED:
      process: (ast, parsed)->
        node = 
          type: 'ITERATION'
          children: []
          parent: ast.current
        ast.current.children.push node
        ast.current = node
        node.children.push parsed
        
    SUPPOSED_END:
      process: (ast, parsed)->
        #controlar que no sea un nuevo supuesto
        parsed.iteration = ast.current
        ast.current = ast.current.parent
        ast.current.children.push parsed
        ast.supposed_end = false
      
  clean = (ast)->
    unless ast.current is ast.root
      ast.root.children.push
        type: 'ERROR'
        error_key: 'STRUCTURE_ERROR'
        content: ['La derivación no puede finalizar dentro de un contexto de supuesto']
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
    ast.current = ast.root
    for line in lines
      try
        parsed = parser.parse(line)
      catch evnt
        ast.current.children.push
          type: 'ERROR'
          error_key: 'PARSE_ERROR'
          content: evnt.message.split('\n')
        return clean ast
      if parsed.type is 'SUPPOSED_END'
        if ast.supposed_end
          ast.current.children.push
            type: 'ERROR'
            error_key: 'SUPPOSED_ERROR'
            parsed: parsed
            content: ['No se pueden realizar dos cierres de contextos de suposición consecutivos']
          return clean ast
        else
          ast.supposed_end = true
      else
        if ast.index isnt parsed.index
          ast.current.children.push
            type: 'ERROR'
            error_key: 'INDEX_ERROR'
            parsed: parsed
            content: ['Se esperaba el numero de linea ' + ast.index]
          return clean ast
        if ast.supposed_end
          processors.SUPPOSED_END.process(ast, parsed)
        else
          processors[parsed.type].process(ast, parsed)
        ast.index += 1
    return clean ast
      

      