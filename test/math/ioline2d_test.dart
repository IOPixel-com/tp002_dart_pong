import 'package:flutter_test/flutter_test.dart';
import 'package:tp002_dart_pong/math/ioline2d.dart';
import 'package:flame/position.dart';

void main() {
  group('IOLine2D', () {
    test('empty constructor', () {
      expect(IOLine2D.empty().isValid(), false);
    });

    test('findXByY', () {
      var line = IOLine2D(Position(0.0, 0.0), Position(1.0, 2.0));

      var v = line.findXByY(1.0);

      expect(v, 0.5);
    });

    test('value should be decremented', () {});
  });
}
