import 'package:flutter/material.dart';
import 'package:indoor_pos_system/home_page.dart';
import 'package:network/network.dart';

import 'api/beacons/i_beacons_api.dart';

class App extends StatelessWidget {
  const App({
    required this.networkClient,
    required this.beaconsApi,
    Key? key,
  }) : super(key: key);

  final NetworkClient networkClient;
  final IBeaconsApi beaconsApi;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Отчет',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(
        title: 'Отчет',
        networkClient: networkClient,
        beaconsApi: beaconsApi,
      ),
    );
  }
}
