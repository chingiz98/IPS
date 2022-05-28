import 'package:flutter/widgets.dart';

import 'entities/entities.dart';

class IntersectionsModel extends ChangeNotifier {
  List<String> _beaconMacs = [];
  IntersectionsResponseEntity? _intersections;
  String? _selectedMac;
  double _interval = 360.0;
  double _distance = 80.0;

  void setBeaconMacs(macs) {
    _beaconMacs = macs;
    notifyListeners();
  }

  void setIntersections(intersections) {
    _intersections = intersections;
    notifyListeners();
  }

  void setSelectedMac(mac) {
    _selectedMac = mac;
    notifyListeners();
  }

  void setInterval(value) {
    _interval = value;
    notifyListeners();
  }

  void setDistance(value) {
    _distance = value;
    notifyListeners();
  }

  List<String> get beaconMacs => _beaconMacs;

  IntersectionsResponseEntity? get intersections => _intersections;

  String? get selectedMac => _selectedMac;

  double get interval => _interval;

  double get distance => _distance;
}