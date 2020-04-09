import 'package:flame/position.dart';

import 'package:tp002_dart_pong/pong.dart';
import 'package:tp002_dart_pong/ioapplication.dart';

enum IOPongEventType { VICTORY, DEFEAT, COLLISION_WALL, COLLISION_MALLET }

class IOPongEvent {
  IOPongEventType type;

  IOPongEvent(this.type);
}

class IOPhy {
  static const int PUCK_SPEED_LIMIT = 10;
  // walls
  double _minX = 0;
  double _maxX = 100;
  double _minY = 0;
  double _maxY = 100;

  // puck
  Position _puckPos = Position(50, 50);
  Position _puckVelocity = Position(0, 1);
  double _puckSize = 50;
  int _puckSpeed = 1;

  // computer & player
  Position _playerPos = Position(50, 0);
  Position _computerPos = Position(50, 100);
  double _malletSize = 50;

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

  void setWalls(double minX, maxX, minY, maxY) {
    _minX = minX;
    _maxX = maxX;
    _minY = minY;
    _maxY = maxY;
  }

  set puckSize(double sz) {
    _puckSize = sz;
  }

  set malletSize(double sz) {
    _malletSize = sz;
  }

  void init([IOTIPOFF tipoff = IOTIPOFF.PLAYER]) {
    // positions
    _puckPos = Position((_minX + _maxX) / 2.0, (_minY + _maxY) / 2.0);
    _playerPos = Position((_minX + _maxX) / 2.0, _malletSize / 2.0 + _minY);
    _computerPos = Position((_minX + _maxX) / 2.0, _maxY - _malletSize / 2.0);
    _puckSpeed = 1;
    _puckVelocity = Position(0, 0);
  }

  void start([IOTIPOFF tipoff = IOTIPOFF.PLAYER]) {
    // positions
    _puckPos = Position((_minX + _maxX) / 2.0, _maxY / 2.0);
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
    if (direction == IOPAD.CENTER) {
      // limit to walls
      if (_playerPos.x - _malletSize / 2.0 - Pong.PAD_DX < _minX) {
        _playerPos.x = _minX + _malletSize / 2.0;
      } else if (_playerPos.x + _malletSize / 2.0 + Pong.PAD_DX > _maxX) {
        _playerPos.x = _maxX - _malletSize / 2.0;
      }
    } else if (direction == IOPAD.LEFT) {
      // limit to the left wall
      if (_playerPos.x - _malletSize / 2.0 - Pong.PAD_DX < _minX) {
        _playerPos.x = _minX + _malletSize / 2.0;
      } else {
        _playerPos.x -= Pong.PAD_DX;
      }
    } else if (direction == IOPAD.RIGHT) {
      // limit to the right wall
      if (_playerPos.x + _malletSize / 2.0 + Pong.PAD_DX > _maxX) {
        _playerPos.x = _maxX - _malletSize / 2.0;
      } else {
        _playerPos.x += Pong.PAD_DX;
      }
    }
    // update ai
    updateAI();
    // update puck pos
    Position newPos = _puckPos + _puckVelocity * dT;
    // check end of point
    if (newPos.y < _minY + _malletSize / 2.0) {
      // one point for computer
      events.add(IOPongEvent(IOPongEventType.DEFEAT));
      return;
    } else if (newPos.y > _maxY - _malletSize / 2.0) {
      // one point for player
      events.add(IOPongEvent(IOPongEventType.VICTORY));
      return;
    }
    // check puck collision with walls
    if (newPos.x < _minX + _puckSize / 2.0) {
      // collision on left wall
      _puckVelocity.x = -_puckVelocity.x;
      events.add(IOPongEvent(IOPongEventType.COLLISION_WALL));
    } else if (newPos.x > _maxX - _puckSize / 2.0) {
      // collision on right wall
      _puckVelocity.x = -_puckVelocity.x;
      events.add(IOPongEvent(IOPongEventType.COLLISION_WALL));
    }
    // check collision with mallets
    if (_playerPos.distance(newPos) < (_malletSize + _puckSize) / 2.0) {
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
        (_malletSize + _puckSize) / 2.0) {
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
