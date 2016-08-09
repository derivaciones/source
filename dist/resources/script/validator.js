var validator;

validator = {};

(function() {
  var clean, processors;
  processors = {
    PREMISE: {
      process: function(ast, parsed) {
        return ast.current.children.push(parsed);
      }
    },
    ASSERTION: {
      process: function(ast, parsed) {
        return ast.current.children.push(parsed);
      }
    },
    SUPPOSED: {
      process: function(ast, parsed) {
        var node;
        node = {
          type: 'ITERATION',
          children: [],
          parent: ast.current
        };
        ast.current.children.push(node);
        ast.current = node;
        return node.children.push(parsed);
      }
    },
    SUPPOSED_END: {
      process: function(ast, parsed) {
        parsed.iteration = ast.current;
        ast.current = ast.current.parent;
        ast.current.children.push(parsed);
        return ast.supposed_end = false;
      }
    }
  };
  clean = function(ast) {
    if (ast.current !== ast.root) {
      ast.root.children.push({
        type: 'ERROR',
        error_key: 'STRUCTURE_ERROR',
        content: ['La derivación no puede finalizar dentro de un contexto de supuesto']
      });
    }
    ast.length = ast.index - 1;
    delete ast.current;
    delete ast.supposed_end;
    delete ast.index;
    return ast;
  };
  return validator.validate = function(raw, parser) {
    var ast, evnt, line, lines, parsed, _i, _len;
    lines = raw.split('\n');
    ast = {
      root: {
        type: 'ROOT',
        children: []
      },
      index: 1
    };
    ast.current = ast.root;
    for (_i = 0, _len = lines.length; _i < _len; _i++) {
      line = lines[_i];
      try {
        parsed = parser.parse(line);
      } catch (_error) {
        evnt = _error;
        ast.current.children.push({
          type: 'ERROR',
          error_key: 'PARSE_ERROR',
          content: evnt.message.split('\n')
        });
        return clean(ast);
      }
      if (parsed.type === 'SUPPOSED_END') {
        if (ast.supposed_end) {
          ast.current.children.push({
            type: 'ERROR',
            error_key: 'SUPPOSED_ERROR',
            parsed: parsed,
            content: ['No se pueden realizar dos cierres de contextos de suposición consecutivos']
          });
          return clean(ast);
        } else {
          ast.supposed_end = true;
        }
      } else {
        if (ast.index !== parsed.index) {
          ast.current.children.push({
            type: 'ERROR',
            error_key: 'INDEX_ERROR',
            parsed: parsed,
            content: ['Se esperaba el numero de linea ' + ast.index]
          });
          return clean(ast);
        }
        if (ast.supposed_end) {
          processors.SUPPOSED_END.process(ast, parsed);
        } else {
          processors[parsed.type].process(ast, parsed);
        }
        ast.index += 1;
      }
    }
    return clean(ast);
  };
})();
