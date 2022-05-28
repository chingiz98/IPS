import 'package:indoor_pos_system/api/beacons/beacons_dto/dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'intersections_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class IntersectionsResponseDto {
  IntersectionsResponseDto({
    required this.intersections,
    required this.trace,
  });

  final List<IntersectionDto> intersections;
  final List<TraceDto> trace;

  factory IntersectionsResponseDto.fromJson(Map<String, dynamic> json) => _$IntersectionsResponseDtoFromJson(json);
}
