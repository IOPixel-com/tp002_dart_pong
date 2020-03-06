import 'package:flutter/material.dart';
import 'package:tp002_dart_pong/pong.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Pong().widget);
}
