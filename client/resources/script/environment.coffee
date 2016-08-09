
environment = {}

do ->
  count = 0
  
  current = 
    x:1
    y:1
    max_x:7
    min_x:0
    max_y:7
    min_y:0
  
  actions = 
    MoverNorte:->
      if current.y > current.min_y
        current.y -= 1
        board.set_current current
        error:false
      else
        error:true
        description: 'Fin del tablero al norte'
    MoverOeste:->
      if current.x > current.min_x
        current.x -= 1
        board.set_current current
        error:false
      else
        error:true
        description: 'Fin del tablero al Oeste'
    MoverSur:->
      if current.y < current.max_y
        current.y += 1
        board.set_current current
        error:false
      else
        error:true
        description: 'Fin del tablero al Sur'
    MoverEste:->
      if current.x < current.max_x
        current.x += 1
        board.set_current current
        error:false
      else
        error:true
        description: 'Fin del tablero al Este'
    PintarNegro:->
      board.PintarNegro()
      error:false
    PintarVerde:->
      board.PintarVerde()
      error:false
    PintarRojo:->
      board.PintarRojo()
      error:false
    Despintar:->
      board.Despintar()
      error:false
      
  actions.Arriba = actions.MoverNorte
  actions.Abajo = actions.MoverSur
  actions.Derecha = actions.MoverEste
  actions.Izquierda = actions.MoverOeste
  
  conditions =
    estaPintado:->
      board.estaPintado()
    estaPintadoDeNegro:->
      board.estaPintadoDeNegro()
    estaPintadoDeVerde:->
      board.estaPintadoDeVerde()
    estaPintadoDeRojo:->
      board.estaPintadoDeRojo()
    puedoMoverSur:->
      current.y < current.max_y
    puedoMoverNorte:->
      current.y > current.min_y
    puedoMoverEste:->
      current.x < current.max_x
    puedoMoverOeste:->
      current.x > current.min_x
      
  environment.examine = (key)->
    result = conditions[key]()
    #always resolve, but data change
    resolved(true, result)
    
  environment.effect = (key)->
    
    result = actions[key]()
    #resolve or reject based in result value
    resolved(not result.error, result.description)
    
  environment.view = board.view
  
  board.resize current
  
  environment.resize = (w, h)->
    current.max_x = w - 1
    current.max_y = h - 1
    if current.x > current.max_x then current.x = current.max_x
    if current.y > current.max_y then current.y = current.max_y
    board.resize current
  
  environment.left = ->
    conditions.puedoMoverOeste() and actions.MoverOeste()
  environment.right = ->
    conditions.puedoMoverEste() and actions.MoverEste()
  environment.up = ->
    conditions.puedoMoverNorte() and actions.MoverNorte()
  environment.down = ->
    conditions.puedoMoverSur() and actions.MoverSur()

