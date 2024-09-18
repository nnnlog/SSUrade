import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/di/di.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future configureDependencies() => getIt.init();

@InjectableInit.microPackage()
initMicroPackage() {}
