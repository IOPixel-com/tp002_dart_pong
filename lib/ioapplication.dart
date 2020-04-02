import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flame/game.dart';
import 'package:flame/position.dart';

import 'package:tp002_dart_pong/gui/index.dart';
import 'package:tp002_dart_pong/iotime.dart';
import 'package:tp002_dart_pong/render/resources_loader.dart';

enum IOPAD { CENTER, LEFT, RIGHT, NONE }

enum IOEventType { UP, DOWN, MOVE }

class IOEvent {
  final IOEventType type;
  final Position position;

  IOEvent(this.type, this.position);
}

enum IOActivityStatus { INIT, STARTED, ENDED }

class IOActivity {
  // cache
  IOApplication application;
  // state
  var _status = IOActivityStatus.INIT;
  // services
  var _resourceLoader = IOResourcesLoader();
  // gui
  IOGUI gui;

  IOActivity(this.application) {
    gui = IOGUI(_resourceLoader);
  }

  void resize(Size sz) {
    if (_status == IOActivityStatus.STARTED) {
      gui.size = sz;
    }
  }

  void render(Canvas canvas) {
    if (_status == IOActivityStatus.STARTED) {
      gui.render(canvas);
    }
  }

  void update() {
    if (_status == IOActivityStatus.INIT) {
      if (_resourceLoader.loaded) {
        _status = IOActivityStatus.STARTED;
        resize(application.size);
        onMount();
      }
    } else if (_status == IOActivityStatus.STARTED) {
      gui.update();
    }
  }

  void onEvent(IOEvent evt) {
    if (_status == IOActivityStatus.STARTED) {
      gui.onEvent(evt);
    }
  }

  void onMount() {}

  // util
  bool get resourcesLoaded {
    return _resourceLoader.loaded;
  }

  Future<IOResource> loadTexture(String fileName, [IOResourceLoadedCB cb]) {
    return _resourceLoader.loadTexture(fileName, cb);
  }
}

class IOApplication extends Game {
  // activities
  List<IOActivity> _activities;
  IOActivity _current;
  Size _size;

  Size get size {
    return _size;
  }

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
