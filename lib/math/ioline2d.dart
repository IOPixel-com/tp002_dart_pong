import 'package:flame/position.dart';

class IOLine2D {
  double _a = 0.0;
  double _b = 0.0;
  double _c = 0.0;
  var _status = false;

  IOLine2D(Position p1, Position p2) {
    if ((p1.x == p2.x) && (p1.y == p2.y)) {
      _status = false;
    } else if (p1.x == p2.x) {
      // x = cste
      _b = 0;
      _a = 1;
      _c = -p1.x;
      _status = true;
    } else if (p1.y == p2.y) {
      // y = cste
      _a = 0;
      _b = 1;
      _c = p1.y;
      _status = true;
    } else {
      _b = 1.0;
      _a = (p1.y - p2.y) / (p1.x - p2.x);
      _c = p1.y - _a * p1.x;
      _status = true;
    }
  }

  IOLine2D.empty() {
    _status = false;
  }

  bool isValid() {
    return _status;
  }

  bool isParallel(IOLine2D other) {
    if (!_status || !other._status) {
      return true;
    }
    double determinant = other._a * _b - other._b * _a;
    if (determinant == 0) {
      return true;
    }
    return false;
  }

  Position intersect(IOLine2D other) {
    double det = other._a * _b - other._b * _a;
    double y = (_c * other._a - _a * other._c) / det;
    double x = (_c * other._b - _b * other._c) / det;
    return Position(x, y);
  }

  double sign(Position pt) {
    return -_b * pt.y + _a * pt.x + _c;
  }

  double findYByX(double x) {
    return (_a * x + _c) / _b;
  }

  double findXByY(double y) {
    return (_b * y - _c) / _a;
  }
}
