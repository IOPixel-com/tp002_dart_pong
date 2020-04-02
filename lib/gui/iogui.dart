import 'dart:ui';
import 'dart:convert';

import 'package:flame/sprite.dart';
import 'package:flame/position.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';
import 'package:tp002_dart_pong/gui/index.dart';
import 'package:tp002_dart_pong/gui/iointerpolator.dart';

import 'package:tp002_dart_pong/render/resources_loader.dart';
import 'package:tp002_dart_pong/ioapplication.dart';
import 'package:tp002_dart_pong/gui/ioanimator.dart';
import 'package:tp002_dart_pong/gui/ioelement.dart';

class IOImage extends IOElement {
  Sprite _sprite;
  var _painter = Paint();

  IOImage(IOGUI gui, IOElement parent, String uid, IOAnchor anchor, Rect rect)
      : super(gui, parent, uid, anchor, rect);

  void load(String fileName) async {
    var rsc = await gui.resourcesLoader.loadSprite(fileName);
    _sprite = rsc.sprite;
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
    if (visible) {
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

class IOText extends IOElement {
  // painter
  TextPainter _painter;
  TextStyle _textStyle;

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
    // size = Position(_painter.size.width, _painter.size.height);
  }

  @override
  void render(Canvas canvas) {
    /* Position newPos;
    if (anchor == IOAnchor.UPPER_LEFT) {
      newPos = Position(position.x, position.y);
    } else if (anchor == IOAnchor.CENTER) {
      newPos = Position(position.x - size.x / 2.0, position.y - size.y / 2.0);
    } else if (anchor == IOAnchor.LOWER_RIGHT) {
      newPos = Position(position.x - size.x, position.y - size.y);
    }
    _painter.paint(canvas, Offset(newPos.x, newPos.y));
    for (var child in children) {
      child.render(canvas);
    } */
  }
}

enum IORatio { HORIZONTAL, VERTICAL, NONE }

typedef ClickGUICB = void Function(String);

class IOGUI extends IOElement {
  IOResourcesLoader _resourcesLoader;
  var _animators = List<IOAnimator>();
  ClickGUICB _clickCB;
  IOElement _lastElementClicked;

  IOGUI(this._resourcesLoader)
      : super(null, null, 'root', IOAnchor(), Rect.fromLTWH(0, 0, 750, 1334));

  IOResourcesLoader get resourcesLoader {
    return _resourcesLoader;
  }

  set clickCB(ClickGUICB cb) {
    _clickCB = cb;
  }

  set size(Size size) {
    super.relativeRect = Rect.fromLTWH(0, 0, size.width, size.height);
    super.updateRect = true;
    var scaler = Vector2(size.width / super.originRect.width,
        size.height / super.originRect.height);
    onResize(scaler);
  }

  void render(Canvas canvas) {
    // update positions
    recalculateAbsoluteRect(false);
    // render
    for (var el in children) {
      if (el.visible) {
        el.render(canvas);
      }
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

  static IOElement findElement(Offset pos, IOElement element) {
    // if not visible -> No
    if (!element.visible) return null;
    // look into children of child before
    for (var c in element.children) {
      var e = findElement(pos, c);
      if (e != null) return e;
    }
    if (element.isPointInside(pos)) {
      return element;
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
      } else {
        this?._clickCB("none");
        _lastElementClicked = null;
      }
    }
  }

  // utils
  void loadScene(String filename) {
    resourcesLoader.loadText(filename, _loadedScene);
  }

  void _loadedScene(String filename) {
    var r = resourcesLoader.loadedResources[filename];
    if (r.status == IOResourceStatus.LOADED) {
      var jScene = json.decode(r.text);
      // Retrieve size
      originRect = Rect.fromLTWH(0, 0, jScene['size'][0], jScene['size'][1]);
      // load elements
      for (var el in jScene['elements']) {
        var parent = _loadSceneElement(this, el, originRect);
        // rect with absolute coord
        var rect = _readRect(
            el['center'][0], el['center'][1], el['size'][0], el['size'][1]);
        // Children
        var children = el['children'];
        for (var el2 in children) {
          _loadSceneElement(parent, el2, rect);
        }
      }
    }
  }

  IOElement _loadSceneElement(IOElement parent, Map el, Rect parentRect) {
    // GUI
    if (el['category'] == 'gui') {
      String widget = el['widget'];
      String uid = el['name'];
      String spriteName = el['sprite']; // can be null
      IOAnchor anchor =
          IOAnchor.fromText(el['align'], el['valign'], el['scale']);
      // size
      var rect = _readRect(
          el['center'][0], el['center'][1], el['size'][0], el['size'][1]);
      var x = 0.0;
      var y = 0.0;
      var width = rect.width;
      var height = rect.height;
      if (anchor.align == IOAlign.LEFT) {
        var dX = rect.left - parentRect.left;
        x = dX + width / 2.0;
      } else if (anchor.align == IOAlign.CENTER) {
        var dX = rect.center.dx - parentRect.center.dx;
        x = dX;
      } else if (anchor.align == IOAlign.RIGHT) {
        var dX = rect.right - parentRect.right;
        x = dX - width / 2.0;
      } else {
        x = rect.left - parentRect.left;
      }
      if (anchor.valign == IOVAlign.TOP) {
        var dY = rect.top - parentRect.top;
        y = dY + height / 2.0;
      } else if (anchor.valign == IOVAlign.CENTER) {
        var dY = rect.center.dy - parentRect.center.dy;
        y = dY;
      } else if (anchor.valign == IOVAlign.BOTTOM) {
        var dY = rect.bottom - parentRect.bottom;
        y = dY - height / 2.0;
      } else {
        y = rect.top - parentRect.top;
      }
      var rRect =
          Rect.fromCenter(center: Offset(x, y), width: width, height: height);
      print("scene $uid $rRect");
      if (widget == 'image') {
        return createImage(parent, uid, spriteName, anchor, rRect);
        //createImage(this, uid, filename, anchor, r, align);
      } else if (widget == 'panel') {
        return createImage(parent, uid, spriteName, anchor, rRect);
      } else if (widget == 'button') {
        return createButton(parent, uid, spriteName, anchor, rRect);
      }
    }
    return null;
  }

  Rect _readRect(double x, double y, double width, double height) {
    return Rect.fromCenter(center: Offset(x, y), width: width, height: height);
  }

  IOButton createButton(
      IOElement parent, String uid, String filename, IOAnchor anchor, Rect r) {
    var button = IOButton(this, parent, uid, anchor, r);
    button.load(filename);
    return button;
  }

  IOImage createImage(
      IOElement parent, String uid, String filename, IOAnchor anchor, Rect r) {
    var image = IOImage(this, parent, uid, anchor, r);
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
