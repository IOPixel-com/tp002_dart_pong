import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tp002_dart_pong/gui/index.dart';

import 'package:tp002_dart_pong/gui/ioposition.dart';

class IOElement {
  var children = List<IOElement>();
  IOElement parent;
  IOGUI gui;
  // Positions
  IOAnchor anchor;
  Rect absoluteRect;
  Rect relativeRect;
  // flags
  bool visible = true;
  bool updateRect = true;
  // infos
  String uid;

  IOElement(this.gui, this.parent, this.uid, this.anchor, this.relativeRect) {
    // attach to parent if parent
    parent?.addChild(this);
    updateRect = true;
  }

  addChild(IOElement child) {
    children.add(child);
  }

  recalculateAbsoluteRect(bool parentModified) {
    if (parent == null) {
      if (updateRect) {
        absoluteRect = relativeRect;
        print("update $uid $absoluteRect");
      }
    } else {
      if (parentModified || updateRect) {
        if (anchor == IOAnchor.CENTER) {
          // parent center
          Offset pcenter = parent.absoluteRect.center;
          pcenter += relativeRect.topLeft;
          absoluteRect = Rect.fromCenter(
              center: pcenter,
              width: relativeRect.width,
              height: relativeRect.height);
        } else if (anchor == IOAnchor.UPPER_LEFT) {
          Offset pul = parent.absoluteRect.topLeft;
          pul += relativeRect.topLeft;
          absoluteRect = Rect.fromLTWH(
              pul.dx, pul.dy, relativeRect.width, relativeRect.height);
        } else if (anchor == IOAnchor.LOWER_RIGHT) {
          Offset pul = parent.absoluteRect.bottomRight;
          pul += relativeRect.bottomRight;
          pul -= Offset(relativeRect.width, relativeRect.height);
          absoluteRect = Rect.fromLTWH(
              pul.dx, pul.dy, relativeRect.width, relativeRect.height);
        }
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
    return;
    if (anchor == IOAnchor.CENTER) {
      Rect.fromLTWH(
          p.dx - relativeRect.width / 2.0,
          p.dy - relativeRect.height / 2.0,
          relativeRect.width,
          relativeRect.height);
    } else if (anchor == IOAnchor.UPPER_LEFT) {
      Rect.fromLTWH(p.dx, p.dy, relativeRect.width, relativeRect.height);
    } else if (anchor == IOAnchor.LOWER_RIGHT) {
      Rect.fromLTWH(p.dx - relativeRect.width, p.dy - relativeRect.height,
          relativeRect.width, relativeRect.height);
    }
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
