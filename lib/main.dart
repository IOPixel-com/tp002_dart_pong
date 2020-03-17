import 'package:flutter/material.dart';
import 'package:tp002_dart_pong/pong.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var app = PongApplication();
  runApp(Listener(
      onPointerDown: app.down,
      onPointerUp: app.up,
      onPointerMove: app.move,
      child: app.widget));
}
