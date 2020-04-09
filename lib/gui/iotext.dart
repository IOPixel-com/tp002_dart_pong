import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:tp002_dart_pong/gfx/index.dart';
import 'package:tp002_dart_pong/gui/index.dart';

class IOText extends IOElement {
  // painter
  TextPainter _painter;
  TextStyle _textStyle;
  var _textSize = Size(0, 0);

  IOText(IOGUI gui, IOElement parent, String uid, IOAnchor anchor, Rect rect)
      : super(gui, parent, uid, anchor, rect) {
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
    // retrieve new size -> recompute position
    _textSize = Size(_painter.size.width, _painter.size.height);
  }

  @override
  void render(Canvas canvas) {
    double x = 0;
    double y = 0;
    if (anchor.align == IOAlign.LEFT) {
      x = absoluteRect.left;
    } else if (anchor.align == IOAlign.CENTER) {
      x = absoluteRect.center.dx - _textSize.width / 2.0;
    } else if (anchor.align == IOAlign.RIGHT) {
      x = absoluteRect.right - _textSize.width;
    }
    if (anchor.valign == IOVAlign.TOP) {
      y = absoluteRect.top;
    } else if (anchor.valign == IOVAlign.CENTER) {
      y = absoluteRect.center.dy - _textSize.height / 2.0;
    } else if (anchor.valign == IOVAlign.BOTTOM) {
      y = absoluteRect.bottom - _textSize.height;
    }
    _painter.paint(canvas, Offset(x, y));
    for (var child in children) {
      child.render(canvas);
    }
  }
}
