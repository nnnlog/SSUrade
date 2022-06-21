import 'package:fluttertoast/fluttertoast.dart';

showToast(String message) {
  Fluttertoast.showToast(msg: message);
}

cancelToast() {
  Fluttertoast.cancel();
}
