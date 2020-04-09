import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tp002_dart_pong/gfx/index.dart';
import 'package:tp002_dart_pong/scene/index.dart';
import 'package:tp002_dart_pong/scene/ioscenenode.dart';

class IOTextNode extends IOSceneNode {
  // painter
  TextPainter _painter;
  TextStyle _textStyle;
  var _textSize = Size(0, 0);
  var _fontColor = Colors.white;
  var _fontSize = 45.0;

  IOTextNode(
      IOScene scene, IONode parent, String uid, IOAnchor anchor, Rect rect)
      : super(scene, parent, uid, anchor, rect) {
    _painter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    _updateTextStyle();
  }

  set text(String txt) {
    _painter.text = TextSpan(text: txt, style: _textStyle);
    // compute layout & size
    _painter.layout();
    // retrieve new size -> recompute position
    _textSize = Size(_painter.size.width, _painter.size.height);
  }

  set color(Color c) {
    _fontColor = c;
    _updateTextStyle();
  }

  set size(double sz) {
    _fontSize = sz;
    _updateTextStyle();
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

  _updateTextStyle() {
    _textStyle = TextStyle(
      color: _fontColor,
      fontSize: _fontSize,
      shadows: <Shadow>[
        Shadow(
          blurRadius: 7,
          color: Color(0xff000000),
          offset: Offset(3, 3),
        ),
      ],
    );
  }
}
