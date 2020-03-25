import 'package:flame/position.dart';
import 'package:tp002_dart_pong/math/ioline2d.dart';

class IOInterpolator {
  double compute(double v) {
    return v;
  }
}

class IOLineInterpolator extends IOInterpolator {
  var _points = List<Position>();

  IOLineInterpolator([List<Position> pts]) {
    if (pts != null) {
      _points.addAll(pts);
    }
  }

  double compute(double t) {
    var current = Position(0, 0);
    var next = Position(0, 0);
    for (int i = 0; i < _points.length; ++i) {
      if (t >= _points[i].x) {
        current = _points[i];
        if (i + 1 < _points.length) {
          next = _points[i + 1];
        } else {
          next = Position(_points[i].x + .1, _points[i].y);
        }
      }
    }
    var line = IOLine2D(current, next);
    if (line.isValid()) {
      double value = line.findYByX(t);
      return value;
    } else {
      return 0.0;
    }
  }

  void addPoints(List<Position> pts) {
    _points.addAll(pts);
  }
}
