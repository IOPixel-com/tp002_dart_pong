import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flame/position.dart';

import 'package:tp002_dart_pong/ioapplication.dart';
import 'package:tp002_dart_pong/gui/ioposition.dart';
import 'package:tp002_dart_pong/gui/iointerpolator.dart';
import 'package:tp002_dart_pong/iotime.dart';

enum IOANIMATORSTATUS {
  INIT,
  STARTED,
  RUNNING,
  FINISHED,
}

class IOAnimator {
  var _status = IOANIMATORSTATUS.INIT;
  var _disappearAtEnd = false;
  var _startDate = 0.0;
  var _endDate = 0.0;
  var _animatables = List<IOElement>();
  var _interpolator = IOInterpolator();

  set disappearAtEnd(bool v) {
    _disappearAtEnd = v;
  }

  void attach(IOElement a) {
    if (_animatables.indexOf(a) == -1) {
      _animatables.add(a);
    }
  }

  void detach(IOElement a) {
    // too much safe
    var index = _animatables.indexOf(a);
    while (index != -1) {
      _animatables.removeAt(index);
      index = _animatables.indexOf(a);
    }
  }

  void start(double at, [double duration = 1.0]) {
    _startDate = at;
    _endDate = _startDate + duration;
    _status = IOANIMATORSTATUS.STARTED;
    onStart(at);
  }

  void stop() {
    if (_disappearAtEnd) {
      for (var a in _animatables) {
        a.hide();
      }
    }
  }

  void animate() {
    var date = IOTime.time;
    if (_status == IOANIMATORSTATUS.INIT ||
        _status == IOANIMATORSTATUS.FINISHED) {
      return;
    } else if (_status == IOANIMATORSTATUS.STARTED) {
      _status = IOANIMATORSTATUS.RUNNING;
    }
    double v = (date - _startDate) / (_endDate - _startDate);
    if (v > 1.0) {
      // end
      _status = IOANIMATORSTATUS.FINISHED;
      onEnd(date);
    }
    v.clamp(0, 1);
    v = _interpolator.compute(v);
    for (var a in _animatables) {
      onAnimate(a, date, v);
    }
  }

  void onAnimate(IOElement a, double date, double v) {}

  onStart(double date) {}

  onEnd(double date) {}
}

class IOVisibilityAnimator extends IOAnimator {
  onStart(double date) {
    for (var a in _animatables) {
      a.show();
    }
  }

  onEnd(double date) {
    for (var a in _animatables) {
      a.hide();
    }
  }
}

class IOOpacityAnimator extends IOAnimator {}

class IOElement extends IOPosition {
  bool _visible = true;
  Rect rect;
  String uid;

  IOElement(this.uid, IOAnchor anchor, Position position, Position size)
      : super(anchor, position, size) {
    _setPosition(position);
  }

  void show() {
    _visible = true;
  }

  void hide() {
    _visible = false;
  }

  bool get visible {
    return _visible;
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

  set opacity(double v) {}

  void render(Canvas canvas) {}

  void update() {}
}

class IOImage extends IOElement {
  Sprite _sprite;
  IORatio _align;
  bool _updated = true;
  var _painter = Paint();

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

  @override
  set opacity(double v) {
    //_painter.blendMode = BlendMode.plus;
    _painter.color = Color(0xFFFFFFFF).withAlpha((255.0 * v).toInt());
  }

  void render(Canvas canvas) {
    if (_sprite.loaded() && visible) {
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
      _sprite.renderPosition(canvas, upperLeft,
          size: size, overridePaint: _painter);
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
  var _elements = List<IOElement>();
  var _animators = List<IOAnimator>();
  ClickGUICB _clickCB;
  ResizeGUICB _resizeCB;

  set clickCB(ClickGUICB cb) {
    _clickCB = cb;
  }

  set resizeCB(ResizeGUICB cb) {
    _resizeCB = cb;
  }

  void resize(Position size) {
    if (_resizeCB != null) {
      for (var el in _elements) {
        _resizeCB(el.uid, size);
      }
    }
  }

  void render(Canvas canvas) {
    for (var el in _elements) {
      el.render(canvas);
    }
  }

  void update() {
    // animate
    for (var el in _animators) {
      el.animate();
    }
    // update ioelements
    for (var el in _elements) {
      el.update();
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

  IOVisibilityAnimator createVisibilityAnimator() {
    var a = IOVisibilityAnimator();
    _animators.add(a);
    return a;
  }
}
