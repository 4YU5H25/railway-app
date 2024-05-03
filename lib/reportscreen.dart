import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:railways1/db.dart';

class Report extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("assets/images/indianrailways.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.19),
              BlendMode.modulate,
            ),
          ),
        ),
        child: Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 3,
              backgroundColor: Colors.deepOrange,
            ),
            onPressed: () async {
              await _generateAndDownloadCSV(context);
              // Add your functionality for the button here
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => DatabaseTable()),
              );
              print("Generate Report Button Pressed");
            },
            child: const Text(
              "Generate Report",
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generateAndDownloadCSV(BuildContext context) async {
    // Retrieve all user data from SQLite database
    List<Map<String, dynamic>> userDataList =
        await DatabaseHelper().getAllUserData();

    List<String> header = [
      'Sleeper Number',
      'Gauge',
      'Distance',
      'Elevation',
      'Temperature'
    ];

    // Generate CSV data for new entries only
    List<List<String>> newCsvData = [];
    for (var userData in userDataList) {
      newCsvData.add([
        userData['Sleeper'].toString(),
        userData['Gauge'].toString(),
        userData['Distance'].toString(),
        userData['Elevation'].toString(),
        userData['Temperature'].toString(),
      ]);
    }

    // Get the path to the existing CSV file
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String timestamp = DateTime.now().toString();
    String filePath = '${documentsDir.path}/Report_$timestamp.csv';

    try {
      // Check if the file exists
      bool fileExists = await File(filePath).exists();

      if (fileExists) {
        // Read existing CSV data
        String existingCsvContent = await File(filePath).readAsString();
        List<List<dynamic>> existingCsvData =
            const CsvToListConverter().convert(existingCsvContent);

        // Combine existing and new data
        existingCsvData.addAll(newCsvData);

        // Write CSV data with header
        await File(filePath).writeAsString(
          const ListToCsvConverter(fieldDelimiter: '  ')
              .convert(existingCsvData),
          encoding: utf8,
        );
      } else {
        // Write CSV data with header
        await File(filePath).writeAsString(
          const ListToCsvConverter(fieldDelimiter: '  ')
              .convert([header] + newCsvData),
          encoding: utf8,
        );
      }

      String documentsFolderPath = '/storage/emulated/0/Documents';
      Directory? externalDir = await getExternalStorageDirectory();
      String fileName = 'Report_$timestamp.csv';

      String newFilePath = '$documentsFolderPath/$fileName';

      await File(filePath).copy(newFilePath);
      await File(filePath).delete();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report saved to Documents!'),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error Saving!'),
        ),
      );
      print("Error saving CSV: $e");
    }
  }
}