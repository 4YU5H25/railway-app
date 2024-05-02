import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class Bluetooth {
  static late BluetoothConnection? connection;
  static bool isConnected = false;
  static bool isScanning = false;
  static List<double> receivedDataList = [];
  static List<BluetoothDiscoveryResult> devices = [];
  static StreamSubscription<BluetoothDiscoveryResult>? streamSubscription;
  static List<BluetoothDevice> devicesList = [];
  static List<String> answers = [];

  static List<double> distance = [];
  static List<double> gauge = [];
  static List<double> temperature = [];
  static List<double> elevation = [];

  static Future<void> startDiscovery() async {
    try {
      FlutterBluetoothSerial.instance.startDiscovery();
    } catch (ex) {
      print(ex);
    }

    FlutterBluetoothSerial.instance
        .startDiscovery()
        .listen((BluetoothDiscoveryResult state) {
      devicesList.add(state.device);
    });
  }

  static Future<bool> connectToDevice(String address) async {
    connection = await BluetoothConnection.toAddress(address);
    print("connectiontoaddress!!!!!");
    String pass = '1234';
    pass = pass.trim();
    try {
      List<int> list = pass.codeUnits;
      Uint8List bytes = Uint8List.fromList(list);
      connection!.output.add(bytes);
      await connection!.output.allSent;
      print("inside try and output is sent");
      isConnected = true;
      print('Connected to Device');
      // startListening();
    } catch (exception) {
      print('Cannot connect, exception occurred: $exception');
      // print('StackTrace: $stackTrace');
    }
    if (connection != null) {
      return true;
    }
    return false;
  }

  void sendData(String data) async {
    data = data.trim();
    if (isConnected) {
      try {
        List<int> list = data.codeUnits;
        Uint8List bytes = Uint8List.fromList(list);
        connection!.output.add(bytes);
        await connection!.output.allSent;
        if (kDebugMode) {
          print('Data sent successfully');
        }
      } catch (e) {
        print('Error sending data: $e');
      }
    } else {
      print('BlConnection not yet initialized');
    }
  }

  static List<double> startListening() {
    List<double> values = [0, 0, 0, 0];
    connection!.input!.listen((Uint8List data) {
      String rec = String.fromCharCodes(data);
      print("rec: $rec");
      List<String> lines = rec.split('\r\n');

      for (var i = 0; i < lines.length && i < values.length; i++) {
        values[i] = double.tryParse(lines[i].trim()) ?? 0;
      }
      distance.add(values[0]);
      gauge.add(values[1]);
      elevation.add(values[2]);
      temperature.add(values[3]);
      print('Value 1: ${values[0]}');
      print('Value 2: ${values[1]}');
      print('Value 3: ${values[2]}');
      print('Value 3: ${values[3]}');
    }, onDone: () {
      print('Connection closed');
      connection = null;
    }, onError: (e) {
      print("Error occurred: $e");
    });
    return values; // Return the list of values
  }

  static void stopBluetooth() {
    if (connection != null) {
      connection!.dispose();
      connection = null;
      print('Bluetooth Blconnection stopped');
    }
  }

  static Future<void> requestPermissions() async {
    await requestStoragePermission();
    await requestLocationPermission();
    await requestBluetoothPermission();
    await requestBluetoothScanPermission();
    await requestConnectPermission();
  }

  static Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.request();

    if (status == PermissionStatus.granted) {
      // Permission granted, you can access storage
      print('Storage permission granted');
      return true;
    } else if (status == PermissionStatus.denied) {
      // Permission denied
      print('Storage permission denied');
      return false;
    } else if (status == PermissionStatus.permanentlyDenied) {
      // Permission permanently denied
      print('Storage permission permanently denied. Open app settings.');
      await openAppSettings();
      return false;
    }

    // If status is restricted, unavailable, or limited, handle accordingly
    return false;
  }

  static Future<void> requestLocationPermission() async {
    // Request location permission
    var status = await Permission.location.request();

    if (status.isGranted) {
      // Permission granted, you can proceed with location-related tasks
      print("Location permission granted");
    } else if (status.isDenied) {
      // Permission denied, handle accordingly
      print("Location permission denied");
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  static Future<void> requestConnectPermission() async {
    // Request location permission
    var status = await Permission.bluetoothConnect.request();

    if (status.isGranted) {
      // Permission granted, you can proceed with location-related tasks
      print("Location permission granted");
    } else if (status.isDenied) {
      // Permission denied, handle accordingly
      print("Location permission denied");
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, navigate to app settings
      openAppSettings();
    }
  }

  static Future<void> requestBluetoothPermission() async {
    var status = await Permission.bluetooth.request();

    if (status.isGranted) {
      // Permission granted, you can proceed with Bluetooth-related tasks
      print("Bluetooth permission granted");
    } else if (status.isDenied) {
      // Permission denied, handle accordingly
      print("Bluetooth permission denied");
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, navigate to app settings
      openAppSettings();
    }
  }

  static Future<void> requestBluetoothScanPermission() async {
    var status = await Permission.bluetoothScan.request();

    if (status.isGranted) {
      // Permission granted, you can proceed with Bluetooth-related tasks
      print("Bluetooth permission granted");
    } else if (status.isDenied) {
      // Permission denied, handle accordingly
      print("Bluetooth permission denied");
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, navigate to app settings
      openAppSettings();
    }
  }
}
