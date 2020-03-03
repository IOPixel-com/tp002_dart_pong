import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame/position.dart';
import 'package:flame/flame.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  runApp(Pong().widget);
}

class IOSprite {
  Sprite _sprite;
  Position _pos;
  Position _size;

  IOSprite.upperLeft(String filename, this._pos, this._size)
      : _sprite = Sprite(filename);

  void resize(Position sz) {
    _size = sz;
  }

  void draw(Canvas canvas) {
    _sprite.renderPosition(canvas, _pos, size: _size);
  }
}

class IOScene {
  IOSprite _bg;
  IOSprite _player;
  IOSprite _computer;

  IOScene(Position windowSize) {
    _bg = IOSprite.upperLeft('bg_metal.png', Position(0, 0), windowSize);
    _player = IOSprite.upperLeft('puck.png', Position(0, 0), Position(64, 64));
    _computer = IOSprite.upperLeft(
        'puck.png', Position(0, windowSize.y - 64), Position(64, 64));
        _
  }

  void resize(Position size) {
    _bg.resize(size);
  }

  void draw(Canvas canvas) {
    _bg.draw(canvas);
    _player.draw(canvas);
    _computer.draw(canvas);
  }
}

class Pong extends Game {
  double _date = 0;
  IOScene _scene;

  Pong() {
    //_player = Sprite('sprite.png');
    print('constructor');
  }

  @override
  void resize(Size sz) {
    // fonction appelee quand la taille de l ecran est definie
    print('resize $sz');
    if (_scene == null) {
      _scene = IOScene(Position(sz.width, sz.height));
      Flame.util.fullScreen();
      Flame.util.setPortrait();
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
    print('delta time in ms between two frames: $_date $t');
    _date += t;
  }
}
