// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intersections_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntersectionsResponseDto _$IntersectionsResponseDtoFromJson(
    Map<String, dynamic> json) {
  return IntersectionsResponseDto(
    intersections: (json['intersections'] as List<dynamic>)
        .map((e) => IntersectionDto.fromJson(e as Map<String, dynamic>))
        .toList(),
    trace: (json['trace'] as List<dynamic>)
        .map((e) => TraceDto.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
