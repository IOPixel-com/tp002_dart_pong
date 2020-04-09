import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flame/position.dart';
import 'package:flutter/material.dart';

import 'package:tp002_dart_pong/gfx/index.dart';
import 'package:tp002_dart_pong/gui/index.dart';
import 'package:tp002_dart_pong/gui/ioelement.dart';

class IOButton extends IOElement {
  var _painter = Paint();
  Sprite _sprite;
  Sprite _spriteDisabled;
  var _disabled = false;
  var _clicked = false;

  IOButton(
    IOGUI gui,
    IOElement parent,
    String uid,
    IOAnchor anchor,
    Rect rect,
  ) : super(gui, parent, uid, anchor, rect);

  void _loaded(String filename, dynamic content) {
    _sprite = content as Sprite;
  }

  void load(String fileName) async {
    gui.resourcesLoader.requestSprite(fileName, _loaded);
  }

  void _loadDisabled(String filename, dynamic content) {
    _sprite = content as Sprite;
  }

  void loadDisabled(String fileName) {
    gui.resourcesLoader.requestSprite(fileName, _loadDisabled);
  }

  void render(Canvas canvas) {
    if (visible) {
      var upperLeft =
          Position(absoluteRect.topLeft.dx, absoluteRect.topLeft.dy);
      var size = Position(absoluteRect.width, absoluteRect.height);
      if (_disabled && _spriteDisabled != null) {
        _spriteDisabled.renderPosition(canvas, upperLeft,
            size: size, overridePaint: _painter);
      } else if (_clicked) {
        var pos = upperLeft + Position(2, 2);
        _sprite.renderPosition(canvas, pos,
            size: size, overridePaint: _painter);
      } else {
        _sprite.renderPosition(canvas, upperLeft,
            size: size, overridePaint: _painter);
      }
    }
    // render children
    for (var child in children) {
      child.render(canvas);
    }
  }

  @override
  void onClickPressed() {
    _clicked = true;
    print('click pressed');
  }

  @override
  void onClickReleased() {
    _clicked = false;
    print('click released');
  }
}
