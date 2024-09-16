import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

part 'credential.g.dart';

@CopyWith()
class Credential extends Equatable {
  final String id;
  final String password;
  final List<dynamic> cookies;

  const Credential({
    required this.id,
    required this.password,
    required this.cookies,
  });

  @override
  List<Object?> get props => [id, password, cookies];

  factory Credential.empty() => Credential(id: "", password: "", cookies: []);
}
