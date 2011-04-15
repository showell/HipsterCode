(function() {
  var chessboard_view, display, solve, under_attack;
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
  solve = function(n, view) {
    var pieces_placed, place_one_queen, x, y;
    pieces_placed = [];
    x = 0;
    y = 0;
    place_one_queen = function() {
      var x_place, y_hide, y_place;
      if (x < 0) {
        return;
      }
      if (x >= n) {
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
        return view.place_queen(x_place, y_place, place_one_queen);
      } else {
        x -= 1;
        y_hide = pieces_placed[x];
        y = y_hide + 1;
        pieces_placed = pieces_placed.slice(0, x);
        return view.hide_queen(x, y_hide, place_one_queen);
      }
    };
    return place_one_queen();
  };
  chessboard_view = function(n) {
    var canvas, ctx, delay, draw, draw_board, h, w;
    canvas = document.getElementById("canvas");
    ctx = canvas.getContext("2d");
    w = 40;
    h = 40;
    delay = 100;
    draw_board = function() {
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
    };
    draw = function(x, y, color) {
      ctx.fillStyle = color;
      x = x * w;
      y = y * h;
      return ctx.fillRect(x + 1, y + 1, w - 2, h - 2);
    };
    draw_board();
    return {
      place_queen: function(x, y, callback) {
        draw(x, y, 'black');
        return setTimeout(callback, delay);
      },
      hide_queen: function(x, y, callback) {
        draw(x, y, 'white');
        return setTimeout(callback, delay);
      }
    };
  };
  display = function(width, height) {
    var view;
    view = view_2d(width, height);
    return {
      render_board: function(board) {
        var fate, x, y, _results;
        _results = [];
        for (x = 0; (0 <= width ? x < width : x > width); (0 <= width ? x += 1 : x -= 1)) {
          _results.push((function() {
            var _results;
            _results = [];
            for (y = 0; (0 <= height ? y < height : y > height); (0 <= height ? y += 1 : y -= 1)) {
              fate = board.alive([x, y]);
              _results.push(view.draw(x, y, fate));
            }
            return _results;
          })());
        }
        return _results;
      }
    };
  };
  (function() {
    var n, view;
    n = 8;
    view = chessboard_view(n);
    return solve(n, view);
  })();
}).call(this);
