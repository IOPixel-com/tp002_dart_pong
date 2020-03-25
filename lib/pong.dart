import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:flame/position.dart';
import 'package:flame/flame.dart';
import 'package:tp002_dart_pong/gui/iointerpolator.dart';

import 'package:tp002_dart_pong/gui/ioposition.dart';
import 'package:tp002_dart_pong/gui/ioanimator.dart';
import 'package:tp002_dart_pong/gui/iogui.dart';
import 'package:tp002_dart_pong/ioscene.dart';
import 'package:tp002_dart_pong/iophy.dart';
import 'package:tp002_dart_pong/iotime.dart';
import 'package:tp002_dart_pong/ioapplication.dart';

enum IOTIPOFF { PLAYER, COMPUTER }

class PongApplication extends IOApplication {
  PongApplication() {
    PongMenu pm = PongMenu(this);
    start(pm);
  }
}

class PongTest extends IOActivity {
  ui.Image img;

  PongTest(IOApplication app) : super(app);

  void render(Canvas canvas) {}
}

class PongMenu extends IOActivity {
  static const I7W = 750.0;
  static const I7H = 1334.0;

  IOImage bg;
  IOImage logo;
  IOImage bgPopup;
  IOButton playButton;
  IOButton quitButton;
  IOButton settingsButton;

  PongMenu(IOApplication app) : super(app) {
    gui.clickCB = this.clickCB;
    gui.resizeCB = this.resizeCB;
    bg = gui.createImage(gui, 'bg', 'bg_1024.png', IOAnchor.CENTER,
        Rect.fromLTWH(0, 0, I7W, I7H), IORatio.HORIZONTAL);
    logo = gui.createImage(gui, 'logo', 'logo.png', IOAnchor.CENTER,
        Rect.fromLTWH(0, 0, 100, I7H / 10.0), IORatio.NONE);
    // menu
    bgPopup = gui.createImage(gui, 'bg_popup', 'bg_popup.png', IOAnchor.CENTER,
        Rect.fromLTWH(I7W / 2.0, I7H / 2.0, 100, 100), IORatio.NONE);
    playButton = gui.createButton(bgPopup, 'play', 'win_text.png',
        IOAnchor.CENTER, Rect.fromLTWH(400, 400, 100, 100));
    quitButton = gui.createButton(bgPopup, 'quit', 'lose_text.png',
        IOAnchor.CENTER, Rect.fromLTWH(400, 600, 100, 100));
    // settings
    settingsButton = gui.createButton(gui, 'settings', 'settings_on.png',
        IOAnchor.LOWER_RIGHT, Rect.fromLTWH(I7W, I7H, 100, 100));
    //settingsButton.loadDisabled('settings_off.png');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  // specifics

  void clickCB(String uid) {
    if (uid == 'play') {
      //exit(0);
      Pong pg = Pong(this.application);
      this.application.start(pg);
    } else if (uid == 'quit') {
      SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
    }
    print('click on $uid');
  }

  void resizeCB(String uid, Position sz) {
    if (uid == 'logo') {
      logo.height = sz.y / 10.0;
      logo.position = Offset(0, -4.0 * sz.y / 10.0);
    } else if (uid == 'bg_popup') {
      bgPopup.height = sz.y / 2.0;
      bgPopup.position = Offset(0, 0);
    } else if (uid == 'play') {
      playButton.height = sz.y / 10.0;
      playButton.position = Offset(0, -sz.y / 10.0);
    } else if (uid == 'quit') {
      quitButton.height = sz.y / 10.0;
      quitButton.position = Offset(0, sz.y / 10.0);
    } else if (uid == 'settings') {
      settingsButton.height = sz.y / 20.0;
      settingsButton.position = Offset(-sz.y / 20.0, -sz.y / 20.0);
    } else if (uid == 'bg') {
      if (sz.x < sz.y) {
        bg.height = sz.y;
      } else {
        bg.width = sz.x;
      }
      bg.position = Offset(0, 0);
    }
  }
}

enum PongState {
  START,
  PLAY,
  COMPUTER_POINT,
  PLAYER_POINT,
  COMPUTER_VICTORY,
  PLAYER_VICTORY
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
  bool _padPressed = false;
  Position _padPosition = Position(0, 0);
  IOPAD _pad = IOPAD.NONE;

  // phy state
  IOPhy _phy = IOPhy();

  // score state
  PongState _state = PongState.START;
  double _stateDate = 0;
  double _eventDate = 0;
  int _computerScore = 0;
  int _playerScore = 0;

  // state
  var _size = Size(0, 0);
  IOScene _scene;

  // messages
  IOImage _winMsg;
  IOAnimator _awinMsg;

  Pong(IOApplication app) : super(app) {
    _winMsg = gui.createImage(gui, 'play', 'win_text.png', IOAnchor.CENTER,
        Rect.fromLTWH(400, 400, 100, 100), IORatio.VERTICAL);
    _awinMsg = gui.createOpacityAnimator(
        IOLineInterpolator([Position(0, 0), Position(.5, 1), Position(1, 0)]));

    _awinMsg.attach(_winMsg);
    _awinMsg.start(IOTime.time, 5);
  }

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
      _state = PongState.START;
      _eventDate = _stateDate;
    }
    super.resize(sz);
  }

  @override
  void render(Canvas canvas) {
    if (_scene != null) {
      _scene.draw(canvas);
    }
    super.render(canvas);
  }

  @override
  void update() {
    super.update();
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
      print("${evt.type} $_stateDate");
      if (evt.type == IOPongEventType.DEFEAT) {
        _computerScore++;
        if (_computerScore >= 5) {
          _state = PongState.COMPUTER_VICTORY;
          _eventDate = _stateDate;
          _phy.init();
        } else {
          // _phy.start(IOTIPOFF.PLAYER);
          _state = PongState.START;
          _eventDate = _stateDate;
          _phy.init();
        }
        _scene?.setScore(_playerScore, _computerScore);
        break;
      } else if (evt.type == IOPongEventType.VICTORY) {
        _playerScore++;
        if (_playerScore >= 5) {
          _state = PongState.PLAYER_VICTORY;
          _eventDate = _stateDate;
          _phy.init();
        } else {
          // _phy.start(IOTIPOFF.COMPUTER);
          _state = PongState.START;
          _eventDate = _stateDate;
          _phy.init();
        }
        _scene?.setScore(_playerScore, _computerScore);
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
    if (evt.type == IOEventType.DOWN) {
      _padPressed = true;
    } else if (evt.type == IOEventType.UP) {
      _padPressed = false;
    }
    _padPosition = evt.position;
  }
}
