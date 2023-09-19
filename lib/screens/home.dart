import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm_example/screens/edit_alarm.dart';
import 'package:alarm_example/screens/ring.dart';
import 'package:alarm_example/widgets/tile.dart';
import 'package:flutter/material.dart';

class ExampleAlarmHomeScreen extends StatefulWidget {
  const ExampleAlarmHomeScreen({Key? key}) : super(key: key);

  @override
  State<ExampleAlarmHomeScreen> createState() => _ExampleAlarmHomeScreenState();
}

class _ExampleAlarmHomeScreenState extends State<ExampleAlarmHomeScreen> {
  late List<AlarmSettings> alarms;

  static StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    loadAlarms();
    subscription ??= Alarm.ringStream.stream.listen(
      (alarmSettings) => navigateToRingScreen(alarmSettings),
    );
  }

  void loadAlarms() {
    setState(() {
      alarms = Alarm.getAlarms();
      alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    });
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ExampleAlarmRingScreen(alarmSettings: alarmSettings),
        ));
    loadAlarms();
  }

  Future<void> navigateToAlarmScreen(AlarmSettings? settings) async {
    final res = await showModalBottomSheet<bool?>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.7,
            child: ExampleAlarmEditScreen(alarmSettings: settings),
          );
        });

    if (res != null && res == true) loadAlarms();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Askari Alarms'),
        backgroundColor: Colors.indigo, // Improved app bar color
      ),
      body: SafeArea(
        child: alarms.isNotEmpty
            ? ListView.separated(
                itemCount: alarms.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.grey),
                itemBuilder: (context, index) {
                  final alarm = alarms[index];
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white, // Alarm tile background color
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 3), // Shadow
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        TimeOfDay.fromDateTime(alarm.dateTime).format(context),
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onTap: () => navigateToAlarmScreen(alarm),
                      trailing: IconButton(
                        icon: Icon(Icons.delete,
                            color: Colors.red), // Red delete icon
                        onPressed: () {
                          Alarm.stop(alarm.id).then((_) => loadAlarms());
                        },
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  "No alarms set",
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
              ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              onPressed: () {
                final alarmSettings = AlarmSettings(
                  id: 42,
                  dateTime: DateTime.now(),
                  assetAudioPath:
                      'assets/Azaan E Fajr - Full Audio  Aqeel Khan  Amjad Nadeem  Islamic Songs 2022.mp3',
                  volumeMax: false,
                );
                Alarm.set(alarmSettings: alarmSettings);
              },
              backgroundColor: Colors.indigo, // Improved FAB color
              heroTag: null,
              child: Icon(Icons.play_arrow, size: 32), // Play icon
            ),
            FloatingActionButton(
              onPressed: () => navigateToAlarmScreen(null),
              backgroundColor: Colors.indigo, // Improved FAB color
              child: Icon(Icons.add, size: 32), // Plus icon
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
