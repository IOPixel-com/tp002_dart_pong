import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:flame/position.dart';
import 'package:flame/flame.dart';
import 'package:tp002_dart_pong/gfx/index.dart';
import 'package:tp002_dart_pong/gui/index.dart';

import 'package:tp002_dart_pong/iophy.dart';
import 'package:tp002_dart_pong/iotime.dart';
import 'package:tp002_dart_pong/ioapplication.dart';
import 'package:tp002_dart_pong/scene/iotextnode.dart';

enum IOTIPOFF { PLAYER, COMPUTER }

class PongApplication extends IOApplication {
  PongApplication() {
    PongMenu pm = PongMenu(this);
    start(pm);
  }
}

class PongMenu extends IOActivity {
  static const I7W = 750.0;
  static const I7H = 1334.0;

  PongMenu(IOApplication app) : super(app) {
    gui.clickCB = this.clickCB;
    gui.loadScene('menu.json');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  void clickCB(String uid) {
    if (uid == 'button_1p') {
      //exit(0);
      Pong pg = Pong(this.application);
      this.application.start(pg);
    } else if (uid == 'quit') {
      SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
    }
    print('click on $uid');
  }
}

enum PongState {
  START,
  PLAY,
  PAUSED,
  COMPUTER_POINT,
  PLAYER_POINT,
  COMPUTER_VICTORY,
  PLAYER_VICTORY
}

class Pong extends IOActivity {
  // constants
  static const I7W = 750.0;
  static const I7H = 1334.0;
  static const PUCK_VELOCITY = 200.0;
  static const PUCK_ACCELERATION = 1.2;
  static const PAD_DX = 10.0;

  // gamepad
  bool _padPressed = false;
  Position _padPosition = Position(0, 0);
  IOPAD _pad = IOPAD.NONE;

  // phy state
  IOPhy _phy = IOPhy();
  IONode _wallLeft;
  IONode _wallRight;
  IONode _puck;
  IONode _player2;
  IONode _player1;

  // score state
  PongState _state = PongState.START;
  PongState _lastState = PongState.START;
  double _stateDate = 0;
  double _eventDate = 0;
  int _computerScore = 0;
  int _playerScore = 0;

  // state
  var _mounted = false;

  // gui
  IOImage _pauseMenu;
  IOAnimator _winAnim;
  IOAnimator _loseAnim;
  IOTextNode _computerScoreNode;
  IOTextNode _playerScoreNode;

  Pong(IOApplication app) : super(app) {
    scene.loadScene("game.json");
    gui.loadScene("game.json");
    gui.clickCB = this.clickCB;
  }

  @override
  void onMount() {
    _mounted = true;
    _wallLeft = scene.findChild("wall_left");
    _wallRight = scene.findChild("wall_right");
    _player1 = scene.findChild("player1");
    _player2 = scene.findChild("player2");
    _puck = scene.findChild("puck");
    _playerScoreNode = scene.findChild("score1");
    _computerScoreNode = scene.findChild("score2");
    // gui
    var lineI1 = IOLineInterpolator();
    lineI1.addPoints(
        [Position(0, 0), Position(.1, 1), Position(.9, 1), Position(1, 0)]);
    _pauseMenu = gui.findChild("menu_pause");
    var winNode = gui.findChild("msg_win");
    _winAnim = gui.createOpacityAnimator(lineI1);
    _winAnim.disappearAtEnd = true;
    _winAnim.attach(winNode);
    var loseNode = gui.findChild("msg_lose");
    _loseAnim = gui.createOpacityAnimator(lineI1);
    _loseAnim.disappearAtEnd = true;
    _loseAnim.attach(loseNode);
  }

  @override
  void resize(Size sz) {
    super.resize(sz);
    scene.recalculateAbsoluteRect(false);
    // physic part
    _phy.setWalls(_wallLeft.absoluteRect.right, _wallRight.absoluteRect.left,
        _wallRight.absoluteRect.top, _wallRight.absoluteRect.bottom);
    _phy.puckSize = _puck.relativeRect.width;
    _phy.malletSize = _player1.relativeRect.width;
    _phy.init();
    _state = PongState.START;
    _computerScoreNode?.text = _computerScore.toStringAsFixed(0);
    _playerScoreNode?.text = _playerScore.toStringAsFixed(0);
  }

