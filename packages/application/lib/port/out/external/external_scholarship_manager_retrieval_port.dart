import 'package:ssurade_application/domain/model/job/job.dart';
import 'package:ssurade_application/domain/model/scholarship/scholarship_manager.dart';

abstract interface class ExternalScholarshipManagerRetrievalPort {
  Job<ScholarshipManager?> retrieveScholarshipManager();
}
