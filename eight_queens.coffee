# This is a solution to the Eight Queens problem.  (This is a fairly
# famous problem where you have to place eight queens on a chessboard
# such that none of the queens attack each other, i.e. all pieces
# are on distinct rows, columns, and diagonals).
#

under_attack = (y_new, pieces_placed) ->
  # assumption: we are trying to place queens in files moving from
  # left to right, so the x coordinates are implicit here
  x_new = pieces_placed.length
  for x in [0...pieces_placed.length] 
    y = pieces_placed[x]
    return true if y == y_new
    return true if x + y == x_new + y_new
    return true if x + y_new == x_new + y
  return false

solve = (n, view) ->
  pieces_placed = [] # array of y-coordinates indexed by x
  x = 0
  y = 0
  place_one_queen = ->
    return if x < 0
    return if x >= n
    while y < n && under_attack(y, pieces_placed)
      y += 1
    if y < n
      x_place = x
      y_place = y
      pieces_placed[x] = y
      x += 1
      y = 0
      view.place_queen(x_place, y_place, place_one_queen)
    else
      # backtracking
      x -= 1
      y_hide = pieces_placed[x]
      y = y_hide + 1
      pieces_placed = pieces_placed[0...x]
      view.hide_queen(x, y_hide, place_one_queen)
  place_one_queen()

chessboard_view = (n) ->
  canvas = document.getElementById("canvas")
  ctx = canvas.getContext("2d")
  w = 40
  h = 40
  delay = 100
  current_callback = null
  paused = false
  toggle_button = document.getElementById("toggle")

  draw_board = ->
    for x in [0..n] 
      ctx.moveTo(x*w, 0)
      ctx.lineTo(x*w, n*h)
    for y in [0..n] 
      ctx.moveTo(0, y*w)
      ctx.lineTo(n*w, y*w)
    ctx.stroke()
      
  draw = (x, y, color) ->
    ctx.fillStyle = color
    x = x * w
    y = y * h
    ctx.fillRect(x+1, y+1, w-2, h-2)

  toggle = ->
    if !paused
      paused = true
      toggle_button.value = "resume"
    else
      paused = false
      toggle_button.value = "pause"
      current_callback()
    false

  toggle_button.onclick = toggle

  resume = ->
    current_callback() unless paused

  draw_board()

  place_queen: (x, y, callback) ->
    draw(x, y, 'black')
    current_callback = callback
    setTimeout(resume, delay)
  hide_queen: (x, y, callback) ->
    draw(x, y, 'white')
    current_callback = callback
    setTimeout(resume, delay)

display = (width, height) ->
  view = view_2d(width, height)
  render_board: (board) ->
    for x in [0...width]
      for y in [0...height]
        fate = board.alive([x, y])
        view.draw(x, y, fate)

do -> 
  n = 8
  view = chessboard_view(n)
  solve(n, view)
