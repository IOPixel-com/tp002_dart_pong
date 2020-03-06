import 'package:flame/gestures.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/flame.dart';

import 'package:tp002_dart_pong/ioscene.dart';
import 'package:tp002_dart_pong/pong.dart';
import 'package:tp002_dart_pong/ioapplication.dart';

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
  List<IOPongEvent> events = List<IOPongEvent>();

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
      events.add(IOPongEvent(IOPongEventType.DEFEAT));
      return;
    } else if (newPos.y > _height - Pong.MALLET_SIZE / 2.0) {
      // one point for player
      start(IOTIPOFF.PLAYER);
      events.add(IOPongEvent(IOPongEventType.VICTORY));
      return;
    }
    // check collision with walls
    if (newPos.x < _minX + Pong.MALLET_SIZE / 2.0) {
      // collision on left wall
      _puckVelocity.x = -_puckVelocity.x;
      events.add(IOPongEvent(IOPongEventType.COLLISION_WALL));
    } else if (newPos.x > _maxX - Pong.MALLET_SIZE / 2.0) {
      // collision on right wall
      _puckVelocity.x = -_puckVelocity.x;
      events.add(IOPongEvent(IOPongEventType.COLLISION_WALL));
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
      events.add(IOPongEvent(IOPongEventType.COLLISION_MALLET));
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
      events.add(IOPongEvent(IOPongEventType.COLLISION_MALLET));
    }
    _puckPos = newPos;
  }
}
