import 'package:ssurade_application/domain/model/chapel/chapel_manager.dart';

abstract interface class LocalStorageChapelManagerSavePort {
  Future<void> saveChapelManager(ChapelManager chapelManager);
}
