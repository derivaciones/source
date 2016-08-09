interpreter = {}

do ->
  ast         = null
  environment = null
  
  invocation = (name)->
    TYPE: 'INVOCATION'
    name: name
    
  not_defined = {}
  
  root = ->
    activate:->
      resolved(true, true)
    deactivate:->
    step:->
      resolved(true, true)
    scope: {}
    
  eval_exp = (exp, scope)->
    switch exp.TYPE
      when 'IDENTIFIER' then scope[exp.name]
      when 'NUMERIC'    then parseInt exp.value
      when 'ADD'        then eval_exp(exp.left, scope) + eval_exp(exp.right, scope)
      when 'SUB'        then eval_exp(exp.left, scope) - eval_exp(exp.right, scope)
    
  get_procedure = (name)->
    required = null
    for procedure in ast 
      if procedure.name is name
        if not required
          required = procedure
        else
          throw new EXCEPTION.DuplicatedProcedure(name)
    unless required then throw new EXCEPTION.ProcedureNotExist(name)
    required
  
  ACTIVE      = 'active'
  TERMINATED  = 'terminated'  
  context = 
    BLOCK: (statements, parent)->
      scope: parent.scope
      index: -1
      activate:->
        @index += 1
        parent.view.scrollIntoView(false)
        if statements.length > @index
          statements[@index].view.classList.add ACTIVE
        else
          parent.view.classList.add TERMINATED
        resolved(true)
      deactivate: ->
        if statements.length > @index
          statements[@index].view.classList.remove ACTIVE
        parent.view.classList.remove TERMINATED
      step:->
        if statements.length > @index
          next = statements[@index]
          creator = context[next.TYPE]
          try
            next2 = creator(next, @)
          catch evnt
            return resolved(null, evnt.message)
          context.set_current next2
        else
          context.set_current parent
      
    INVOCATION:(invocation, parent)->
      procedure = get_procedure(invocation.name)
      scope = {}
      for arg in invocation.args or []
        scope[arg.name] = eval_exp arg.value, parent.scope
      scope: scope
      view: procedure.view
      deactive_params: ->
        for param_view in procedure.view.params
          param_view.setAttribute 'title', ''
          param_view.classList.remove ACTIVE
      activate: ->
        if not @processed
          @processed = true
          params_clone = procedure.params and procedure.params.slice() or []
          for arg in (invocation.args or [])
            index = params_clone.indexOf arg.name
            if index > -1
              params_clone.splice index, 1
            else
              @deactive_params()
              return resolved(null, 'line ' + invocation.line + ': ' + procedure.name + ': no se esperaba el argumento ' + arg.name)
          if params_clone.length
            @deactive_params()
            return resolved(null, 'line ' + invocation.line + ': ' + procedure.name + ': argumentos faltantes [' + params_clone.join(',') + ']')
          for param_view in procedure.view.params
            param_view.setAttribute 'title', @scope[param_view.param_name]
            param_view.classList.add ACTIVE
          context.set_current context.BLOCK(procedure.statements, @)
        else
          @deactive_params()
          context.set_current parent
      deactivate: ->
      
    CONDITIONAL:(conditional, parent)->
      scope: parent.scope
      view: conditional.view
      activate: ->
        if not @processed
          promise = synck()
          @processed = true
          environment.examine(conditional.condition)
            .success (result)=>
              if conditional.negate then result = not result
              if result
                context.set_current(context.BLOCK(conditional.positive, @))
                  .success -> promise.resolve()
                  .error -> promise.failure()
              else
                if conditional.negative
                  defer = context.set_current(context.BLOCK(conditional.negative, @))
                else 
                  defer = context.set_current parent
                defer.success -> promise.resolve()
                defer.error -> promise.failure()
          promise
        else
          context.set_current parent
      deactivate: ->
        conditional.view.classList.remove ACTIVE
          
    REPEAT:(repeat, parent)->
      scope: parent.scope
      view: repeat.view
      processed: 0
      amount: eval_exp repeat.index, parent.scope
      activate: ->
        if @processed < @amount
          @processed += 1
          context.set_current context.BLOCK(repeat.statements, @)
        else
          context.set_current parent
      deactivate: ->
        repeat.view.classList.remove ACTIVE
      
    ACTION:(action, parent)->
      scope: parent.scope
      activate: ->
        promise = synck()
        environment.effect(action.name)
          .success => 
            context.set_current(parent)
              .success -> promise.resolve()
              .error -> promise.failure()
          .error (data)=> 
            promise.failure(data)
        promise
      deactivate: ->
        action.view.classList.remove ACTIVE

  
  do ->
    current = null
    Object.defineProperty context, 'current',
      get:()->
        current
      set:(next)->
        throw new Error('cannot set current as attribute')
    context.set_current = (next)->
      current and current.deactivate()
      current = next
      current.activate()
  
  interpreter.reset = ->
    context.set_current context.INVOCATION(name:'main',root())
    
  interpreter.load = (next_ast, next_environment)->
    ast         = next_ast        
    environment = next_environment        
    @reset()
  
  interpreter.step = ->
    context.current.step()
    
  interpreter.deactivate = ->
    context.current and context.current.deactivate()
