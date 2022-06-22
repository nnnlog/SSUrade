import 'package:flutter/material.dart';

class GradeLogo extends StatefulWidget {
  final String bigText, smallText;
  final Color backgroundColor, textColor;

  const GradeLogo({Key? key, this.bigText = "", this.smallText = "", required this.backgroundColor, required this.textColor}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GradeLogoState(bigText, smallText, backgroundColor, textColor);

  static const GradeLogo pass = GradeLogo(
    backgroundColor: Color.fromRGBO(209, 255, 187, 1),
    textColor: Color.fromRGBO(101, 160, 74, 1),
    smallText: "PASS",
  );
  static const GradeLogo fail = GradeLogo(
    backgroundColor: Color.fromRGBO(217, 217, 217, 1),
    textColor: Color.fromRGBO(111, 111, 111, 1),
    bigText: "F",
  );

  static var A = (String detail) => GradeLogo(
        backgroundColor: const Color.fromRGBO(187, 238, 255, 1),
        textColor: const Color.fromRGBO(9, 144, 189, 1),
        bigText: "A",
        smallText: detail,
      );
  static var B = (String detail) => GradeLogo(
        backgroundColor: const Color.fromRGBO(255, 244, 176, 1),
        textColor: const Color.fromRGBO(188, 140, 17, 1),
        bigText: "B",
        smallText: detail,
      );
  static var C = (String detail) => GradeLogo(
        backgroundColor: const Color.fromRGBO(255, 192, 192, 1),
        textColor: const Color.fromRGBO(195, 76, 76, 1),
        bigText: "B",
        smallText: detail,
      );
  static var D = (String detail) => GradeLogo(
        backgroundColor: const Color.fromRGBO(217, 217, 217, 1),
        textColor: const Color.fromRGBO(111, 111, 111, 1),
        bigText: "D",
        smallText: detail,
      );

  static var unknown = const GradeLogo(
    backgroundColor: Color.fromRGBO(217, 217, 217, 1),
    textColor: Color.fromRGBO(111, 111, 111, 1),
    bigText: "?",
  );

  static GradeLogo Function(String) parse = (String grade) {
    if (grade == "P") return pass;
    if (grade == "F") return fail;
    if (grade.length != 2) return unknown;
    if (grade.startsWith("A")) return A(grade.substring(1, 2));
    if (grade.startsWith("B")) return B(grade.substring(1, 2));
    if (grade.startsWith("C")) return C(grade.substring(1, 2));
    if (grade.startsWith("D")) return D(grade.substring(1, 2));
    return unknown;
  };
}

class _GradeLogoState extends State<GradeLogo> {
  final String bigText, smallText;
  final Color backgroundColor, textColor;

  _GradeLogoState(this.bigText, this.smallText, this.backgroundColor, this.textColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: backgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            bigText,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 25,
            ),
          ),
          Text(
            smallText,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
