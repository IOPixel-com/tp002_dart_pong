import 'package:flutter_test/flutter_test.dart';
import 'package:tp002_dart_pong/gui/iointerpolator.dart';
import 'package:flame/position.dart';

void main() {
  group('IOLineInterpolator', () {
    test('Simple case', () {
      var i = IOLineInterpolator();
      i.addPoints(Position(0, 0));
      i.addPoints(Position(0.5, 1));
      i.addPoints(Position(1, 0));
      expect(i.getInterpolation(-1), 0);
      expect(i.getInterpolation(0), 0);
      expect(i.getInterpolation(0.25), .5);
      expect(i.getInterpolation(0.5), 1);
      expect(i.getInterpolation(0.75), .5);
      expect(i.getInterpolation(1), 0);
      expect(i.getInterpolation(2.0), 0.0);
    });
  });
}
