import 'package:flutter/material.dart';
import 'package:indoor_pos_system/entities/entities.dart';

@immutable
class IntersectionsResponseEntity {
  const IntersectionsResponseEntity({
    required this.intersections,
    required this.trace,
  });

  final List<IntersectionEntity> intersections;
  final List<TraceEntity> trace;
}
