import 'dart:async';

import 'package:change_notifier_builder/change_notifier_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indoor_pos_system/entities/entities.dart';
import 'package:network/network.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import 'api/beacons/i_beacons_api.dart';

import 'package:collection/collection.dart';

import 'intersections_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.title,
    required this.networkClient,
    required this.beaconsApi,
  }) : super(key: key);

  final NetworkClient networkClient;
  final IBeaconsApi beaconsApi;

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _intervalDebounceTimer;
  Timer? _distanceDebounceTimer;

  final model = IntersectionsModel();

  final _textStyle = TextStyle(color: Colors.white);

  @override
  void initState() {
    super.initState();

    try {
      widget.beaconsApi.getBeaconsList().then((beaconMacs) {
        print(beaconMacs.toString());
        model.setBeaconMacs(beaconMacs);
        model.setSelectedMac(beaconMacs.firstOrNull);
        _loadIntersections();
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void _loadIntersections() {
    if (model.selectedMac != null) {
      try {
        widget.beaconsApi
            .getIntersections(mac: model.selectedMac!, interval: model.interval, distance: model.distance)
            .then((intersections) {
          model.setIntersections(intersections);
        });
      } catch (e) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SafeArea(
          bottom: true,
          child: ChangeNotifierBuilder(
            notifier: model,
            builder: (BuildContext context, IntersectionsModel? mod, _) {
              final List<List<IntersectionEntity>> serieses = [];
              final dataSrc = mod?.intersections != null ? mod!.intersections!.intersections : <IntersectionEntity>[];

              for (var beaconMac in mod?.beaconMacs ?? []) {
                serieses.add(dataSrc.where((intersec) => intersec.mac == beaconMac).toList());
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: SfCartesianChart(
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                        builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                          if (data is IntersectionEntity) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MAC-address: ${data.mac}',
                                  style: _textStyle,
                                ),
                                Text(
                                  'X: ${data.p.x} Y: ${data.p.y}',
                                  style: _textStyle,
                                ),
                                Text(
                                  'Distance: ${data.distance.toStringAsFixed(3)}',
                                  style: _textStyle,
                                ),
                                Text(
                                  'Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(data.time)}',
                                  style: _textStyle,
                                ),
                              ],
                            );
                          }

                          if (data is TraceEntity) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MAC-address: ${data.beacon_mac}',
                                  style: _textStyle,
                                ),
                                Text(
                                  'X: ${data.p.x} Y: ${data.p.y}',
                                  style: _textStyle,
                                ),
                                Text(
                                  'Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(data.time)}',
                                  style: _textStyle,
                                ),
                              ],
                            );
                          }

                          return const SizedBox();
                        },
                      ),
                      zoomPanBehavior: ZoomPanBehavior(
                        enablePinching: true,
                        enableMouseWheelZooming: true,
                        enablePanning: true,
                      ),
                      primaryXAxis: NumericAxis(minimum: 0, maximum: 500),
                      primaryYAxis: NumericAxis(minimum: 0, maximum: 500),
                      series: <ChartSeries>[
                        ...serieses.map((series) {
                          return ScatterSeries<IntersectionEntity, num>(
                            enableTooltip: true,
                            dataSource: series,
                            xValueMapper: (IntersectionEntity data, _) => data.p.x,
                            yValueMapper: (IntersectionEntity data, _) => data.p.y,
                          );
                        }),
                        LineSeries<TraceEntity, num>(
                          animationDelay: 0,
                          animationDuration: 0,
                          dataSource: mod?.intersections != null ? mod!.intersections!.trace : [],
                          xValueMapper: (TraceEntity data, _) => data.p.x,
                          yValueMapper: (TraceEntity data, _) => data.p.y,
                          markerSettings: const MarkerSettings(isVisible: true),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Text('Select beacon mac:'),
                          DropdownButton(
                            items:
                                mod?.beaconMacs.map((mac) => DropdownMenuItem(child: Text(mac), value: mac)).toList(),
                            value: mod?.selectedMac,
                            onChanged: (String? mac) {
                              mod?.setSelectedMac.call(mac);
                              _loadIntersections();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(width: 25),
                      Column(
                        children: [
                          const Text('Interval:'),
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                              ],
                              initialValue: ((mod?.interval) ?? '').toString(),
                              onChanged: (interval) {
                                if (_intervalDebounceTimer?.isActive ?? false) _intervalDebounceTimer?.cancel();
                                _intervalDebounceTimer = Timer(
                                  const Duration(milliseconds: 500),
                                  () {
                                    final value = double.tryParse(interval);
                                    if (value != null) {
                                      mod?.setInterval(value);
                                      _loadIntersections();
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 25),
                      Column(
                        children: [
                          const Text('Distance:'),
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                              ],
                              initialValue: ((mod?.distance) ?? '').toString(),
                              onChanged: (distance) => _debounceTextFiled(
                                timer: _distanceDebounceTimer,
                                value: distance,
                                onValueParsed: (distance) {
                                  mod?.setDistance.call(distance);
                                  _loadIntersections();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _debounceTextFiled({
    required Timer? timer,
    required String value,
    required ValueChanged<double> onValueParsed,
  }) {
    if (timer?.isActive ?? false) timer?.cancel();
    timer = Timer(
      const Duration(milliseconds: 500),
      () {
        final parsedNumber = double.tryParse(value);
        if (parsedNumber != null) {
          onValueParsed(parsedNumber);
        } else {}
      },
    );
  }
}
