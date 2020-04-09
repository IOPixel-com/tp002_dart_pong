import 'dart:convert';
import 'dart:ui';

import 'package:tp002_dart_pong/scene/iotextnode.dart';
import 'package:vector_math/vector_math.dart';

import 'package:tp002_dart_pong/gfx/index.dart';

import './iosprite.dart';

// class IOSprite extends IONode {}

class IOScene extends IONode {
  // rsc loader
  IOResourcesLoader _resourcesLoader;

  IOScene(this._resourcesLoader)
      : super(null, 'scene', IOAnchor(), Rect.fromLTWH(0, 0, 750, 1334));

  IOResourcesLoader get resourcesLoader {
    return _resourcesLoader;
  }

  set size(Size size) {
    updateRect = true;
    relativeRect = Rect.fromLTWH(0, 0, size.width, size.height);
    var scaler =
        Vector2(size.width / originRect.width, size.height / originRect.height);
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

  // utils
  void loadScene(String filename) {
    resourcesLoader.requestText(filename, _loadedScene);
  }

  _loadedScene(String filename, dynamic content) {
    print('load Scene $filename');
    var jScene = json.decode(content as String);
    // Retrieve size
    originRect = Rect.fromLTWH(0, 0, jScene['size'][0], jScene['size'][1]);
    // load elements
    for (var el in jScene['elements']) {
      var parent = _loadSceneElement(this, el, originRect);
      // rect with absolute coord
      var rect = Rect.fromCenter(
          center: Offset(el['center'][0], el['center'][1]),
          width: el['size'][0],
          height: el['size'][1]);
      // Children
      var children = el['children'];
      for (var el2 in children) {
        _loadSceneElement(parent, el2, rect);
      }
    }
  }

  IONode _loadSceneElement(IONode parent, Map jEl, Rect parentRect) {
    // GUI
    if (jEl['category'] == 'scene') {
      String widget = jEl['widget'];
      String uid = jEl['name'];
      IOAnchor anchor =
          IOAnchor.fromText(jEl['align'], jEl['valign'], jEl['scale']);
      // size
      var rect = Rect.fromCenter(
          center: Offset(jEl['center'][0], jEl['center'][1]),
          width: jEl['size'][0],
          height: jEl['size'][1]);
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
      if (widget == 'sprite') {
        String spriteName = jEl['sprite']; // can be null
        return createSprite(parent, uid, spriteName, anchor, rRect);
      } else if (widget == 'text') {
        return createTextNode(parent, uid, anchor, rRect);
      }
      //createImage(this, uid, filename, anchor, r, align);
    }
    return null;
  }

  IONode createSprite(
      IONode parent, String uid, String filename, IOAnchor anchor, Rect r) {
    var image = IOSprite(this, parent, uid, anchor, r);
    image.load(filename);
    return image;
  }

  IONode createTextNode(IONode parent, String uid, IOAnchor anchor, Rect r) {
    var textW = IOTextNode(this, parent, uid, anchor, r);
    textW.text = '0-0';
    return textW;
  }
}
