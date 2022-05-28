import 'package:indoor_pos_system/entities/entities.dart';

abstract class IBeaconsApi {
  Future<List<String>> getBeaconsList();

  Future<IntersectionsResponseEntity> getIntersections({
    required String mac,
    required double interval,
    required double distance,
  });
}
