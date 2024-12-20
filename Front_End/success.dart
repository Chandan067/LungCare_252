import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'newcheckfile.dart'; // Import your NewCheckFile page

class SuccessPage extends StatefulWidget {
  @override
  _SuccessPageState createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  List<List<String>> _csvData = [];

  // Function to fetch CSV data from the server
  Future<void> fetchCsvData() async {
    final url = "http://180.235.121.245/php/export_details.php"; // Update with your server URL

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = response.body;
        List<List<String>> parsedData = parseCsv(data);

        // Ensure all rows have the same number of columns as the header
        int columnCount = parsedData.isNotEmpty ? parsedData[0].length : 0;
        parsedData = parsedData.map((row) {
          while (row.length < columnCount) {
            row.add(''); // Add empty cells to match the column count
          }
          return row;
        }).toList();

        setState(() {
          _csvData = parsedData;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load CSV: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching CSV: $e')),
      );
    }
  }

  // Function to parse CSV data
  List<List<String>> parseCsv(String data) {
    List<List<String>> rows = [];
    List<String> lines = LineSplitter.split(data).toList();

    for (var line in lines) {
      rows.add(line.split(',').map((e) => e.trim()).toList());
    }

    return rows;
  }

  // Function to request permission and save CSV to the selected folder
  Future<void> saveCsvToFile() async {
    // Request storage permissions for Android 10+
    var status = await Permission.storage.request();

    // For Android 11 and above, request additional permission
    if (status.isGranted || await Permission.manageExternalStorage.request().isGranted||true) {
      if (_csvData.isNotEmpty) {
        // Use File Picker to open folder selection dialog
        String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

        if (selectedDirectory != null) {
          // Ask the user to input a file name after selecting the folder
          String? fileName = await _showFileNameDialog();

          if (fileName != null && fileName.isNotEmpty) {
            // Convert the CSV data to a string
            String csvContent = _csvData.map((row) => row.join(',')).join('\n');

            // Define the file path for CSV in the selected directory with the user-provided name
            final file = File('$selectedDirectory/$fileName.csv');

            // Write the CSV content to the file
            await file.writeAsString(csvContent);

            // Notify the user that the file has been saved
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('CSV file saved to ${file.path}')),
            );
          } else {
            // Handle case when user doesn't provide a name
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No file name provided.')),
            );
          }
        } else {
          // Handle case when the user cancels the folder selection
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No folder selected.')),
          );
        }
      }
    } else {
      // Handle permission denial
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied! Unable to save CSV file.')),
      );
    }
  }


  // Function to show a dialog for the user to input the file name
  Future<String?> _showFileNameDialog() async {
    String? fileName = '';
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter File Name'),
          content: TextField(
            onChanged: (value) {
              fileName = value;
            },
            decoration: InputDecoration(hintText: "Enter file name here"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(fileName);
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null); // Cancel the operation
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchCsvData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Success'),
        backgroundColor: Color(0xFFFFC3A0),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CancerDetectionPage()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20.0,
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2DC2D7),
                  ),
                  columns: _csvData.isNotEmpty
                      ? _csvData[0]
                      .map((col) => DataColumn(label: Text(col)))
                      .toList()
                      : [],
                  rows: _csvData.length > 1
                      ? _csvData
                      .sublist(1)
                      .map(
                        (row) => DataRow(
                      cells: row
                          .map(
                            (cell) => DataCell(Text(cell)),
                      )
                          .toList(),
                    ),
                  )
                      .toList()
                      : [],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: saveCsvToFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFC3A0),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Save CSV to Selected Folder',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
