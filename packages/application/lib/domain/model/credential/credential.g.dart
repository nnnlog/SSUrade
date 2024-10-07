// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CredentialCWProxy {
  Credential id(String id);

  Credential password(String password);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Credential(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Credential(...).copyWith(id: 12, name: "My name")
  /// ````
  Credential call({
    String? id,
    String? password,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCredential.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCredential.copyWith.fieldName(...)`
class _$CredentialCWProxyImpl implements _$CredentialCWProxy {
  const _$CredentialCWProxyImpl(this._value);

  final Credential _value;

  @override
  Credential id(String id) => this(id: id);

  @override
  Credential password(String password) => this(password: password);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Credential(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Credential(...).copyWith(id: 12, name: "My name")
  /// ````
  Credential call({
    Object? id = const $CopyWithPlaceholder(),
    Object? password = const $CopyWithPlaceholder(),
  }) {
    return Credential(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      password: password == const $CopyWithPlaceholder() || password == null
          ? _value.password
          // ignore: cast_nullable_to_non_nullable
          : password as String,
    );
  }
}

extension $CredentialCopyWith on Credential {
  /// Returns a callable class that can be used as follows: `instanceOfCredential.copyWith(...)` or like so:`instanceOfCredential.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CredentialCWProxy get copyWith => _$CredentialCWProxyImpl(this);
}
