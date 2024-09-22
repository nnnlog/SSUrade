import 'package:ssurade_application/domain/model/chapel/chapel_manager.dart';

abstract interface class ChapelDataPort {
  ChapelManager getChapelManager();

  void setChapelManager(ChapelManager chapelManager);
}
