import 'package:json_annotation/json_annotation.dart';

part 'beacon_mac_dto.g.dart';

@JsonSerializable(createToJson: false)
class BeaconMacDto {
  BeaconMacDto({
    required this.beacon_mac,
  });

  final String beacon_mac;

  factory BeaconMacDto.fromJson(Map<String, dynamic> json) =>
      _$BeaconMacDtoFromJson(json);
}
