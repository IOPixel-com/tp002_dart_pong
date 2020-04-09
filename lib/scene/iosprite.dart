import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flame/position.dart';

import 'package:tp002_dart_pong/gfx/index.dart';
import './ioscenenode.dart';
import './ioscene.dart';

class IOSprite extends IOSceneNode {
  Sprite _sprite;
  var _painter = Paint();

  IOSprite(IOScene scene, IONode parent, String uid, IOAnchor anchor, Rect rect)
      : super(scene, parent, uid, anchor, rect);

  _loaded(String filename, dynamic content) {
    _sprite = content as Sprite;
  }

  void load(String fileName) {
    scene.resourcesLoader.requestSprite(fileName, _loaded);
  }

  @override
  void render(Canvas canvas) {
    if (visible) {
      var upperLeft =
          Position(absoluteRect.topLeft.dx, absoluteRect.topLeft.dy);
      var size = Position(absoluteRect.width, absoluteRect.height);
      _sprite.renderPosition(canvas, upperLeft,
          size: size, overridePaint: _painter);
      print('render sprite $uid $upperLeft $size');
    }
    // render children
    for (var child in children) {
      child.render(canvas);
    }
  }
}
