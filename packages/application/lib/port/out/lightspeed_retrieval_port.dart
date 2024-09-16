import 'package:ssurade_application/ssurade_application.dart';

abstract interface class LightspeedRetrievalPort {
  Future<Lightspeed> retrieveLightspeed(String version);
}
