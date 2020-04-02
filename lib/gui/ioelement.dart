import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

import 'package:tp002_dart_pong/gui/index.dart';

class IOElement {
  // gui
  var children = List<IOElement>();
  IOElement parent;
  IOGUI gui;
  // properties
  IOAnchor anchor;
  bool visible = true;
  bool updateRect = true;
  Rect originRect;
  // current Positions
  Rect absoluteRect;
  Rect relativeRect;
  // infos
  String uid;

  IOElement(this.gui, this.parent, this.uid, this.anchor, this.originRect) {
    // attach to parent if parent
    relativeRect = originRect;
    parent?.addChild(this);
    updateRect = true;
  }

  addChild(IOElement child) {
    children.add(child);
  }

  IOElement findChild(String uid) {
    // look itself
    if (this.uid == uid) {
      return this;
    }
    // look into children
    for (var el in children) {
      var e = el.findChild(uid);
      if (e != null) {
        return e;
      }
    }
    return null;
  }

  void onResize(Vector2 scaler) {
    if (parent != null) {
      // define size of relativeRect
      var width = 0.0;
      var height = 0.0;
      var ratioHW = originRect.width / originRect.height;
      if (anchor.scaling == IOScaling.WH) {
        width = originRect.width * scaler.x;
        height = originRect.height * scaler.y;
      } else if (anchor.scaling == IOScaling.W) {
        width = originRect.width * scaler.x;
        height = width / ratioHW;
      } else if (anchor.scaling == IOScaling.H) {
        height = originRect.height * scaler.y;
        width = height * ratioHW;
      } else if (anchor.scaling == IOScaling.MAX_WH) {
        var scaling = max(scaler.x, scaler.y);
        width = originRect.width * scaling;
        height = originRect.height * scaling;
      } else {
        width = originRect.width;
        height = originRect.height;
      }
      // define position
      var x = 0.0;
      var y = 0.0;
      if (anchor.valign == IOVAlign.TOP) {
        y = originRect.top * scaler.y;
      } else if (anchor.valign == IOVAlign.CENTER) {
        y = originRect.center.dy * scaler.y - height / 2.0;
      } else if (anchor.valign == IOVAlign.BOTTOM) {
        y = originRect.bottom * scaler.y - height;
      } else {
        y = originRect.top;
      }
      if (anchor.align == IOAlign.LEFT) {
        x = originRect.left * scaler.x;
      } else if (anchor.align == IOAlign.CENTER) {
        x = originRect.center.dx * scaler.x - width / 2.0;
      } else if (anchor.align == IOAlign.RIGHT) {
        x = originRect.right * scaler.y - width;
      } else {
        x = originRect.left;
      }
      relativeRect = Rect.fromLTWH(x, y, width, height);
    }
    // recursive
    for (var el in children) {
      el.onResize(scaler);
    }
  }

  recalculateAbsoluteRect(bool parentModified) {
    if (parent == null) {
      if (updateRect) {
        absoluteRect = relativeRect;
        print("update $uid $absoluteRect");
      }
    } else {
      if (parentModified || updateRect) {
        var x = 0.0;
        var y = 0.0;
        var width = relativeRect.width;
        var height = relativeRect.height;
        if (anchor.align == IOAlign.LEFT) {
          x = parent.absoluteRect.left + relativeRect.left + width / 2.0;
        } else if (anchor.align == IOAlign.CENTER) {
          x = parent.absoluteRect.center.dx + relativeRect.center.dx;
        } else if (anchor.align == IOAlign.RIGHT) {
          x = parent.absoluteRect.right + relativeRect.right - width / 2.0;
        } else {
          x = parent.absoluteRect.left + relativeRect.left + width / 2.0;
        }
        if (anchor.valign == IOVAlign.TOP) {
          y = parent.absoluteRect.top + relativeRect.top + height / 2.0;
        } else if (anchor.valign == IOVAlign.CENTER) {
          y = parent.absoluteRect.center.dy + relativeRect.center.dy;
        } else if (anchor.valign == IOVAlign.BOTTOM) {
          y = parent.absoluteRect.bottom + relativeRect.bottom - height / 2.0;
        } else {
          y = parent.absoluteRect.top + relativeRect.top + height / 2.0;
        }
        absoluteRect =
            Rect.fromCenter(center: Offset(x, y), width: width, height: height);
        print("update $uid $absoluteRect");
      }
    }
    // children
    for (var child in children) {
      child.recalculateAbsoluteRect(parentModified || updateRect);
    }
    updateRect = false;
  }

  bool isPointInside(Offset pos) {
    return absoluteRect.contains(pos);
  }

  set position(Offset p) {
    relativeRect =
        Rect.fromLTWH(p.dx, p.dy, relativeRect.width, relativeRect.height);
  }

  set opacity(double v) {}

  void render(Canvas canvas) {
    for (var child in children) {
      child.render(canvas);
    }
  }

  void update() {}

  void onClickPressed() {}

  void onClickReleased() {}
}
