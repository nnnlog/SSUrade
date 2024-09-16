import 'dart:collection';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade_application/domain/model/chapel/chapel.dart';

part 'chapel_manager.g.dart';

@CopyWith()
@JsonSerializable(converters: [_DataConverter()])
class ChapelManager extends Equatable {
  @JsonKey()
  final SplayTreeSet<Chapel> data;

  const ChapelManager(this.data);

  factory ChapelManager.empty() => ChapelManager(SplayTreeSet());

  bool get isEmpty => data.isEmpty;

  bool get isNotEmpty => data.isNotEmpty;

  @override
  List<Object?> get props => [data];

  // JSON serialization
  factory ChapelManager.fromJson(Map<String, dynamic> json) => _$ChapelManagerFromJson(json);

  Map<String, dynamic> toJson() => _$ChapelManagerToJson(this);
}

class _DataConverter extends JsonConverter<SplayTreeSet<Chapel>, List<dynamic>> {
  const _DataConverter();

  @override
  SplayTreeSet<Chapel> fromJson(List<dynamic> json) {
    return SplayTreeSet.from(json.map((e) => Chapel.fromJson(e)));
  }

  @override
  List<dynamic> toJson(SplayTreeSet<Chapel> object) {
    return object.toList();
  }
}
