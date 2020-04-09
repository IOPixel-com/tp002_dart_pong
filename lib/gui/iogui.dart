import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';
import 'package:tp002_dart_pong/gfx/index.dart';
import 'package:tp002_dart_pong/gui/index.dart';
import 'package:tp002_dart_pong/gui/iointerpolator.dart';

import 'package:tp002_dart_pong/ioapplication.dart';
import 'package:tp002_dart_pong/gui/ioanimator.dart';
import 'package:tp002_dart_pong/gui/ioelement.dart';

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
    // animate
    for (var el in _animators) {
      el.animate();
    }
    // update positions
    recalculateAbsoluteRect(false);
    // render
    for (var el in children) {
      if (el.visible) {
        el.render(canvas);
      }
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
        if (_clickCB != null) {
          _clickCB(_lastElementClicked.uid);
        }
        _lastElementClicked = null;
      } else {
        if (_clickCB != null) {
          _clickCB("none");
        }
        _lastElementClicked = null;
      }
    }
  }

  // utils
  void loadScene(String filename) {
    resourcesLoader.requestText(filename, _loadedScene);
  }

  void _loadedScene(String filename, dynamic content) {
    print('load GUI $filename');
    var jScene = json.decode(content as String);
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

  IOElement _loadSceneElement(IOElement parent, Map el, Rect parentRect) {
    // GUI
    if (el['category'] == 'gui') {
      String widget = el['widget'];
      String uid = el['name'];
      String spriteName = el['sprite']; // can be null
      bool visible = true;
      if (el.containsKey('visible')) {
        if (el['visible'] == 'false') {
          visible = false;
        }
      }
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
      IONode newElement;
      print("load gui $uid $rRect");
      if (widget == 'image') {
        newElement = createImage(parent, uid, spriteName, anchor, rRect);
        //createImage(this, uid, filename, anchor, r, align);
      } else if (widget == 'panel') {
        newElement = createImage(parent, uid, spriteName, anchor, rRect);
      } else if (widget == 'button') {
        newElement = createButton(parent, uid, spriteName, anchor, rRect);
      } else if (widget == 'text') {
        var textW = createText(parent, uid, anchor, rRect);
        if (el.containsKey('txt')) {
          textW.text = el['txt'];
        }
        newElement = textW;
      }
      newElement?.visible = visible;
      return newElement;
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

  IOText createText(IOElement parent, String uid, IOAnchor anchor, Rect r) {
    var text = IOText(this, parent, uid, anchor, r);
    return text;
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
