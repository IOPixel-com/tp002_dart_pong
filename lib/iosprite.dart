import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flame/sprite.dart';
import 'package:flame/position.dart';

import 'package:tp002_dart_pong/gui/ioposition.dart';

class IOSprite extends IOPosition {
  Sprite _sprite;
  bool _visible = true;

  IOSprite(String filename, IOAnchor anchor, Position position, Position size)
      : _sprite = Sprite(filename),
        super(anchor, position, size);

  set center(Position center) {
    position.x = center.x - size.x / 2.0;
    position.y = center.y - size.y / 2.0;
  }

  set dX(double x) {
    position.x += x;
  }

  set visible(bool v) {
    _visible = v;
  }

  void draw(Canvas canvas) {
    if (_visible) {
      _sprite.renderPosition(canvas, upperLeft, size: size);
    }
  }
}
