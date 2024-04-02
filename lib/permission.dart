import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPermissions() async {
  // Request multiple permissions at once
  final Map<Permission, PermissionStatus> statuses = await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.locationWhenInUse,
  ].request();

  // Check individual permission status
  if (statuses[Permission.bluetoothScan]!.isGranted &&
      statuses[Permission.bluetoothConnect]!.isGranted &&
      statuses[Permission.locationWhenInUse]!.isGranted) {
    // All permissions granted
    return true;
  } else {
    // Handle permission denials or permanent denials
    // await handlePermissionDenial(statuses);
    return false;
  }
}

// Future<void> handlePermissionDenial(
//     Map<Permission, PermissionStatus> statuses) async {
//   // Loop through denied permissions
//   for (var permission in statuses.entries) {
//     final PermissionStatus status = permission.value;
//     if (status.isDenied) {
//       // Open permission settings if user denied permission
//       await openAppSettings();
//     } else if (status.isPermanentlyDenied) {
//       // Request permission again with a rationale
//       await Permission.bluetoothScan.request()(
//           "This app needs Bluetooth permission to scan for devices.");
//     }
//   }
// }
