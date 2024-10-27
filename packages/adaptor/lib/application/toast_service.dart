import 'package:fluttertoast/fluttertoast.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_application/port/out/application/toast_port.dart';

@Singleton(as: ToastPort)
class ToastService implements ToastPort {
  @override
  Future<void> showToast(String message) async {
    await Fluttertoast.showToast(msg: message);
  }
}
