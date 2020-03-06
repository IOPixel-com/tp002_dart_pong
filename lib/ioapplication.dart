import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flame/gestures.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';

enum IOPAD { LEFT, RIGHT, NONE }

enum IOEventType { UP, DOWN }

class IOEvent {
  final IOEventType type;
  final Position position;

  IOEvent(this.type, this.position);
}

class IOActivity {
  void resize(Size sz) {}

  void render(Canvas canvas) {}

  void update(double t) {}

  void onEvent(IOEvent evt) {}
}

class IOApplication extends Game with PanDetector, TapDetector {
  List<IOActivity> _activities;
  IOActivity _current;

  IOApplication() {
    _activities = List<IOActivity>();
  }

  void start(IOActivity activity) {
    _activities.add(activity);
    _current = activity;
  }

  void stop() {
    _activities.removeLast();
    if (_activities.isNotEmpty) {
      _current = _activities.last;
    } else {
      _current = null;
    }
  }

  @override
  void resize(Size sz) {
    _current?.resize(sz);
  }

  @override
  void render(Canvas canvas) {
    _current?.render(canvas);
  }

  @override
  void update(double t) {
    _current?.update(t);
  }

  @override
  void onTapUp(TapUpDetails details) {
    // print('up ${details.localPosition}');
    _current?.onEvent(IOEvent(IOEventType.UP,
        Position(details.localPosition.dx, details.localPosition.dy)));
  }

  @override
  void onTapDown(TapDownDetails details) {
    // print('down ${details.localPosition}');
    _current?.onEvent(IOEvent(IOEventType.DOWN,
        Position(details.localPosition.dx, details.localPosition.dy)));
  }

  @override
  void onPanUpdate(DragUpdateDetails details) {
    // print('update ${details.localPosition} $_touch');
    _current?.onEvent(IOEvent(IOEventType.DOWN,
        Position(details.localPosition.dx, details.localPosition.dy)));
  }
}
