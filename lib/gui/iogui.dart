import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flame/position.dart';
import 'package:flutter/material.dart';
import 'package:tp002_dart_pong/gui/index.dart';
import 'package:tp002_dart_pong/gui/iointerpolator.dart';

import 'package:tp002_dart_pong/render/resources_loader.dart';
import 'package:tp002_dart_pong/ioapplication.dart';
import 'package:tp002_dart_pong/gui/ioposition.dart';
import 'package:tp002_dart_pong/gui/ioanimator.dart';
import 'package:tp002_dart_pong/gui/ioelement.dart';

class IOImage extends IOElement {
  Sprite _sprite;
  IORatio _align;
  var _painter = Paint();

  IOImage(IOGUI gui, IOElement parent, String uid, IOAnchor anchor, Rect rect,
      [IORatio align = IORatio.NONE])
      : _align = align,
        super(gui, parent, uid, anchor, rect);

  void load(String fileName) async {
    var rsc = await gui.resourcesLoader.loadSprite(fileName);
    _sprite = rsc.sprite;
  }

  set height(double height) {
    _align = IORatio.VERTICAL;
    var ratio = _sprite.image.width / _sprite.image.height;
    super.relativeRect = Rect.fromLTWH(super.relativeRect.topLeft.dx,
        super.relativeRect.topLeft.dy, ratio * height, height);
    super.updateRect = true;
  }

  set width(double width) {
    _align = IORatio.HORIZONTAL;
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

  void render(Canvas canvas) {
    if (visible) {
      var upperLeft =
          Position(absoluteRect.topLeft.dx, absoluteRect.topLeft.dy);
      var size = Position(absoluteRect.width, absoluteRect.height);
      _sprite.renderPosition(canvas, upperLeft,
          size: size, overridePaint: _painter);
      // print('render image $uid $upperLeft $size');
    }
    for (var child in children) {
      child.render(canvas);
    }
  }
}

class IOButton extends IOImage {
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

  void loadDisabled(String fileName) async {
    var rsc = await gui.resourcesLoader.loadSprite(fileName);
    _spriteDisabled = rsc.sprite;
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

enum IORatio { HORIZONTAL, VERTICAL, NONE }

typedef ClickGUICB = void Function(String);
typedef ResizeGUICB = void Function(String, Position sz);

class IOGUI extends IOElement {
  IOResourcesLoader _resourcesLoader;
  var _animators = List<IOAnimator>();
  ClickGUICB _clickCB;
  ResizeGUICB _resizeCB;
  IOElement _lastElementClicked;

  IOGUI(this._resourcesLoader)
      : super(null, null, 'root', IOAnchor.UPPER_LEFT,
            Rect.fromLTWH(0, 0, 750, 1334));

  IOResourcesLoader get resourcesLoader {
    return _resourcesLoader;
  }

  set clickCB(ClickGUICB cb) {
    _clickCB = cb;
  }

  set resizeCB(ResizeGUICB cb) {
    _resizeCB = cb;
  }

  void resize(Position size) {
    super.relativeRect = Rect.fromLTWH(0, 0, size.x, size.y);
    super.updateRect = true;
    // super.size = size;
    if (_resizeCB != null) {
      // call for resize
      for (var el in children) {
        resizeChild(el, size);
        // recursive
      }
    }
  }

  void resizeChild(el, size) {
    _resizeCB(el.uid, size);
    for (var e in el.children) {
      resizeChild(e, size);
    }
  }

  void render(Canvas canvas) {
    // update positions
    recalculateAbsoluteRect(false);
    // render
    for (var el in children) {
      el.render(canvas);
    }
  }

  void update() {
    // animate
    for (var el in _animators) {
      el.animate();
    }
    // update ioelements
    for (var el in children) {
      el.update();
    }
  }

  IOElement findElement(Offset pos, IOElement child) {
    // look into children of child before
    for (var c in child.children) {
      var e = findElement(pos, c);
      if (e != null) return e;
    }
    if (child.isPointInside(pos)) {
      return child;
    }
    return null;
  }

  void onEvent(IOEvent evt) {
    if (evt.type == IOEventType.DOWN) {
      for (var el in children.reversed) {
        var e = findElement(Offset(evt.position.x, evt.position.y), el);
        if (e != null) {
          e.onClickPressed();
          _lastElementClicked = e;
          break;
        }
      }
    }
    if (evt.type == IOEventType.UP) {
      if (_lastElementClicked != null) {
        _lastElementClicked.onClickReleased();
        this?._clickCB(_lastElementClicked.uid);
        _lastElementClicked = null;
      }
    }
  }

  // utils
  IOButton createButton(
      IOElement parent, String uid, String filename, IOAnchor anchor, Rect r) {
    var button = IOButton(this, parent, uid, anchor, r);
    button.load(filename);
    return button;
  }

  IOImage createImage(IOElement parent, String uid, String filename,
      IOAnchor anchor, Rect r, IORatio align) {
    var image = IOImage(this, parent, uid, anchor, r, align);
    image.load(filename);
    return image;
  }

  IOVisibilityAnimator createVisibilityAnimator() {
    var a = IOVisibilityAnimator();
    _animators.add(a);
    return a;
  }

  IOOpacityAnimator createOpacityAnimator([IOInterpolator i]) {
    var a = IOOpacityAnimator(i);
    _animators.add(a);
    return a;
  }
}
