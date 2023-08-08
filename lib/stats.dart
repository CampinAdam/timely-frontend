import 'dart:developer';

import 'package:date_time_format/date_time_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:staggered_grid_view_flutter/rendering/sliver_staggered_grid.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import 'package:timely/agenda.dart';
import 'package:timely/event_models/EventModel.dart';
import 'package:styled_widget/styled_widget.dart';

import 'controllers/account_controller.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'agenda.dart';

class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  State<Stats> createState() => _StatsState();
}

Future<String> getUserArrivalData() async {
  FirebaseAuth auth = FirebaseAuth.instance;
  final response = await Client().get(
    Uri.parse(
        'http://dursteler.me:8000/api/get_arrival_data_by_user_id/${auth.currentUser!.uid}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  return response.body;
}

class _StatsState extends State<Stats> {
  List<EventModel> events = AccountController().getAllEvents();
  FirebaseAuth auth = FirebaseAuth.instance;
  late List<String> arrivalData;
  @override
  void initState() {
    super.initState();
    arrivalData = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
        automaticallyImplyLeading: true,
      ),
      body: FutureBuilder<String>(
        future: getUserArrivalData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            log('The arrival data is ${snapshot.data}');
            arrivalData = snapshot.data!.split(',');
            return StaggeredGridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              staggeredTiles: const [
                StaggeredTile.extent(2, 220.0),
                StaggeredTile.extent(2, 220.0),
                StaggeredTile.extent(2, 220.0),
                StaggeredTile.extent(2, 220.0),
                StaggeredTile.extent(4, 220.0),
                StaggeredTile.extent(4, 220.0),
              ],
              children: [
                Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  color: Colors.blue,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Total Events',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          events.length.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40.0,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  color: Colors.green,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Total Events Attended',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          arrivalData.length.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40.0,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  color: Colors.red,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Total Events Missed',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          (events.length - arrivalData.length).toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40.0,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 8.0,
                  shadowColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  color: Colors.orange,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Attendance Percentage',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          '${((arrivalData.length / events.length) * 100).toStringAsFixed(2)}%',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40.0,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: 10,
                    minY: 0,
                    maxY: 10,
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          const FlSpot(0, 0),
                          const FlSpot(1, 1),
                          const FlSpot(2, 2),
                          const FlSpot(3, 3),
                          const FlSpot(4, 4),
                          const FlSpot(5, 5),
                          const FlSpot(6, 6),
                          const FlSpot(7, 7),
                          const FlSpot(8, 8),
                          const FlSpot(9, 9),
                          const FlSpot(10, 10),
                        ],
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 5,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: false,
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('no data yet'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
