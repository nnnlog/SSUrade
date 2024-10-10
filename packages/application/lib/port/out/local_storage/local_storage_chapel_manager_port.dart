import 'package:ssurade_application/domain/model/chapel/chapel_manager.dart';

abstract interface class LocalStorageChapelManagerPort {
  Future<ChapelManager?> retrieveChapelManager();

  Future<void> saveChapelManager(ChapelManager chapelManager);
}
