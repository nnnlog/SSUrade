String toStringWithPrecision(double value, int precision) {
  String str = value.toStringAsFixed(precision);
  return double.parse(str).toStringAsPrecision(value.toInt().toString().length + precision);
}
