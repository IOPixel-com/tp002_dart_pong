enum IOAlign { NONE, CENTER, LEFT, RIGHT }

enum IOVAlign { NONE, TOP, BOTTOM, CENTER }

enum IOScaling { NONE, W, H, WH, MAX_WH }

class IOAnchor {
  IOAlign align;
  IOVAlign valign;
  IOScaling scaling;

  IOAnchor() {
    this.align = IOAlign.CENTER;
    this.valign = IOVAlign.CENTER;
    this.scaling = IOScaling.NONE;
  }

  IOAnchor.fromText(String align, String valign, String scaling) {
    // align
    if (align == 'center') {
      this.align = IOAlign.CENTER;
    } else if (align == 'left') {
      this.align = IOAlign.LEFT;
    } else if (align == 'right') {
      this.align = IOAlign.RIGHT;
    } else {
      this.align = IOAlign.NONE;
    }
    // valign
    if (valign == 'center') {
      this.valign = IOVAlign.CENTER;
    } else if (valign == 'top') {
      this.valign = IOVAlign.TOP;
    } else if (valign == 'bottom') {
      this.valign = IOVAlign.BOTTOM;
    } else {
      this.valign = IOVAlign.NONE;
    }
    // scaling
    if (scaling == 'w') {
      this.scaling = IOScaling.W;
    } else if (scaling == 'h') {
      this.scaling = IOScaling.H;
    } else if (scaling == 'wh') {
      this.scaling = IOScaling.WH;
    } else if (scaling == 'max_wh') {
      this.scaling = IOScaling.MAX_WH;
    } else if (scaling == 'none') {
      this.scaling = IOScaling.NONE;
    } else {
      print('warning scaling: $scaling');
      this.scaling = IOScaling.NONE;
    }
  }
}
