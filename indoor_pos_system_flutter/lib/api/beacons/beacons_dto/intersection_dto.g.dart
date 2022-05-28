// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intersection_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntersectionDto _$IntersectionDtoFromJson(Map<String, dynamic> json) {
  return IntersectionDto(
    distance: (json['distance'] as num).toDouble(),
    id1: json['id1'] as int,
    id2: json['id2'] as int,
    mac1: json['mac1'] as String,
    mac2: json['mac2'] as String,
    p1: json['p1'] as String,
    p2: json['p2'] as String,
    time1: DateTime.parse(json['time1'] as String),
    time2: DateTime.parse(json['time2'] as String),
  );
}
