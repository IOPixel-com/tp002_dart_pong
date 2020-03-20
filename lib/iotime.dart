class IOTime {
  static double _time = 0;
  static double _delta = 0;

  static get time {
    return _time;
  }

  static get delta {
    return _delta;
  }

  static void setTime(double t) {
    _time = t;
  }

  static void incTime(double t) {
    _delta = t;
    _time += t;
  }
}
