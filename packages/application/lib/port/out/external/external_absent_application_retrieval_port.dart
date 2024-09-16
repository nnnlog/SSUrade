import 'package:ssurade_application/domain/model/absent_application/absent_application_manager.dart';
import 'package:ssurade_application/domain/model/job/job.dart';

abstract interface class ExternalAbsentApplicationRetrievalPort {
  Job<AbsentApplicationManager> retrieveAbsentManager();
}
