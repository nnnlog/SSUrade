import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

part 'app_version.g.dart';

@CopyWith()
class AppVersion extends Equatable {
  final String appVersion;
  final String newVersion;
  final String devVersion;
  final String buildNumber;

  AppVersion({
    required this.appVersion,
    required this.newVersion,
    required this.devVersion,
    required this.buildNumber,
  });

  @override
  List<Object?> get props => [appVersion, newVersion, devVersion, buildNumber];
}
