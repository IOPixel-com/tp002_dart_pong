import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flame/game.dart';
import 'package:flame/position.dart';

import 'package:tp002_dart_pong/iogui.dart';
import 'package:tp002_dart_pong/iotime.dart';

enum IOPAD { CENTER, LEFT, RIGHT, NONE }

enum IOEventType { UP, DOWN, MOVE }

class IOEvent {
  final IOEventType type;
  final Position position;

  IOEvent(this.type, this.position);
}

class IOActivity {
  IOApplication application;
  IOGUI gui = IOGUI();

  IOActivity(this.application);

  void resize(Size sz) {
    gui.resize(Position(sz.width, sz.height));
  }

  void render(Canvas canvas) {
    gui.render(canvas);
  }

  void update() {
    gui.update();
  }

  void onEvent(IOEvent evt) {
    gui.onEvent(evt);
  }
}

class IOApplication extends Game {
  List<IOActivity> _activities;
  IOActivity _current;
  Size _size;

  IOApplication() {
    _activities = List<IOActivity>();
  }

  void start(IOActivity activity) {
    _activities.add(activity);
    if (_size != null) {
      activity.resize(_size);
    }
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
    _size = sz;
    _current?.resize(sz);
  }

  @override
  void render(Canvas canvas) {
    _current?.render(canvas);
  }

  @override
  void update(double t) {
    IOTime.incTime(t);
    _current?.update();
  }

  void down(PointerEvent details) {
    // print('DD down $details');
    _current?.onEvent(IOEvent(IOEventType.DOWN,
        Position(details.localPosition.dx, details.localPosition.dy)));
  }

  void up(PointerEvent details) {
    // print('DD up $details');
    _current?.onEvent(IOEvent(IOEventType.UP,
        Position(details.localPosition.dx, details.localPosition.dy)));
  }

  void move(PointerEvent details) {
    // print('DD move $details');
    _current?.onEvent(IOEvent(IOEventType.MOVE,
        Position(details.localPosition.dx, details.localPosition.dy)));
  }
}
