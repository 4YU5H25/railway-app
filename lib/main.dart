import 'package:flutter/material.dart';
import 'package:railways1/blue.dart';
import 'package:railways1/homescreen.dart';
import 'package:railways1/splashscreen.dart';

void main() {
  runApp(const myapp());
}

class myapp extends StatelessWidget {
  const myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // home: HomeScreen("00:22:12:00:4D:DF"),
        home: BluetoothPage(),
        debugShowCheckedModeBanner: false,
        routes: {
          // '/HomeScreen': (context) => HomeScreen(),
          '/BluetoothScreen': (context) => const BluetoothPage(),
        });
  }
}
