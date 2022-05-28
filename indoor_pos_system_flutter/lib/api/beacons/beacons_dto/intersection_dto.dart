import 'package:json_annotation/json_annotation.dart';

part 'intersection_dto.g.dart';

@JsonSerializable(createToJson: false)
class IntersectionDto {
  IntersectionDto({
    required this.distance,
    required this.id1,
    required this.id2,
    required this.mac1,
    required this.mac2,
    required this.p1,
    required this.p2,
    required this.time1,
    required this.time2,
  });

  final double distance;
  final int id1;
  final int id2;
  final String mac1;
  final String mac2;
  final String p1;
  final String p2;
  final DateTime time1;
  final DateTime time2;

  factory IntersectionDto.fromJson(Map<String, dynamic> json) =>
      _$IntersectionDtoFromJson(json);
}
