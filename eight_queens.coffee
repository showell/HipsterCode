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


# Determine if a piece would be under attack on the next open
# file at rank y_new, given the pieces already placed.
#
# assumption: we are trying to place queens in files moving from
# left to right, so the x coordinates are implicit here
under_attack = (y_new, pieces_placed) ->
  x_new = pieces_placed.length
  for x in [0...pieces_placed.length] by 1
    y = pieces_placed[x]
    return true if y == y_new
    return true if x + y == x_new + y_new
    return true if x + y_new == x_new + y
  return false

# Solve the n-queens iteratively by placing queens
# on the board, and backtracking as needed when you reach
# a dead end.  Interact with a "controller" object that draws
# the board and calls back to you at certain intervals.
#
# This code may be slightly tricky to follow due to the
# callbacks, but the key function to understand is
# try\_to\_place\_queen(), which will always be called
# with the next candidate x/y coordinate for a queen,
# where x and y are in the closure scope.
solve = (n, controller) ->
  pieces_placed = [] # array of y-coordinates indexed by x
  x = 0
  y = 0

  try_to_place_queen = ->
    # If we get here, we just found a solution, so
    # we tell the controller to basically pause, declare
    # victory, then call back to "backtrack" when
    # the user is ready.
    if x >= n
      controller.declare_victory(pieces_placed, backtrack)
      return

    # If we have backtracked this far, there are no
    # more solutions, and this function returns (and
    # the app stops).
    if x < 0
      controller.declare_no_more_solutions()
      return

    # x,y may actually be under attack, so we have
    # to advance down the file till we find a free space
    while y < n && under_attack(y, pieces_placed)
      y += 1

    # Did we find a place??
    if y < n
      x_place = x
      y_place = y
      pieces_placed[x] = y
      x += 1
      y = 0
      # This queen position is not under attack, so we yield to
      # the controller and have it draw it.  We'll get a callback
      # when the user is ready.  At this point we don't know if we
      # have blocked out the rest of the board; we just know we
      # are safe.
      controller.place_queen(x_place, y_place, try_to_place_queen)
    # Or did we fall off the bottom of the board and need to backtrack?
    # (This is basically the case that the current queens have blocked
    # off the next file; once a file is closed, you are obviously done,
    # so then we will move the prior queen.)
    else
      backtrack()

  # We backtrack when we determine (somewhat lazily) that
  # the rest of the board is under attack.  We go back to
  # the most recent queen, pull her off the board, then
  # notify the controller to hide it, then wait for a callback
  # where we try to place a queen at the next y down.
  #
  # (We also call this right after getting a complete solution..
  # by backtracking, we get to a new unique solution.)
  backtrack = ->
    x -= 1
    y_hide = pieces_placed[x]
    y = y_hide + 1
    pieces_placed = pieces_placed[0...x]
    controller.hide_queen(x, y_hide, try_to_place_queen)

  try_to_place_queen()

# This is a light layer on top of the canvas to draw the
# eight-queens configurations.  It's just using black/blue
# squares to represent pieces for now.
canvas_grid = (n) ->
  canvas = document.getElementById("canvas")
  ctx = canvas.getContext("2d")
  w = 40
  h = 40

  # Draw the initial board (a bunch of gridlines).
  do ->
    for x in [0..n] by 1
      ctx.moveTo(x*w, 0)
      ctx.lineTo(x*w, n*h)
    for y in [0..n] by 1
      ctx.moveTo(0, y*w)
      ctx.lineTo(n*w, y*w)
    ctx.stroke()
      
  # Nothing fancy here, just some scaling and being
  # careful not to erase the borders.
  fill_square: (x, y, color) ->
    ctx.fillStyle = color
    x = x * w
    y = y * h
    ctx.fillRect(x+1, y+1, w-2, h-2)

# For now we just log solutions directly to the page.
solution_logger = ->
  dom_object = document.getElementById("log")
  log: (v) ->
    dom_object.innerHTML += "\n" + v.toString()

# This is a bit of a kitchen sink, as it handles/dispatches all
# events in the page:
#
#   - clicking pause/resume
#   - timeouts for animation
#   - algorithm wants something drawn 
#
chessboard_controller = (n) ->
  toggle_button = document.getElementById("toggle")
  step_button = document.getElementById("step")
  delay = 100
  solver_callback = null
  fadeout_callback = null
  paused = false
  num_solutions_found = 0
  grid = canvas_grid(n)
  logger = solution_logger()

  # the same button is used for resume/pause, and
  # we handle toggling the text on the button itself, 
  # as well as implementing pause/resume
  toggle_button.onclick = ->
    if !paused
      # handle "pause" case
      paused = true
      toggle_button.value = "resume"
    else
      # handle "resume" case
      paused = false
      toggle_button.value = "pause"
      # call back to the algorithm to keep on trucking
      tick()

  # The step button's callback advances the algorithm by one
  # tick (and effectively pauses the app). 
  step_button.onclick = ->
    paused = true
    toggle_button.value = "resume"
    tick()

  # try to tick, unless we are paused
  try_tick = ->
    return if paused
    tick()
    
  # Do the next step in the animation algorithm, fading
  # any square as necessary. (Squares that are "hidden"
  # actually are red for one tick/step.)
  tick = ->
    if fadeout_callback?
      fadeout_callback()
      fadeout_callback = null
    solver_callback()

  # For placing a queen, grid does the real work, but we orchestrate
  # the callback to the algorithm.
  place_queen: (x, y, callback) ->
    grid.fill_square(x, y, 'black')
    if callback?
      solver_callback = callback
      setTimeout(try_tick, delay)

  # We don't hide the square right away, but
  # instead leave it red for one tick, then resume processing.
  hide_queen: (x, y, callback) ->
    grid.fill_square(x, y, 'red')
    solver_callback = callback
    fadeout_callback = ->
      grid.fill_square(x, y, 'white')
    setTimeout(try_tick, delay)

  # We found a solution with all queens, so turn
  # squares blue, log it, etc.
  declare_victory: (pieces_placed, callback) ->
    num_solutions_found += 1
    delay = 5 # let's go faster after first solution
    for y, x in pieces_placed
      grid.fill_square(x, y, 'blue')
    solver_callback = callback
    paused = true
    toggle_button.value = "find next solution"
    logger.log(pieces_placed)

  # Clear all queens, then call back to the algorithm.
  clear_board: (pieces_placed, x, callback) ->
    while x < pieces_placed.length
      y = pieces_placed[x]
      grid.fill_square(x, y, 'white')
      x += 1
    solver_callback = callback
    setTimeout(try_tick, delay)

  # We're done!
  declare_no_more_solutions: ->
    alert("No more solutions")
    logger.log("All #{num_solutions_found} solutions found")

# Main program:
#
# - controller manages UI
# - solve() manages the algorithm, and it will delegate back
#   to the controller as needed for UI details
do -> 
  n = 8
  controller = chessboard_controller(n)
  solve(n, controller)
