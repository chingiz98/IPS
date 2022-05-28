import 'package:indoor_pos_system/api/beacons/beacons_dto/dto.dart';

abstract class BeaconsMapper {
  static List<String> mapDtoToEntity(List<BeaconMacDto> dtos) {
    return dtos.map((beacon) => beacon.beacon_mac).toList();
  }
}
