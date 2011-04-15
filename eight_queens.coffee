# This is a solution to the Eight Queens problem.  (This is a fairly
# famous problem where you have to place eight queens on a chessboard
# such that none of the queens attack each other, i.e. all pieces
# are on distinct rows, columns, and diagonals).
#
# See https://github.com/showell/HipsterCode for the accompanying
# files:
#
#    eight_queens.html
#    eight_queens.js
#
# As of this writing, browsers do not natively support CoffeeScript,
# so follow instructions here to install the CoffeeScript compiler:
#
# http://jashkenas.github.com/coffee-script/#installation
#
# Then do:
#   coffee -c eight_queens.coffee
#

under_attack = (y_new, pieces_placed) ->
  # Determine if a piece would be under attack on the next open
  # file at rank y_new, given the pieces already placed.
  #
  # assumption: we are trying to place queens in files moving from
  # left to right, so the x coordinates are implicit here
  x_new = pieces_placed.length
  for x in [0...pieces_placed.length] 
    y = pieces_placed[x]
    return true if y == y_new
    return true if x + y == x_new + y_new
    return true if x + y_new == x_new + y
  return false

solve = (n, controller) ->
  # Solve the eight-queens iteratively by placing queens
  # on the board, and backtracking as needed when you reach
  # a dead end.  Interact with a "controller" object that draws
  # the board and calls back to you at certain intervals.
  #
  # This code may be slightly tricky to follow due to the
  # callbacks, but the key function to understand is
  # try_to_place_queen(), which will always be called
  # with the next candidate x/y coordinate for a queen,
  # where x and y are in the closure scope.
  pieces_placed = [] # array of y-coordinates indexed by x
  x = 0
  y = 0

  try_to_place_queen = ->
    if x >= n
      # If we get here, we just found a solution, so
      # we tell the controller to basically pause, declare
      # victory, then call back to "backtrack" when
      # the user is ready.
      controller.declare_victory(pieces_placed, backtrack)
      return
    if x < 0
      # If we have backtracked this far, there are no
      # more solutions, and this function returns (and
      # the app stops).
      controller.declare_no_more_solutions()
      return

    # x,y may actually be under attack, so we have
    # to advance down the file till we find a free space
    while y < n && under_attack(y, pieces_placed)
      y += 1
    if y < n
      x_place = x
      y_place = y
      pieces_placed[x] = y
      x += 1
      y = 0
      controller.place_queen(x_place, y_place, try_to_place_queen)
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
      controller.hide_queen(x, y_hide, try_to_place_queen)

  try_to_place_queen()

chessboard_controller = (n) ->
  canvas = document.getElementById("canvas")
  ctx = canvas.getContext("2d")
  w = 40
  h = 40
  delay = 100
  current_callback = null
  fadeout_callback = null
  paused = false
  toggle_button = document.getElementById("toggle")
  step_button = document.getElementById("step")
  log = document.getElementById("log")
  num_solutions_found = 0

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
    pulse()

  toggle_button.onclick = toggle
  step_button.onclick = step

  resume = ->
    return if paused
    pulse()

  pulse = ->
    if fadeout_callback?
      fadeout_callback()
      fadeout_callback = null
    current_callback()

  log_result = (v) ->
    log.innerHTML += "\n" + v.toString()

  draw_board()

  place_queen: (x, y, callback) ->
    draw(x, y, 'black')
    if callback?
      current_callback = callback
      setTimeout(resume, delay)

  hide_queen: (x, y, callback) ->
    draw(x, y, 'red')
    current_callback = callback
    fadeout_callback = ->
      draw(x, y, 'white')
    setTimeout(resume, delay)

  declare_victory: (pieces_placed, callback) ->
    num_solutions_found += 1
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
    log_result("All #{num_solutions_found} solutions found")


do -> 
  n = 8
  controller = chessboard_controller(n)
  solve(n, controller)
