import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flame/position.dart';

import 'package:tp002_dart_pong/ioapplication.dart';
import 'package:tp002_dart_pong/ioposition.dart';

class IOElement extends IOPosition {
  Rect rect;
  String uid;

  IOElement(this.uid, IOAnchor anchor, Position position, Position size)
      : super(anchor, position, size) {
    _setPosition(position);
  }

  bool isIn(Position pos) {
    return rect.contains(Offset(pos.x, pos.y));
  }

  set position(Position p) {
    super.position = p;
    _setPosition(p);
  }

  void _setPosition(Position p) {
    if (anchor == IOAnchor.UPPER_LEFT) {
      rect = Rect.fromLTRB(p.x, p.y, p.x + size.x, p.y + size.y);
    } else if (anchor == IOAnchor.CENTER) {
      rect = Rect.fromCenter(
          center: Offset(p.x, p.y), width: size.x, height: size.y);
    } else if (anchor == IOAnchor.LOWER_RIGHT) {
      rect = Rect.fromLTRB(p.x - size.x, p.y - size.y, p.x, p.y);
    }
  }

  void render(Canvas canvas) {}

  void update(double t) {}
}

class IOImage extends IOElement {
  Sprite _sprite;
  IORatio _align;
  bool _updated = true;

  IOImage(String uid, String filename, IOAnchor anchor, Position position,
      Position size,
      [IORatio align = IORatio.NONE])
      : _sprite = Sprite(filename),
        _align = align,
        super(uid, anchor, position, size);

  set align(IORatio a) {
    _align = a;
    _updated = true;
  }

  set height(double height) {
    _align = IORatio.VERTICAL;
    super.size.y = height;
    _updated = true;
  }

  set width(double width) {
    _align = IORatio.HORIZONTAL;
    super.size.x = width;
    _updated = true;
  }

  void render(Canvas canvas) {
    if (_sprite.loaded()) {
      Position sz = _sprite.originalSize;
      if (_updated) {
        if (_align == IORatio.HORIZONTAL) {
          var width = size.x;
          var height = width * sz.y / sz.x;
          super.size = Position(width, height);
        } else if (_align == IORatio.VERTICAL) {
          var height = size.y;
          var width = height * sz.x / sz.y;
          super.size = Position(width, height);
        }
        this.position = super.position;
        _updated = false;
        print("$uid $position $size $upperLeft");
      }
      _sprite.renderPosition(canvas, upperLeft, size: size);
    }
  }
}

class IOButton extends IOImage {
  IOButton(
    String uid,
    String filename,
    IOAnchor anchor,
    Position position,
    Position size,
  ) : super(uid, filename, anchor, position, size);
}

enum IORatio { HORIZONTAL, VERTICAL, NONE }

typedef ClickGUICB = void Function(String);
typedef ResizeGUICB = void Function(String, Position sz);

class IOGUI {
  List<IOElement> _elements = List<IOElement>();
  ClickGUICB _clickCB;
  ResizeGUICB _resizeCB;

  set clickCB(ClickGUICB cb) {
    _clickCB = cb;
  }

  set resizeCB(ResizeGUICB cb) {
    _resizeCB = cb;
  }

  void resize(Position size) {
    for (var el in _elements) {
      _resizeCB(el.uid, size);
    }
  }

  void render(Canvas canvas) {
    for (var el in _elements) {
      el.render(canvas);
    }
  }

  void update(double t) {
    for (var el in _elements) {
      el.update(t);
    }
  }

  void onEvent(IOEvent evt) {
    if (evt.type == IOEventType.DOWN) {
      for (var el in _elements) {
        if (el.isIn(evt.position)) {
          this?._clickCB(el.uid);
        }
      }
    }
  }

  // utils
  IOButton createButton(String uid, String filename, IOAnchor anchor,
      Position position, Position size) {
    var button = IOButton(uid, filename, anchor, position, size);
    _elements.add(button);
    return button;
  }

  IOImage createImage(String uid, String filename, IOAnchor anchor,
      Position pos, Position size, IORatio align) {
    var image = IOImage(uid, filename, anchor, pos, size, align);
    _elements.add(image);
    return image;
  }
}
