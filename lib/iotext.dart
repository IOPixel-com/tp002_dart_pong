import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flame/position.dart';

import 'package:tp002_dart_pong/gui/ioposition.dart';

class IOText extends IOPosition {
  // painter
  TextPainter _painter;
  TextStyle _textStyle;
  // state

  IOText(IOAnchor anchor, Position position, Position size)
      : super(anchor, position, size) {
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

  set text(String txt) {
    _painter.text = TextSpan(text: txt, style: _textStyle);
    // compute layout & size
    _painter.layout();
    // retrieve size
    size = Position(_painter.size.width, _painter.size.height);
  }

  void draw(Canvas canvas) {
    Position newPos;
    if (anchor == IOAnchor.UPPER_LEFT) {
      newPos = Position(position.x, position.y);
    } else if (anchor == IOAnchor.CENTER) {
      newPos = Position(position.x - size.x / 2.0, position.y - size.y / 2.0);
    } else if (anchor == IOAnchor.LOWER_RIGHT) {
      newPos = Position(position.x - size.x, position.y - size.y);
    }
    _painter.paint(canvas, Offset(newPos.x, newPos.y));
  }
}
