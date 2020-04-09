import 'dart:ui';

import 'package:tp002_dart_pong/gfx/index.dart';
import 'package:tp002_dart_pong/scene/index.dart';

class IOSceneNode extends IONode {
  IOScene scene;

  IOSceneNode(this.scene, IONode parent, String uid, IOAnchor anchor, Rect rect)
      : super(parent, uid, anchor, rect);
}
