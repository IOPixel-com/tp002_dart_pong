import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flame/sprite.dart';
import 'package:flame/position.dart';

class IOSprite {
  Sprite _sprite;
  Position _pos;
  Position _size;
  bool _visible = true;

  IOSprite.upperLeft(String filename, this._pos, this._size)
      : _sprite = Sprite(filename);

  IOSprite.center(String filename, Position pos, this._size)
      : _sprite = Sprite(filename) {
    _pos = Position(pos.x - _size.x / 2.0, pos.y - _size.y / 2.0);
  }

  IOSprite.ssUpperLeft(String filename, this._pos, this._size,
      {double x, double y, double width, double height})
      : _sprite = Sprite(filename, x: x, y: y, width: width, height: height);

  set size(Position sz) {
    _size = sz;
  }

  set position(Position pos) {
    _pos = pos;
  }

  set center(Position center) {
    _pos.x = center.x - _size.x / 2.0;
    _pos.y = center.y - _size.y / 2.0;
  }

  set dX(double x) {
    _pos.x += x;
  }

  set visible(bool v) {
    _visible = v;
  }

  void draw(Canvas canvas) {
    if (_visible) {
      _sprite.renderPosition(canvas, _pos, size: _size);
    }
  }
}
