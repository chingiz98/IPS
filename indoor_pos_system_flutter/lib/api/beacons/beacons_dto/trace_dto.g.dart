// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trace_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TraceDto _$TraceDtoFromJson(Map<String, dynamic> json) {
  return TraceDto(
    id: json['id'] as int,
    beacon_mac: json['beacon_mac'] as String,
    p: json['p'] as String,
    time: DateTime.parse(json['time'] as String),
  );
}
