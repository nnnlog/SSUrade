// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential_cache.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CredentialCache _$CredentialCacheFromJson(Map<String, dynamic> json) => CredentialCache(
      cookies: (json['cookies'] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList(),
      expire: json['expire'] == null ? null : DateTime.parse(json['expire'] as String),
    );

Map<String, dynamic> _$CredentialCacheToJson(CredentialCache instance) => <String, dynamic>{
      'cookies': instance.cookies,
      'expire': instance.expire?.toIso8601String(),
    };
