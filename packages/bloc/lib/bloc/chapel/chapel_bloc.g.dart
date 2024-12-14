// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapel_bloc.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChapelShowingCWProxy {
  ChapelShowing chapelManager(ChapelManager chapelManager);

  ChapelShowing showingYearSemester(YearSemester showingYearSemester);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChapelShowing(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChapelShowing(...).copyWith(id: 12, name: "My name")
  /// ````
  ChapelShowing call({
    ChapelManager chapelManager,
    YearSemester showingYearSemester,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChapelShowing.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChapelShowing.copyWith.fieldName(...)`
class _$ChapelShowingCWProxyImpl implements _$ChapelShowingCWProxy {
  const _$ChapelShowingCWProxyImpl(this._value);

  final ChapelShowing _value;

  @override
  ChapelShowing chapelManager(ChapelManager chapelManager) => this(chapelManager: chapelManager);

  @override
  ChapelShowing showingYearSemester(YearSemester showingYearSemester) => this(showingYearSemester: showingYearSemester);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChapelShowing(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChapelShowing(...).copyWith(id: 12, name: "My name")
  /// ````
  ChapelShowing call({
    Object? chapelManager = const $CopyWithPlaceholder(),
    Object? showingYearSemester = const $CopyWithPlaceholder(),
  }) {
    return ChapelShowing(
      chapelManager: chapelManager == const $CopyWithPlaceholder()
          ? _value.chapelManager
          // ignore: cast_nullable_to_non_nullable
          : chapelManager as ChapelManager,
      showingYearSemester: showingYearSemester == const $CopyWithPlaceholder()
          ? _value.showingYearSemester
          // ignore: cast_nullable_to_non_nullable
          : showingYearSemester as YearSemester,
    );
  }
}

extension $ChapelShowingCopyWith on ChapelShowing {
  /// Returns a callable class that can be used as follows: `instanceOfChapelShowing.copyWith(...)` or like so:`instanceOfChapelShowing.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChapelShowingCWProxy get copyWith => _$ChapelShowingCWProxyImpl(this);
}
