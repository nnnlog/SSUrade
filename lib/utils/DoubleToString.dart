/// https://stackoverflow.com/questions/62989638/convert-long-double-to-string-without-scientific-notation-dart
String _toExact(double value) {
  var sign = "";
  if (value < 0) {
    value = -value;
    sign = "-";
  }
  var string = value.toString();
  var e = string.lastIndexOf('e');
  if (e < 0) return "$sign$string";
  assert(string.indexOf('.') == 1);
  var offset = int.parse(string.substring(e + (string.startsWith('-', e + 1) ? 1 : 2)));
  var digits = string.substring(0, 1) + string.substring(2, e);
  if (offset < 0) {
    return "${sign}0.${"0" * ~offset}$digits";
  }
  if (offset > 0) {
    if (offset >= digits.length) return sign + digits.padRight(offset + 1, "0");
    return "$sign${digits.substring(0, offset + 1)}"
        ".${digits.substring(offset + 1)}";
  }
  return digits;
}

String toStringWithPrecision(double value, int precision) {
  String ret = _toExact(value);
  var offset = ret.lastIndexOf(".");
  if (offset < 0) {
    ret += ".";
    while (precision-- > 0) {
      ret += "0";
    }
  } else {
    int cnt = ret.length - offset - 1;
    int diff = precision - cnt;
    if (diff > 0) {
      while (diff-- > 0) {
        ret += "0";
      }
    } else if (diff < 0) {
      while (diff++ < 0) {
        ret = ret.substring(0, ret.length - 1);
      }
    }
  }
  return ret;
}
