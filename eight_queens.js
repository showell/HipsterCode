(function() {
  var canvas_grid, chessboard_controller, solution_logger, solve, under_attack;
  under_attack = function(y_new, pieces_placed) {
    var x, x_new, y, _ref;
    x_new = pieces_placed.length;
    for (x = 0, _ref = pieces_placed.length; (0 <= _ref ? x < _ref : x > _ref); (0 <= _ref ? x += 1 : x -= 1)) {
      y = pieces_placed[x];
      if (y === y_new) {
        return true;
      }
      if (x + y === x_new + y_new) {
        return true;
      }
      if (x + y_new === x_new + y) {
        return true;
      }
    }
    return false;
  };
  solve = function(n, controller) {
    var backtrack, pieces_placed, try_to_place_queen, x, y;
    pieces_placed = [];
    x = 0;
    y = 0;
    try_to_place_queen = function() {
      var x_place, y_place;
      if (x >= n) {
        controller.declare_victory(pieces_placed, backtrack);
        return;
      }
      if (x < 0) {
        controller.declare_no_more_solutions();
        return;
      }
      while (y < n && under_attack(y, pieces_placed)) {
        y += 1;
      }
      if (y < n) {
        x_place = x;
        y_place = y;
        pieces_placed[x] = y;
        x += 1;
        y = 0;
        return controller.place_queen(x_place, y_place, try_to_place_queen);
      } else {
        return backtrack();
      }
    };
    backtrack = function() {
      var y_hide;
      x -= 1;
      y_hide = pieces_placed[x];
      y = y_hide + 1;
      pieces_placed = pieces_placed.slice(0, x);
      return controller.hide_queen(x, y_hide, try_to_place_queen);
    };
    return try_to_place_queen();
  };
  canvas_grid = function(n) {
    var canvas, ctx, h, w;
    canvas = document.getElementById("canvas");
    ctx = canvas.getContext("2d");
    w = 40;
    h = 40;
    (function() {
      var x, y;
      for (x = 0; (0 <= n ? x <= n : x >= n); (0 <= n ? x += 1 : x -= 1)) {
        ctx.moveTo(x * w, 0);
        ctx.lineTo(x * w, n * h);
      }
      for (y = 0; (0 <= n ? y <= n : y >= n); (0 <= n ? y += 1 : y -= 1)) {
        ctx.moveTo(0, y * w);
        ctx.lineTo(n * w, y * w);
      }
      return ctx.stroke();
    })();
    return {
      fill_square: function(x, y, color) {
        ctx.fillStyle = color;
        x = x * w;
        y = y * h;
        return ctx.fillRect(x + 1, y + 1, w - 2, h - 2);
      }
    };
  };
  solution_logger = function() {
    var dom_object;
    dom_object = document.getElementById("log");
    return {
      log: function(v) {
        return dom_object.innerHTML += "\n" + v.toString();
      }
    };
  };
  chessboard_controller = function(n) {
    var current_callback, delay, fadeout_callback, grid, logger, num_solutions_found, paused, resume, step, step_button, tick, toggle, toggle_button;
    toggle_button = document.getElementById("toggle");
    step_button = document.getElementById("step");
    delay = 100;
    current_callback = null;
    fadeout_callback = null;
    paused = false;
    num_solutions_found = 0;
    toggle = function() {
      if (!paused) {
        paused = true;
        return toggle_button.value = "resume";
      } else {
        paused = false;
        toggle_button.value = "pause";
        return current_callback();
      }
    };
    step = function() {
      paused = true;
      toggle_button.value = "resume";
      return tick();
    };
    toggle_button.onclick = toggle;
    step_button.onclick = step;
    resume = function() {
      if (paused) {
        return;
      }
      return tick();
    };
    tick = function() {
      if (fadeout_callback != null) {
        fadeout_callback();
        fadeout_callback = null;
      }
      return current_callback();
    };
    grid = canvas_grid(n);
    logger = solution_logger();
    return {
      place_queen: function(x, y, callback) {
        grid.fill_square(x, y, 'black');
        if (callback != null) {
          current_callback = callback;
          return setTimeout(resume, delay);
        }
      },
      hide_queen: function(x, y, callback) {
        grid.fill_square(x, y, 'red');
        current_callback = callback;
        fadeout_callback = function() {
          return grid.fill_square(x, y, 'white');
        };
        return setTimeout(resume, delay);
      },
      declare_victory: function(pieces_placed, callback) {
        var x, y, _len;
        num_solutions_found += 1;
        delay = 5;
        for (x = 0, _len = pieces_placed.length; x < _len; x++) {
          y = pieces_placed[x];
          grid.fill_square(x, y, 'blue');
        }
        current_callback = callback;
        paused = true;
        toggle_button.value = "find next solution";
        return logger.log(pieces_placed);
      },
      clear_board: function(pieces_placed, x, callback) {
        var y;
        while (x < pieces_placed.length) {
          y = pieces_placed[x];
          grid.fill_square(x, y, 'white');
          x += 1;
        }
        current_callback = callback;
        return setTimeout(resume, delay);
      },
      declare_no_more_solutions: function() {
        alert("No more solutions");
        return logger.log("All " + num_solutions_found + " solutions found");
      }
    };
  };
  (function() {
    var controller, n;
    n = 8;
    controller = chessboard_controller(n);
    return solve(n, controller);
  })();
}).call(this);
