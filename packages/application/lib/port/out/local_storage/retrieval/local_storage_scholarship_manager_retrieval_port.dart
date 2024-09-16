import 'package:ssurade_application/domain/model/scholarship/scholarship_manager.dart';

abstract interface class LocalStorageScholarshipManagerRetrievalPort {
  Future<ScholarshipManager?> retrieveScholarshipManager();
}
