import 'package:flutter/material.dart';
import 'package:indoor_pos_system/api/beacons/beacons_api.dart';
import 'package:indoor_pos_system/app.dart';
import 'package:network/network.dart';

void main() {
  final monolithClient = NetworkClient.api('https://functions.yandexcloud.net');
  final beaconsApi = BeaconsApi(httpProvider: monolithClient);

  runApp(App(
    networkClient: monolithClient,
    beaconsApi: beaconsApi,
  ));
}
