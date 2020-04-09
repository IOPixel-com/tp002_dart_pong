import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:tp002_dart_pong/gfx/index.dart';
import 'package:tp002_dart_pong/gui/index.dart';

class IOElement extends IONode {
  // gui
  IOGUI gui;

  IOElement(
      this.gui, IONode parent, String uid, IOAnchor anchor, Rect originRect)
      : super(parent, uid, anchor, originRect) {
    // attach to parent if parent
    relativeRect = originRect;
    parent?.addChild(this);
    updateRect = true;
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

  void onClickPressed() {}

  void onClickReleased() {}
}
