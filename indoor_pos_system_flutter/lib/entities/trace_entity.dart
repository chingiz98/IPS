import 'dart:math';

import 'package:flutter/material.dart';

@immutable
class TraceEntity {
  const TraceEntity({
    required this.id,
    required this.beacon_mac,
    required this.p,
    required this.time,
  });

  final int id;
  final String beacon_mac;
  final Point p;
  final DateTime time;
}
