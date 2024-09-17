import 'package:injectable/injectable.dart';
import 'package:ssurade_application/port/out/application/background_process_port.dart';
import 'package:workmanager/workmanager.dart';

part 'background_chapel.dart';

@pragma("vm:entry-point")
void _backgroundServiceMain() {
  Workmanager().executeTask((_, __) async {
    try {
      var futures = [
        // _fetchGrade(),
        // fetchChapel(),
        _fetchChapel(),
        // fetchScholarship(),
        // fetchAbsent(),
      ];

      await Future.wait(futures).catchError((e) => throw e);
    } catch (err, st) {
      // Logger().e(err, stackTrace: st);
      throw Exception(err);
    }
    return true;
  });
}

@Singleton(as: BackgroundProcessPort)
class BackgroundProcessService implements BackgroundProcessPort {
  static String get _backgroundServiceName => "ssurade";

  @factoryMethod
  factory BackgroundProcessService() {
    Workmanager().initialize(_backgroundServiceMain, isInDebugMode: false);
    return BackgroundProcessService();
  }

  @override
  Future<void> registerBackgroundService() async {
    await Workmanager().registerPeriodicTask(
      _backgroundServiceName,
      _backgroundServiceName,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresDeviceIdle: false,
      ),
      backoffPolicy: BackoffPolicy.linear,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      initialDelay: Duration(minutes: 15),
    );
  }

  @override
  Future<void> unregisterBackgroundService() async {
    await Workmanager().cancelByUniqueName(_backgroundServiceName);
  }
}
