import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'credential_cache.g.dart';

@CopyWith()
@JsonSerializable()
class CredentialCache extends Equatable {
  final List<Map<String, dynamic>> cookies;
  final DateTime expire;

  const CredentialCache({
    required this.cookies,
    required this.expire,
  });

  factory CredentialCache.fromJson(Map<String, dynamic> json) => _$CredentialCacheFromJson(json);

  Map<String, dynamic> toJson() => _$CredentialCacheToJson(this);

  @override
  List<Object?> get props => [cookies, expire];
}
