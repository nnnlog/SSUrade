import 'package:fluttertoast/fluttertoast.dart';
import 'package:ssurade_application/port/out/application/toast_port.dart';

class ToastService implements ToastPort {
  @override
  void showToast(String message) {
    Fluttertoast.showToast(msg: message);
  }
}
