import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:smart_home_app/room.dart';

import 'package:firebase_database/firebase_database.dart';

/// An example of the filled card type.
///
/// To make a [Card] match the filled type, the default elevation and color
/// need to be changed to the values from the spec:
///
/// https://m3.material.io/components/cards/specs#0f55bf62-edf2-4619-b00d-b9ed462f2c5a
class FilledCardExample extends StatelessWidget {
  final String cardText;

  const FilledCardExample({super.key, required this.cardText});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Room(deviceName: cardText)),
        );
      },
      child: Center(
        child: Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: SizedBox(
            width: 300,
            height: 100,
            child: Center(child: Text(cardText)),
          ),
        ),
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String _displayText = "Empty String";
  final _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _activeListener();
  }

  void _activeListener() {
    _database.child('Devices').onValue.listen(
      (event) {
        // final data = new Map<String, dynamic>.from(event.snapshot.value);
        // final description = data['description'] as String;
        setState(
          () {
            final String string = event.snapshot.value.toString();
            _displayText = 'text = $string';
          },
        );
      },
    );
  }

  Query dbRef = FirebaseDatabase.instance.ref().child('Devices');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: FirebaseAnimatedList(
                query: dbRef,
                itemBuilder: (context, snapshot, animation, index) {
                  Map device = snapshot.value as Map;
                  device['key'] = snapshot.key;

                  return FilledCardExample(cardText: device['key'].toString());
                },
              ),
            ),
            // StreamBuilder(
            //   stream: _database.child('devices').limitToLast(10).onValue,
            //   builder: (context, snapshot) {
            //     final cardDisplay = <FilledCardExample>[];
            //     if (snapshot.hasData) {
            //       final myDevices = Map<String, dynamic>.from(
            //           (snapshot.data! as Event).);
            //       myDevices.forEach((key, value) {
            //         final device = Map<String, dynamic>.from(value);

            //         final deviceCard =
            //             FilledCardExample(cardText: device.toString());

            //         cardDisplay.add(deviceCard);
            //       });
            //     }

            //     return Column(
            //       children: cardDisplay,
            //     );
            //   },
            // ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
