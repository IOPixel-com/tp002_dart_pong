import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flame/position.dart';

enum IOAnchor { UPPER_LEFT, CENTER, LOWER_RIGHT }

class IOText {
  // painter
  TextPainter _painter;
  TextStyle _textStyle;
  // state
  IOAnchor _anchor = IOAnchor.CENTER;
  Position _pos = Position(0, 0);
  Position _size = Position(0, 0);

  IOText() {
    _painter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    _textStyle = TextStyle(
      color: Color(0xffffffff),
      fontSize: 90,
      shadows: <Shadow>[
        Shadow(
          blurRadius: 7,
          color: Color(0xff000000),
          offset: Offset(3, 3),
        ),
      ],
    );
  }

  set anchor(IOAnchor anchor) {
    _anchor = anchor;
  }

  set text(String txt) {
    _painter.text = TextSpan(text: txt, style: _textStyle);
    // compute layout & size
    _painter.layout();
    // retrieve size
    _size = Position(_painter.size.width, _painter.size.height);
  }

  set position(Position pos) {
    _pos = pos;
  }

  void draw(Canvas canvas) {
    Position newPos;
    if (_anchor == IOAnchor.UPPER_LEFT) {
      newPos = Position(_pos.x, _pos.y);
    } else if (_anchor == IOAnchor.CENTER) {
      newPos = Position(_pos.x - _size.x / 2.0, _pos.y - _size.y / 2.0);
    } else if (_anchor == IOAnchor.LOWER_RIGHT) {
      newPos = Position(_pos.x - _size.x, _pos.y - _size.y);
    }
    _painter.paint(canvas, Offset(newPos.x, newPos.y));
  }
}
