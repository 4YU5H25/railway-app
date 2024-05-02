import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:railways1/bluetooth.dart';
import 'package:railways1/db.dart';
import 'package:railways1/reportscreen.dart';

class HomeScreen extends StatefulWidget {
  String address;
  HomeScreen(this.address);
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();

  bool receiving = true;
  List<double> distance = [0];
  List<double> gauge = [0];
  List<double> elevation = [0];
  List<double> receivedData = [0];

  DatabaseHelper db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    db.initDatabase().then((value) => null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color.fromARGB(255, 216, 77, 38),
              Color.fromARGB(0, 230, 2, 2)
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 73,
            ),
            Image.asset(
              "assets/images/raillogo.png",
              width: 127,
            ),
            const SizedBox(
              height: 31,
            ),
            Expanded(
              child: Container(
                width: 343,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xccffffff),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),
                      const Padding(
                        padding: EdgeInsets.only(left: 18),
                        child: Text(
                          "Sleeper Number:",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(),
                          ),
                          child: TextFormField(
                            controller: _name,
                            textAlign: TextAlign.left,
                            decoration: const InputDecoration(
                              hintText: '',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a sleeper number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Center(
                          child: Container(
                            width: 140,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Color.fromARGB(255, 234, 84, 38),
                                  Color.fromARGB(255, 241, 56, 36)
                                ]),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    disabledForegroundColor:
                                        Colors.transparent.withOpacity(0.38),
                                    disabledBackgroundColor:
                                        Colors.transparent.withOpacity(0.12),
                                    shadowColor: Colors.transparent,
                                  ),
                                  onPressed: () async {
                                    await db.initDatabase();
                                    print("Start Button Pressed");
                                    await Bluetooth.requestPermissions();
                                    if (Bluetooth.isConnected == false) {
                                      try {
                                        await Bluetooth.connectToDevice(
                                            widget.address);
                                      } catch (e) {
                                        print(e);
                                      }
                                    }
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text('Machine reading started'),
                                    ));
                                    List<double> values = [];
                                    setState(() {
                                      values = Bluetooth.startListening();
                                    });

                                    // Update receivedData with new values

                                    setState(() {
                                      receivedData = values;
                                      distance.add(values[0]);
                                      gauge.add(values[1]);
                                      elevation.add(values[2]);
                                    });
                                  },
                                  child: const Text("START")),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const Center(
                        child: Text(
                          "Distance :",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Container(
                            height: 99,
                            color: CupertinoColors.systemGrey4,
                            child: ListView.builder(
                              itemCount: Bluetooth.distance.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                      "Distance: ${Bluetooth.distance[index]}"),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const Center(
                        child: Text(
                          "Gauge :",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Container(
                            height: 99,
                            color: CupertinoColors.systemGrey4,
                            child: ListView.builder(
                              itemCount: Bluetooth.gauge.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title:
                                      Text("Gauge: ${Bluetooth.gauge[index]}"),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const Center(
                        child: Text(
                          "Elevation :",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Container(
                            height: 99,
                            color: CupertinoColors.systemGrey4,
                            child: ListView.builder(
                              itemCount: Bluetooth.elevation.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                      "Elevation: ${Bluetooth.elevation[index]}"),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Center(
                child: Container(
                  width: 140,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          Color.fromARGB(255, 200, 10, 19),
                          Color.fromARGB(255, 249, 66, 66)
                        ]),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.57),
                              blurRadius: 5)
                        ]),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          disabledForegroundColor:
                              Colors.transparent.withOpacity(0.38),
                          disabledBackgroundColor:
                              Colors.transparent.withOpacity(0.12),
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () async {
                          print("Stop Button Pressed");
                          print(distance);
                          print(gauge);
                          print(elevation);
                          await db.insertUserData(
                            sleeper: _name.text,
                            distance: Bluetooth.distance,
                            gauge: Bluetooth.gauge,
                            elevation: Bluetooth.elevation,
                            temperature: [0],
                          );
                          setState(() {
                            receiving = true;
                          });
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Report(),
                            ),
                          );
                          // Bluetooth.stopBluetooth();
                        },
                        child: const Text("STOP")),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
