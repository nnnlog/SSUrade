class Ranking {
  int my, total;

  Ranking(this.my, this.total);

  double get percentage {
    return my / total * 100;
  }

  bool get isEmpty => my == 0 || total == 0;

  bool get isNotEmpty => !isEmpty;

  String toKey() => isEmpty ? "-" : "$my/$total";

  static Ranking fromKey(String str) {
    if (str == "-") {
      return Ranking(0, 0);
    }
    var a = str.split("/").map((e) => int.parse(e)).toList();
    return Ranking(a[0], a[1]);
  }

  @override
  String toString() => toKey();
}
