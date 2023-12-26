/// TODO: I will replace below logic with binary search for precision.
String toStringWithPrecision(double value, int precision) {
  String str = value.toStringAsFixed(precision);
  return double.parse(str).toStringAsPrecision(value.toInt().toString().length + precision);
}
