import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flame/position.dart';

import 'package:tp002_dart_pong/ioapplication.dart';
import 'package:tp002_dart_pong/ioposition.dart';

class IOElement extends IOPosition {
  IOElement(IOAnchor anchor, Position position, Position size)
      : super(anchor, position, size);

  void render(Canvas canvas) {}
}

class IOButton extends IOElement {
  Sprite _sprite;

  IOButton(String filename, IOAnchor anchor, Position position, Position size)
      : _sprite = Sprite(filename),
        super(anchor, position, size);

  void render(Canvas canvas) {
    _sprite.renderPosition(canvas, upperLeft, size: size);
  }
}

class IOGUI {
  List<IOElement> _elements = List<IOElement>();

  void resize(Position size) {}

  void render(Canvas canvas) {
    for (var el in _elements) {
      el.render(canvas);
    }
  }

  void onEvent(IOEvent evt) {
    if (evt.type == IOEventType.DOWN) {
      print('event click $evt');
      for (var el in _elements) {}
    }
  }

  // utils
  void createButton() {}
}
