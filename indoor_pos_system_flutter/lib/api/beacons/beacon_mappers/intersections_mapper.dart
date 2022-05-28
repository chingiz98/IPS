import 'dart:math';

import 'package:indoor_pos_system/api/beacons/beacons_dto/dto.dart';
import 'package:indoor_pos_system/entities/entities.dart';

abstract class IntersectionsMapper {
  static IntersectionsResponseEntity mapDtoToEntity(IntersectionsResponseDto dto, String mac) {
    final List<IntersectionEntity> intersections = dto.intersections.map((intersection) {
      final p1Array = intersection.p1.replaceAll('POINT(', '').replaceAll(')', '').split(' ');
      final p2Array = intersection.p2.replaceAll('POINT(', '').replaceAll(')', '').split(' ');

      return IntersectionEntity(
        distance: intersection.distance,
        id: intersection.mac1 == mac ? intersection.id2 : intersection.id1,
        mac: intersection.mac1 == mac ? intersection.mac2 : intersection.mac1,
        p: intersection.mac1 == mac
            ? Point(int.parse(p2Array.first), int.parse(p2Array.last))
            : Point(int.parse(p1Array.first), int.parse(p1Array.last)),
        time: intersection.mac1 == mac ? intersection.time2 : intersection.time1,
      );
    }).toList();

    final List<TraceEntity> trace = dto.trace.map((tracePoint) {
      final point = tracePoint.p.replaceAll('POINT(', '').replaceAll(')', '').split(' ');

      return TraceEntity(
        id: tracePoint.id,
        beacon_mac: tracePoint.beacon_mac,
        p: Point(int.parse(point.first), int.parse(point.last)),
        time: tracePoint.time,
      );
    }).toList();

    return IntersectionsResponseEntity(
      intersections: intersections,
      trace: trace,
    );
  }
}
