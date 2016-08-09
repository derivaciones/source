
board = {}

do ->
  
  COLOR =
    BLACK: 'black'
    GREEN: 'green'
    RED:   'red'
  
  COLORS = (COLOR[prop] for prop of COLOR)
  
  rows = []
  
  add_classes = (element, classes)->
    classes ?= []
    for klass in classes
      element.classList.add klass
    element
    
  mk_div = (classes)->
    add_classes (document.createElement 'div'), classes
          
  board.view = mk_div ['board']
  
  paint = (cell, color)->
    cell.color and cell.view.classList.remove(cell.color)
    cell.color = color
    cell.color and cell.view.classList.add(cell.color)
  
  isPaintedWith = (color)->
    scope.current.color is color
  
  board.pintar = (color)->
    paint(scope.current, color)
    
  board.PintarNegro = ->
    @pintar COLOR.BLACK
  board.PintarVerde = ->
    @pintar COLOR.GREEN
  board.PintarRojo = ->
    @pintar COLOR.RED
  board.Despintar = ->
    @pintar()
    
  board.estaPintado = ()->
    not not scope.current.color
  board.estaPintadoDeNegro = ->
    isPaintedWith COLOR.BLACK
  board.estaPintadoDeVerde = ->
    isPaintedWith COLOR.GREEN
  board.estaPintadoDeRojo = ->
    isPaintedWith COLOR.RED
  scope = {}
  do ->
    currentClass = 'current'
    current = null
    Object.defineProperty scope, 'current',
      get:()->
        current
      set:(next)->
        current and current.view.classList.remove(currentClass)
        current = next
        current and current.view.classList.add(currentClass)
  
  board.set_current = (config)->  
    row = rows[config.y - config.min_y]
    unless row then return
    cell = row.cells[config.x - config.min_x]
    unless cell then return
    scope.current = cell
    
  switch_color = (cell)->->
    if not cell.color
      next = COLORS[0]
    else
      for color, index in COLORS
        if cell.color is color
          next = COLORS[index+1]
    paint(cell, next)
  
  board.resize = (config)->
    for row in rows
      board.view.removeChild row.view
    rows = []
    for row_index in [config.min_y .. config.max_y]
      row = 
        view: mk_div ['row']
        cells: []
      row.index = row_index
      board.view.appendChild row.view
      rows.push row
      for col_index in [config.min_x .. config.max_x]
        cell = view: mk_div ['cell']
        content = mk_div ['content']
        cell.col_index = col_index
        cell.view.appendChild content
        if row_index is config.y and col_index is config.x
          scope.current = cell
        row.view.appendChild cell.view
        row.cells.push cell
        cell.view.addEventListener 'click', switch_color(cell), false
