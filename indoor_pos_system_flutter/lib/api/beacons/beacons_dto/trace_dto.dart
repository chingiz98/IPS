import 'package:json_annotation/json_annotation.dart';

part 'trace_dto.g.dart';

@JsonSerializable(createToJson: false)
class TraceDto {
  TraceDto({
    required this.id,
    required this.beacon_mac,
    required this.p,
    required this.time,
  });

  final int id;
  final String beacon_mac;
  final String p;
  final DateTime time;

  factory TraceDto.fromJson(Map<String, dynamic> json) => _$TraceDtoFromJson(json);
}
