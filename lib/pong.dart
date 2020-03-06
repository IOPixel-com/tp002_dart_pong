import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:flame/position.dart';
import 'package:flame/flame.dart';

import 'package:tp002_dart_pong/iogui.dart';
import 'package:tp002_dart_pong/ioscene.dart';
import 'package:tp002_dart_pong/iophy.dart';
import 'package:tp002_dart_pong/ioapplication.dart';

enum IOTIPOFF { PLAYER, COMPUTER }

class PongApplication extends IOApplication {
  PongApplication() {
    PongMenu pm = PongMenu(this);
    start(pm);
  }
}

class PongMenu extends IOActivity {
  IOGUI _gui = IOGUI();
  int _counter = 0;

  PongMenu(IOApplication app) : super(app);

  @override
  void resize(Size sz) {}

  @override
  void update(double t) {
    _counter++;
    if (_counter == 10000) {
      Pong pm = Pong(application);
      application.start(pm);
    }
  }

  @override
  void render(Canvas canvas) {
    _gui.render(canvas);
  }

  @override
  void onEvent(IOEvent evt) {
    _gui.onEvent(evt);
  }
}

class Pong extends IOActivity {
  // constants
  static const WALL_SIZE = 36.0;
  static const PUCK_SIZE = 40.0;
  static const PUCK_VELOCITY = 200.0;
  static const PUCK_ACCELERATION = 1.2;
  static const MALLET_SIZE = 64.0;
  static const PAD_DX = 10.0;

  // gamepad
  IOPAD _pad = IOPAD.NONE;

  // phy state
  IOPhy _phy = IOPhy();

  // score state
  int _computerScore = 0;
  int _playerScore = 0;

  // state
  var _size = Size(0, 0);
  IOScene _scene;

  Pong(IOApplication app) : super(app);

  @override
  void resize(Size sz) {
    // fonction appelee quand la taille de l ecran est definie
    print('resize $sz');
    _phy.resize(Position(sz.width, sz.height));
    _size = sz;
    if (_scene == null) {
      // scene
      _scene = IOScene(Position(sz.width, sz.height));
      Flame.util.fullScreen();
      Flame.util.setPortrait();
      if (!kIsWeb) {
        Flame.audio.loadAll(['puck.mp3', 'goal.mp3']);
      }
    } else {
      _scene.resize(Position(sz.width, sz.height));
    }
  }

  @override
  void render(Canvas canvas) {
    if (_scene != null) {
      _scene.draw(canvas);
    }
  }

  @override
  void update(double t) {
    // delta en second entre deux images
    // a 60 fps (ips en fr) cela correspond a 0.0166s
    // si on a 0.032ms, on a un traitement graphique trop lourd pour une image
    // print('delta time in ms between two frames: $_date $t');
    // update physic
    _phy.update(t, _pad);
    // handle events
    for (var evt in _phy.events) {
      if (evt.type == IOPongEventType.DEFEAT) {
        _computerScore++;
        _scene?.setScore(_playerScore, _computerScore);
      } else if (evt.type == IOPongEventType.VICTORY) {
        _playerScore++;
        _scene?.setScore(_playerScore, _computerScore);
      } else if (evt.type == IOPongEventType.COLLISION_MALLET) {
        if (!kIsWeb) {
          Flame.audio.play('puck.mp3');
        }
      } else if (evt.type == IOPongEventType.COLLISION_WALL) {
        if (!kIsWeb) {
          Flame.audio.play('puck.mp3');
        }
      }
    }
    _phy.events.clear();
    if (_scene != null) {
      // physic positions into scene
      _scene.puckPos = _phy.puckPos;
      _scene.puckSize = Position(PUCK_SIZE, PUCK_SIZE);
      _scene.playerPos = _phy.playerPos;
      _scene.playerSize = Position(MALLET_SIZE, MALLET_SIZE);
      _scene.computerPos = _phy.computerPos;
      _scene.computerSize = Position(MALLET_SIZE, MALLET_SIZE);
    }
    // print(
    //    '$_date puck: ${_phy.puckPos} player: ${_phy.playerPos} computer: ${_phy.computerPos}');
  }

  @override
  void onEvent(IOEvent evt) {
    if (evt.type == IOEventType.DOWN || evt.type == IOEventType.MOVE) {
      if (evt.position.x < _size.width / 2.0) {
        _pad = IOPAD.LEFT;
      } else {
        _pad = IOPAD.RIGHT;
      }
    } else {
      _pad = IOPAD.NONE;
    }
  }
}
