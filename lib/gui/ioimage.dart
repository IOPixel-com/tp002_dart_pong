import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flame/position.dart';
import 'package:flutter/material.dart';
import 'package:tp002_dart_pong/gfx/index.dart';

import 'package:tp002_dart_pong/gui/index.dart';

import 'package:tp002_dart_pong/gui/ioelement.dart';

class IOImage extends IOElement {
  Sprite _sprite;
  var _painter = Paint();

  IOImage(IOGUI gui, IOElement parent, String uid, IOAnchor anchor, Rect rect)
      : super(gui, parent, uid, anchor, rect);

  void _loaded(String filename, dynamic content) {
    _sprite = content as Sprite;
  }

  void load(String fileName) async {
    gui.resourcesLoader.requestSprite(fileName, _loaded);
  }

  set height(double height) {
    var ratio = _sprite.image.width / _sprite.image.height;
    super.relativeRect = Rect.fromLTWH(super.relativeRect.topLeft.dx,
        super.relativeRect.topLeft.dy, ratio * height, height);
    super.updateRect = true;
  }

  set width(double width) {
    var ratio = _sprite.image.width / _sprite.image.height;
    super.relativeRect = Rect.fromLTWH(super.relativeRect.topLeft.dx,
        super.relativeRect.topLeft.dy, width, width / ratio);
    super.updateRect = true;
  }

  @override
  set opacity(double v) {
    //_painter.blendMode = BlendMode.plus;
    _painter.color = Color(0xFFFFFFFF).withAlpha((255.0 * v).toInt());
  }

  @override
  void render(Canvas canvas) {
    if (_sprite != null && visible) {
      var upperLeft =
          Position(absoluteRect.topLeft.dx, absoluteRect.topLeft.dy);
      var size = Position(absoluteRect.width, absoluteRect.height);
      _sprite.renderPosition(canvas, upperLeft,
          size: size, overridePaint: _painter);
      // print('render image $uid $upperLeft $size');
    }
    // render children
    for (var child in children) {
      child.render(canvas);
    }
  }
}
