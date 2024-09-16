class GradeTable {
  GradeTable._();

  static const Map<String, int> scores = {
    'A+': 45,
    'A0': 43,
    'A-': 40,
    'B+': 35,
    'B0': 33,
    'B-': 30,
    'C+': 25,
    'C0': 23,
    'C-': 20,
    'D+': 15,
    'D0': 13,
    'D-': 10,
    'P': 5, // (magic) for list sort
    'F': 0,
  };
}
