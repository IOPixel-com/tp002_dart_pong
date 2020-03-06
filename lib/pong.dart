import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:flame/gestures.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/flame.dart';

import 'package:tp002_dart_pong/ioscene.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Pong().widget);
}

enum IOPAD { LEFT, RIGHT, NONE }

enum IOTIPOFF { PLAYER, COMPUTER }

class IOPhy {
  static const int PUCK_SPEED_LIMIT = 10;
  // walls
  double _minX = 0;
  double _maxX = 100;
  double _height = 100;

  // puck
  Position _puckPos = Position(50, 50);
  Position _puckVelocity = Position(0, 1);
  int _puckSpeed = 1;

  // computer & player
  Position _playerPos = Position(50, 0);
  Position _computerPos = Position(50, 100);

  // AI

  // events
  List<IOEvent> events = List<IOEvent>();

  Position get puckPos {
    return _puckPos;
  }

  Position get playerPos {
    return _playerPos;
  }

  Position get computerPos {
    return _computerPos;
  }

  void resize(Position sz) {
    // wall
    _minX = Pong.WALL_SIZE;
    _maxX = sz.x - Pong.WALL_SIZE;
    _height = sz.y;
    // restart game
    start();
  }

  void start([IOTIPOFF tipoff = IOTIPOFF.PLAYER]) {
    // positions
    _puckPos = Position((_minX + _maxX) / 2.0, _height / 2.0);
    _playerPos = Position((_minX + _maxX) / 2.0, Pong.MALLET_SIZE / 2.0);
    _computerPos =
        Position((_minX + _maxX) / 2.0, _height - Pong.MALLET_SIZE / 2.0);
    if (tipoff == IOTIPOFF.PLAYER) {
      _puckVelocity = Position(0, -Pong.PUCK_VELOCITY);
    } else {
      _puckVelocity = Position(0, Pong.PUCK_VELOCITY);
    }
    _puckSpeed = 1;
  }

  void updateAI() {
    // stupid ai
    _computerPos.x = _puckPos.x;
  }

  void update(double dT, IOPAD direction) async {
    // update player position
    if (direction == IOPAD.LEFT) {
      // limit to the left wall
      if (_playerPos.x - Pong.MALLET_SIZE / 2.0 - Pong.PAD_DX < _minX) {
        _playerPos.x = _minX + Pong.MALLET_SIZE / 2.0;
      } else {
        _playerPos.x -= Pong.PAD_DX;
      }
    } else if (direction == IOPAD.RIGHT) {
      // limit to the right wall
      if (_playerPos.x + Pong.MALLET_SIZE / 2.0 + Pong.PAD_DX > _maxX) {
        _playerPos.x = _maxX - Pong.MALLET_SIZE / 2.0;
      } else {
        _playerPos.x += Pong.PAD_DX;
      }
    }
    // update ai
    updateAI();
    // update puck pos
    Position newPos = _puckPos + _puckVelocity * dT;
    // check end of point
    if (newPos.y < Pong.MALLET_SIZE / 2.0) {
      // one point for computer
      start(IOTIPOFF.COMPUTER);
      events.add(IOEvent(IOEventType.DEFEAT));
      return;
    } else if (newPos.y > _height - Pong.MALLET_SIZE / 2.0) {
      // one point for player
      start(IOTIPOFF.PLAYER);
      events.add(IOEvent(IOEventType.VICTORY));
      return;
    }
    // check collision with walls
    if (newPos.x < _minX + Pong.MALLET_SIZE / 2.0) {
      // collision on left wall
      _puckVelocity.x = -_puckVelocity.x;
      events.add(IOEvent(IOEventType.COLLISION_WALL));
    } else if (newPos.x > _maxX - Pong.MALLET_SIZE / 2.0) {
      // collision on right wall
      _puckVelocity.x = -_puckVelocity.x;
      events.add(IOEvent(IOEventType.COLLISION_WALL));
    }
    // check collision with mallets
    if (_playerPos.distance(newPos) <
        (Pong.MALLET_SIZE + Pong.PUCK_SIZE) / 2.0) {
      // collision with player
      double velocity = 1.0;
      if (_puckSpeed < PUCK_SPEED_LIMIT) {
        velocity = _puckVelocity.length() * Pong.PUCK_ACCELERATION;
        _puckSpeed++;
      } else {
        velocity = _puckVelocity.length();
      }
      _puckVelocity = (newPos - _playerPos).normalize() * velocity;
      // compute new position
      newPos = _puckPos + _puckVelocity * dT;
      events.add(IOEvent(IOEventType.COLLISION_MALLET));
    } else if (_computerPos.distance(newPos) <
        (Pong.MALLET_SIZE + Pong.PUCK_SIZE) / 2.0) {
      // collision with computer
      double velocity = 1.0;
      if (_puckSpeed < PUCK_SPEED_LIMIT) {
        velocity = _puckVelocity.length() * Pong.PUCK_ACCELERATION;
        _puckSpeed++;
      } else {
        velocity = _puckVelocity.length();
      }
      _puckVelocity = (newPos - _computerPos).normalize() * velocity;
      // compute new position
      newPos = _puckPos + _puckVelocity * dT;
      events.add(IOEvent(IOEventType.COLLISION_MALLET));
    }
    _puckPos = newPos;
  }
}

class Pong extends Game with PanDetector, TapDetector {
  // constants
  static const WALL_SIZE = 36.0;
  static const PUCK_SIZE = 40.0;
  static const PUCK_VELOCITY = 200.0;
  static const PUCK_ACCELERATION = 1.2;
  static const MALLET_SIZE = 64.0;
  static const PAD_DX = 10.0;

  // gamepad
  var _padTouch = false;
  IOPAD _pad = IOPAD.NONE;

  // phy state
  IOPhy _phy = IOPhy();

  // score state
  int _computerScore = 0;
  int _playerScore = 0;

  // state
  var _date = 0.0;
  var _size = Size(0, 0);
  IOScene _scene;

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
    _date += t;
    // update physic
    _phy.update(t, _pad);
    // handle events
    for (var evt in _phy.events) {
      if (evt.type == IOEventType.DEFEAT) {
        _computerScore++;
        _scene?.setScore(_playerScore, _computerScore);
      } else if (evt.type == IOEventType.VICTORY) {
        _playerScore++;
        _scene?.setScore(_playerScore, _computerScore);
      } else if (evt.type == IOEventType.COLLISION_MALLET) {
        if (!kIsWeb) {
          Flame.audio.play('puck.mp3');
        }
      } else if (evt.type == IOEventType.COLLISION_WALL) {
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
  void onTapUp(TapUpDetails details) {
    // print('up ${details.localPosition}');
    _padTouch = false;
    _pad = IOPAD.NONE;
  }

  @override
  void onTapDown(TapDownDetails details) {
    // print('down ${details.localPosition}');
    _padTouch = true;
    pad(details.localPosition.dx);
  }

  @override
  void onPanUpdate(DragUpdateDetails details) {
    // print('update ${details.localPosition} $_touch');
    pad(details.localPosition.dx);
  }

  void pad(double x) {
    if (_padTouch) {
      if (x < _size.width / 2.0) {
        // left
        _pad = IOPAD.LEFT;
      } else {
        // right
        _pad = IOPAD.RIGHT;
      }
    } else {
      _pad = IOPAD.NONE;
    }
  }
}
