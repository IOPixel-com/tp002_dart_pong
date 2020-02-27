import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flame/game.dart';

void main() => runApp(Starfield().widget);

class Starfield extends Game {
  Size _screenSize = Size(0,0);

  @override
  void resize(Size sz) {
    // fonction appelee quand la taille de l ecran est definie
    _screenSize = sz;
  }

  @override
  void render(Canvas canvas) {
    var points = List<Offset>(1);
    points[0] = _screenSize.center(Offset(0, 0));
    // definit les caracteristiques graphiques du point (couleur et largeur)
    Paint paint = Paint();
    paint.strokeWidth = 50;
    paint.color = Colors.grey;
    // dessine un point au centre de l ecran
    canvas.drawPoints(PointMode.points, points, paint);
  }

  @override
  void update(double t) {
    // delta en second entre deux images
    // a 60 fps (ips en fr) cela correspond a 0.0166s
    // si on a 0.032ms, on a un traitement graphique trop lourd pour une image
    print('delta time in ms between two frames: $t');
  }
}