  void clickCB(String uid) {
    if (uid == "pause") {
      if (_state != PongState.PAUSED) {
        _pauseMenu.visible = true;
        _lastState = _state;
        _state = PongState.PAUSED;
      }
    }
    if (uid == "quit") {
      this.application.stop();
    }
    if (uid == "none" && _state == PongState.PAUSED) {
      _pauseMenu.visible = false;
      _state = _lastState;
    }
  }

  @override
  void render(Canvas canvas) {
    update();
    super.render(canvas);
  }

  void update() {
    // check if pause
    if (_state == PongState.PAUSED) return;
    // pad management
    if (_padPressed) {
      if ((_padPosition.x - _phy.playerPos.x).abs() < PAD_DX) {
        _pad = IOPAD.CENTER;
      } else if (_padPosition.x < _phy.playerPos.x) {
        _pad = IOPAD.LEFT;
      } else {
        _pad = IOPAD.RIGHT;
      }
    } else {
      _pad = IOPAD.NONE;
    }

    // update
    _stateDate = IOTime.time;
    if (_state == PongState.START && (_stateDate - _eventDate > 3)) {
      _eventDate = _stateDate;
      _state = PongState.PLAY;
      _phy.start();
    }
    //print("${_state} ${_stateDate - _eventDate}");
    if ((_state == PongState.PLAYER_VICTORY ||
            _state == PongState.COMPUTER_VICTORY) &&
        (_stateDate - _eventDate > 3)) {
      this.application.stop();
      return;
    }
    // delta en second entre deux images
    // a 60 fps (ips en fr) cela correspond a 0.0166s
    // si on a 0.032ms, on a un traitement graphique trop lourd pour une image
    // print('delta time in ms between two frames: $_date $t');
    // update physic
    _phy.update(IOTime.delta, _pad);
    // handle events
    for (var evt in _phy.events) {
      if (evt.type == IOPongEventType.DEFEAT) {
        _computerScore++;
        if (_computerScore >= 5) {
          _state = PongState.COMPUTER_VICTORY;
          _eventDate = _stateDate;
          _phy.init();
          // anim lose
          _loseAnim.start(4);
        } else {
          _state = PongState.START;
          _eventDate = _stateDate;
          _phy.init();
        }
        _computerScoreNode?.text = _computerScore.toStringAsFixed(0);
        _playerScoreNode?.text = _playerScore.toStringAsFixed(0);
        break;
      } else if (evt.type == IOPongEventType.VICTORY) {
        _playerScore++;
        if (_playerScore >= 5) {
          _state = PongState.PLAYER_VICTORY;
          _eventDate = _stateDate;
          _phy.init();
          // anim win
          _winAnim.start(4);
        } else {
          // _phy.start(IOTIPOFF.COMPUTER);
          _state = PongState.START;
          _eventDate = _stateDate;
          _phy.init();
        }
        _computerScoreNode?.text = _computerScore.toStringAsFixed(0);
        _playerScoreNode?.text = _playerScore.toStringAsFixed(0);
        break;
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
    // physic positions into scene
    if (_mounted) {
      _puck.center = Offset(_phy.puckPos.x, _phy.puckPos.y);
      _player1.center = Offset(_phy.playerPos.x, _phy.playerPos.y);
      _player2.center = Offset(_phy.computerPos.x, _phy.computerPos.y);
    }
    // print(
    //    '$_date puck: ${_phy.puckPos} player: ${_phy.playerPos} computer: ${_phy.computerPos}');
  }

  @override
  void onEvent(IOEvent evt) {
    super.onEvent(evt);
    if (evt.type == IOEventType.DOWN) {
      _padPressed = true;
    } else if (evt.type == IOEventType.UP) {
      _padPressed = false;
    }
    _padPosition = evt.position;
  }
}
