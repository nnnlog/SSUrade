import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade_adaptor/di/di.dart';
import 'package:ssurade_application/port/in/background/background_process_use_case.dart';
import 'package:ssurade_application/port/out/application/background_process_management_port.dart';
import 'package:workmanager/workmanager.dart';

final _getIt = GetIt.instance;

@pragma("vm:entry-point")
void _backgroundServiceMain() {
  Workmanager().executeTask((_, __) async {
    try {
      await configureDependencies();

      final backgroundProcessUseCase = _getIt<BackgroundProcessUseCase>();

      var futures = [
        backgroundProcessUseCase.fetchGrade(),
        backgroundProcessUseCase.fetchChapel(),
        backgroundProcessUseCase.fetchNewChapel(),
        backgroundProcessUseCase.fetchScholarship(),
        backgroundProcessUseCase.fetchAbsent(),
      ];

      await Future.wait(futures).catchError((e) => throw e);
    } catch (err, st) {
      await Sentry.init((options) {
        options.dsn = String.fromEnvironment("SENTRY_DSN");
        options.tracesSampleRate = double.tryParse(String.fromEnvironment("SENTRY_TRACES_SAMPLE_RATE")) ?? 0.0;
      });
      await Sentry.captureException(err, stackTrace: st);
      rethrow;
    }
    return true;
  });
}

@Singleton(as: BackgroundProcessManagementPort)
class BackgroundProcessManagementService implements BackgroundProcessManagementPort {
  static String get _backgroundServiceName => "ssurade.fetch";

  @FactoryMethod(preResolve: true)
  static Future<BackgroundProcessManagementService> init() async {
    await Workmanager().initialize(_backgroundServiceMain, isInDebugMode: kDebugMode);
    return BackgroundProcessManagementService();
  }

  @override
  Future<void> registerBackgroundService(int interval) async {
    await Workmanager().registerPeriodicTask(
      _backgroundServiceName,
      _backgroundServiceName,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      backoffPolicy: BackoffPolicy.linear,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      initialDelay: Duration(minutes: 15),
      frequency: Duration(minutes: interval),
    );
  }

  @override
  Future<void> unregisterBackgroundService() async {
    await Workmanager().cancelByUniqueName(_backgroundServiceName);
  }
}
