import 'package:tp002_dart_pong/gui/iointerpolator.dart';
import 'package:tp002_dart_pong/gui/ioelement.dart';
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
  var _interpolator;

  IOAnimator([IOInterpolator i]) {
    if (i != null) {
      _interpolator = i;
    } else {
      _interpolator = IOInterpolator();
    }
  }

  set interpolator(IOInterpolator i) {
    _interpolator = i;
  }

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

  void start([double duration = 1.0]) {
    _startDate = IOTime.time;
    _endDate = _startDate + duration;
    _status = IOANIMATORSTATUS.STARTED;
    onStart(IOTime.time);
  }

  void stop() {
    if (_disappearAtEnd) {
      for (var a in _animatables) {
        a.visible = false;
      }
    }
  }

  void animate() {
    if (_status == IOANIMATORSTATUS.INIT ||
        _status == IOANIMATORSTATUS.FINISHED) {
      return;
    } else if (_status == IOANIMATORSTATUS.STARTED) {
      _status = IOANIMATORSTATUS.RUNNING;
    }
    var date = IOTime.time;
    double v = (date - _startDate) / (_endDate - _startDate);
    if (v > 1.0) {
      // end
      _status = IOANIMATORSTATUS.FINISHED;
      onEnd(date);
      if (_disappearAtEnd) {
        for (var a in _animatables) {
          a.visible = false;
        }
      }
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
  IOVisibilityAnimator([IOInterpolator i]) : super(i);

  onStart(double date) {
    for (var a in _animatables) {
      a.visible = true;
    }
  }

  onEnd(double date) {
    for (var a in _animatables) {
      a.visible = false;
    }
  }
}

class IOOpacityAnimator extends IOAnimator {
  IOOpacityAnimator([IOInterpolator i]) : super(i);

  onStart(double date) {
    for (var a in _animatables) {
      a.visible = true;
    }
  }

  void onAnimate(IOElement a, double date, double v) {
    // print('opa $v ${a.visible}');
    a.opacity = v;
  }
}
