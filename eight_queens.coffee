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
  try_to_place_queen = ->
    if x >= n
      view.declare_victory(pieces_placed, next_solution)
      return
    if x < 0
      view.declare_no_more_solutions()
      return
    while y < n && under_attack(y, pieces_placed)
      y += 1
    if y < n
      x_place = x
      y_place = y
      pieces_placed[x] = y
      x += 1
      y = 0
      view.place_queen(x_place, y_place, try_to_place_queen)
    else
      backtrack()

  backtrack = ->
      # We backtrack when we determine (somewhat lazily) that
      # the rest of the board is under attack.  We go back to
      # the most recent queen, pull her off the board, then
      # calculate the next tentative position for her on the file
      # (but we don't actually place it until the callback).
      x -= 1
      y_hide = pieces_placed[x]
      y = y_hide + 1
      pieces_placed = pieces_placed[0...x]
      view.hide_queen(x, y_hide, try_to_place_queen)

  next_solution = ->
    # Find the queen that is in the bottom rank, and then
    # backtrack from there.
    x = 0
    while x < n && pieces_placed[x] < n - 1
      x += 1
    view.clear_board(pieces_placed, x, backtrack)

  try_to_place_queen()

chessboard_view = (n) ->
  canvas = document.getElementById("canvas")
  ctx = canvas.getContext("2d")
  w = 40
  h = 40
  delay = 100
  current_callback = null
  paused = false
  toggle_button = document.getElementById("toggle")
  step_button = document.getElementById("step")
  log = document.getElementById("log")

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

  step = ->
    paused = true
    toggle_button.value = "resume"
    current_callback()

  toggle_button.onclick = toggle
  step_button.onclick = step

  resume = ->
    current_callback() unless paused

  log_result = (v) ->
    log.innerHTML += "\n" + v.toString()

  draw_board()

  place_queen: (x, y, callback) ->
    draw(x, y, 'black')
    if callback?
      current_callback = callback
      setTimeout(resume, delay)

  hide_queen: (x, y, callback) ->
    draw(x, y, 'white')
    current_callback = callback
    setTimeout(resume, delay)

  declare_victory: (pieces_placed, callback) ->
    delay = 5 # let's go faster after first solution
    for y, x in pieces_placed
      draw(x, y, 'blue')
    current_callback = callback
    paused = true
    toggle_button.value = "find next solution"
    log_result(pieces_placed)

  clear_board: (pieces_placed, x, callback) ->
    while x < pieces_placed.length
      y = pieces_placed[x]
      draw(x, y, 'white')
      x += 1
    current_callback = callback
    setTimeout(resume, delay)

  declare_no_more_solutions: ->
    alert("No more solutions")

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
