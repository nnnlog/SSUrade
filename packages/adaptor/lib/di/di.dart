import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/di/di.config.dart';
import 'package:ssurade_application/ssurade_application.dart';

final getIt = GetIt.instance;

@InjectableInit(externalPackageModulesAfter: [
  ExternalModule(SsuradeApplicationPackageModule),
])
Future configureDependencies() => getIt.init();

@InjectableInit.microPackage(externalPackageModulesAfter: [
  ExternalModule(SsuradeApplicationPackageModule),
])
initMicroPackage() {}
