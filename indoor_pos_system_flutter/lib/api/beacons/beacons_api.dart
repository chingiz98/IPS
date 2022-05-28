import 'package:indoor_pos_system/api/beacons/beacon_mappers/mappers.dart';
import 'package:indoor_pos_system/api/beacons/beacons_dto/dto.dart';
import 'package:indoor_pos_system/api/beacons/beacons_dto/intersections_response_dto.dart';
import 'package:indoor_pos_system/entities/entities.dart';
import 'package:network/network.dart';
import '../urls.dart';
import 'i_beacons_api.dart';
import 'dart:convert';

class BeaconsApi implements IBeaconsApi {
  BeaconsApi({
    required this.httpProvider,
  });

  final NetworkClient httpProvider;

  @override
  Future<List<String>> getBeaconsList() async {
    final request = Request(httpProvider, url: Urls.beaconsList);
    final response = (await request.make()).data;

    final beaconsDto = jsonDecode(response).map<BeaconMacDto>((j) => BeaconMacDto.fromJson(j)).toList();

    return BeaconsMapper.mapDtoToEntity(beaconsDto);
  }

  @override
  Future<IntersectionsResponseEntity> getIntersections({
    required String mac,
    required double interval,
    required double distance,
  }) async {
    final request = Request(
      httpProvider,
      url: Urls.beaconsIntersections,
      queryParameters: {
        'mac': mac,
        'interval': interval,
        'distance': distance,
      },
    );
    final response = (await request.make()).data;

    final intersectionsDto = IntersectionsResponseDto.fromJson(jsonDecode(response));

    return IntersectionsMapper.mapDtoToEntity(intersectionsDto, mac);
  }
}
