import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smart_home_app/graph.dart';

class ElectricalSwitch extends StatefulWidget {
  const ElectricalSwitch(
      {super.key,
      required this.deviceName_,
      required this.name_,
      required this.key_,
      required this.icon_,
      required this.state_});

  final String deviceName_;
  final String name_;
  final String key_;
  final IconData icon_;
  final bool state_;

  @override
  State<ElectricalSwitch> createState() => _ElectricalSwitchState();
}

class _ElectricalSwitchState extends State<ElectricalSwitch> {
  @override
  Widget build(BuildContext context) {
    final dataBaseRef = FirebaseDatabase.instance
        .ref()
        .child('Devices')
        .child(widget.deviceName_);

    return Card(
      margin: const EdgeInsets.all(5.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.4,
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon_,
              size: 50,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              widget.name_,
              style: const TextStyle(fontSize: 22),
            ),
            Switch(
              value: widget.state_,
              onChanged: (value) async {
                try {
                  await dataBaseRef.update({widget.key_: value});
                } catch (e) {
                  print('Error = $e');
                }
                setState(
                  () {
                    // widget.state_ = value;
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class MonitorScreen extends StatelessWidget {
  const MonitorScreen(
      {super.key,
      required this.lightIntensity,
      required this.peopleDetected,
      required this.temperature});

  final int? peopleDetected;
  final int? lightIntensity;
  final double? temperature;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.person,
                  color: Colors.black87,
                ),
                title: Text('$peopleDetected People'),
                subtitle: const Text('Person detected'),
              ),
              ListTile(
                leading: const Icon(
                  Icons.light_mode_outlined,
                  color: Colors.black87,
                ),
                title: Text('$lightIntensity Lux'),
                subtitle: const Text('Light Intesnsity'),
              ),
              ListTile(
                leading: const Icon(
                  Icons.thermostat,
                  color: Colors.black87,
                ),
                title: Text('$temperature \u2103'),
                subtitle: const Text('Room Temperature'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Room extends StatefulWidget {
  const Room({super.key, required this.deviceName});

  final String deviceName;

  @override
  State<Room> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Room> {
  bool lightBulb = true;
  bool fan = true;
  int? peopleDetected;
  int? lightIntensity;
  double? temperature;
  double? powerUsage;

  final _database = FirebaseDatabase.instance.ref();
  late StreamSubscription _deviceSubscription;

  @override
  void initState() {
    super.initState();
    _activeListener();
  }

  void _activeListener() async {
    _deviceSubscription =
        _database.child('Devices').child(widget.deviceName).onValue.listen(
      (event) {
        Map? device = event.snapshot.value as Map;

        setState(
          () {
            powerUsage = device['Power'] as double;
            peopleDetected = device['People'] as int;
            lightIntensity = device['Light'] as int;
            temperature = device['Temperature'] as double;
            lightBulb = device['Bulb'] as bool;
            fan = device['Fan'] as bool;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        scrolledUnderElevation: 5.0,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Center(
              child: Card(
                margin: const EdgeInsets.all(8.0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                color: Colors.grey.shade300,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(8.0),
                        child: const CircleAvatar(
                          child: Icon(
                            Icons.electric_bolt,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(2.0),
                        child: const SizedBox(
                          width: 20,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${powerUsage?.toStringAsFixed(2)} Watt",
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.black87,
                            ),
                          ),
                          const Text("Power usage today"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            MonitorScreen(
              peopleDetected: peopleDetected,
              lightIntensity: lightIntensity,
              temperature: temperature,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElectricalSwitch(
                  name_: "LightBulb",
                  icon_: Icons.lightbulb,
                  deviceName_: widget.deviceName,
                  state_: lightBulb,
                  key_: 'Bulb',
                ),
                ElectricalSwitch(
                  name_: "Fan",
                  icon_: Icons.wind_power,
                  deviceName_: widget.deviceName,
                  state_: fan,
                  key_: 'Fan',
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(88, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Graph()),
                  );
                },
                child: const Text('Graph'),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void deactivate() {
    _deviceSubscription.cancel();
    super.deactivate();
  }
}
