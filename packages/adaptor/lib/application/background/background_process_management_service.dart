import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/di/di.dart';
import 'package:ssurade_application/port/in/background/background_process_use_case.dart';
import 'package:ssurade_application/port/out/application/background_process_management_port.dart';
import 'package:workmanager/workmanager.dart';

@pragma("vm:entry-point")
void _backgroundServiceMain() {
  Workmanager().executeTask((_, __) async {
    try {
      await configureDependencies();

      final backgroundProcessUseCase = getIt<BackgroundProcessUseCase>();

      var futures = [
        backgroundProcessUseCase.fetchGrade(),
        backgroundProcessUseCase.fetchChapel(),
        backgroundProcessUseCase.fetchNewChapel(),
        backgroundProcessUseCase.fetchScholarship(),
        backgroundProcessUseCase.fetchAbsent(),
      ];

      await Future.wait(futures).catchError((e) => throw e);
    } catch (err, st) {
      // Logger().e(err, stackTrace: st);
      throw Exception(err);
    }
    return true;
  });
}

@Singleton(as: BackgroundProcessManagementPort)
class BackgroundProcessManagementService implements BackgroundProcessManagementPort {
  static String get _backgroundServiceName => "ssurade";

  @FactoryMethod(preResolve: true)
  static Future<BackgroundProcessManagementService> init() async {
    await Workmanager().initialize(_backgroundServiceMain, isInDebugMode: false);
    return BackgroundProcessManagementService();
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