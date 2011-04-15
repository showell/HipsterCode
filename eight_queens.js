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
    var pieces_placed, x, y, _results;
    pieces_placed = [];
    x = 0;
    _results = [];
    while (x < n && x >= 0) {
      if (pieces_placed[x]) {
        y = pieces_placed[x];
        view.hide_queen(x, y);
        y += 1;
        pieces_placed = pieces_placed.slice(0, x);
      } else {
        y = 0;
      }
      while (y < n) {
        if (!under_attack(y, pieces_placed)) {
          break;
        }
        y += 1;
      }
      _results.push(y < n ? (view.place_queen(x, y), pieces_placed[x] = y, x += 1) : x -= 1);
    }
    return _results;
  };
  chessboard_view = function(n) {
    var canvas, ctx, draw, draw_board, h, w;
    canvas = document.getElementById("canvas");
    ctx = canvas.getContext("2d");
    w = 40;
    h = 40;
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
      place_queen: function(x, y) {
        return draw(x, y, 'black');
      },
      hide_queen: function(x, y) {
        return draw(x, y, 'white');
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
