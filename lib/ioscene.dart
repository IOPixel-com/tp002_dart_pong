import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flame/position.dart';

import 'package:tp002_dart_pong/iosprite.dart';
import 'package:tp002_dart_pong/iotext.dart';
import 'package:tp002_dart_pong/pong.dart';

enum IOEventType { VICTORY, DEFEAT, COLLISION_WALL, COLLISION_MALLET }

class IOEvent {
  IOEventType type;

  IOEvent(this.type);
}

class IOScene {
  IOSprite _bg;
  IOSprite _player;
  IOSprite _computer;
  IOSprite _puck;
  IOSprite _wallLeft;
  IOSprite _wallRight;
  IOSprite _msgWin;
  IOSprite _msgLose;
  IOText _score;

  IOScene(Position windowSize) {
    // sprites
    _bg = IOSprite.upperLeft('bg_metal.png', Position(0, 0), windowSize);
    _player = IOSprite.upperLeft(
        'mallet_player.png', Position(0, 0), Position(64, 64));
    _computer = IOSprite.upperLeft('mallet_computer.png',
        Position(0, windowSize.y - 64), Position(64, 64));
    _puck = IOSprite.upperLeft(
        'puck.png',
        Position(windowSize.x / 2, windowSize.y / 2),
        Position(Pong.PUCK_SIZE, Pong.PUCK_SIZE));
    _wallLeft = IOSprite.upperLeft(
        'wallLeft.png', Position(0, 0), Position(Pong.WALL_SIZE, windowSize.y));
    _wallRight = IOSprite.upperLeft(
        'wallRight.png',
        Position(windowSize.x - Pong.WALL_SIZE, 0),
        Position(Pong.PUCK_SIZE, windowSize.y));
    _msgWin =
        IOSprite.center('win_text.png', windowSize / 2.0, Position(128, 64));
    _msgLose =
        IOSprite.center('lose_text.png', windowSize / 2.0, Position(128, 64));
    // texts
    _score = IOText();
    _score.position = windowSize / 2.0;
    _score.text = '0 - 0';
  }

  set puckPos(Position puck) {
    _puck.center = puck;
  }

  set puckSize(Position size) {
    _puck.size = size;
  }

  set playerPos(Position player) {
    _player.center = player;
  }

  set playerSize(Position size) {
    _player.size = size;
  }

  set computerPos(Position computer) {
    _computer.center = computer;
  }

  set computerSize(Position size) {
    _computer.size = size;
  }

  void setScore(int player, int computer) {
    _score.text = player.toString() + ' - ' + computer.toString();
  }

  void resize(Position size) {
    // background (only size to reset)
    _bg.size = size;
    // walls
    _wallLeft.size = Position(Pong.WALL_SIZE, size.y);
    _wallRight.position = Position(size.x - Pong.WALL_SIZE, 0);
    _wallRight.size = Position(Pong.WALL_SIZE, size.y);
    // players & computers
    _computer.position = Position(0, size.y - 64);
    // score
    _score.position = size / 2.0;
    // msgs
    _msgWin.position = size / 2.0;
    _msgLose.position = size / 2.0;
  }

  void draw(Canvas canvas) {
    // draw
    _bg.draw(canvas);
    _wallLeft.draw(canvas);
    _wallRight.draw(canvas);
    _score.draw(canvas);
    _player.draw(canvas);
    _computer.draw(canvas);
    _puck.draw(canvas);
    _msgLose.draw(canvas);
    _msgWin.draw(canvas);
  }
}
