import 'package:flame/position.dart';

enum IOAnchor { UPPER_LEFT, CENTER, LOWER_RIGHT }

class IOPosition {
  IOAnchor anchor = IOAnchor.CENTER;
  Position position;
  Position size;

  IOPosition(this.anchor, this.position, this.size);

  Position get upperLeft {
    if (anchor == IOAnchor.UPPER_LEFT) {
      return position;
    } else if (anchor == IOAnchor.CENTER) {
      return position - size / 2.0;
    } else if (anchor == IOAnchor.LOWER_RIGHT) {
      return position - size;
    }
    return Position(0, 0);
  }
}
