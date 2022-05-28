import 'dart:math';

import 'package:flutter/material.dart';

@immutable
class IntersectionEntity {
  const IntersectionEntity({
    required this.distance,
    required this.id,
    required this.mac,
    required this.p,
    required this.time,
  });

  final double distance;
  final int id;
  final String mac;
  final Point p;
  final DateTime time;
}
