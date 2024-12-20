import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:luncare/login.dart'; // Importing the Login page
import 'package:luncare/success.dart'; // Importing the Success page

class CancerDetectionPage extends StatefulWidget {
  @override
  _CancerDetectionPageState createState() => _CancerDetectionPageState();
}

class _CancerDetectionPageState extends State<CancerDetectionPage> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String _className = "";
  double _confidenceScore = 0.0;

  // Controllers for patient details
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _selectedGender = 'Male'; // Default gender
  final TextEditingController _phoneController = TextEditingController();

  late AnimationController _titleController, _buttonController;
  late Animation<Offset> _titleSlideAnimation, _buttonSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers and animations
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _titleSlideAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(_titleController);
    _buttonSlideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(_buttonController);

    _titleController.forward();
    _buttonController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _buttonController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _className = "";
        _confidenceScore = 0.0;
      });
      await _uploadImage(_image!);
    }
  }

  Future<void> _uploadImage(File image) async {
    final uri = Uri.parse('http://180.235.121.245:5006/predict'); // Updated IP
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', image.path));
    final response = await request.send();
    final responseData = await response.stream.toBytes();
    final result = json.decode(String.fromCharCodes(responseData));

    setState(() {
      _className = result['class_name'];
      _confidenceScore = result['confidence_score'];
    });
  }

  Future<void> _savePatientDetails() async {
    if (_nameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _image == null ||
        _className.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete all details and get a prediction first.")),
      );
      return;
    }

    try {
      final uri = Uri.parse('http://180.235.121.245/php/patient_details.php'); // Replace with actual API endpoint
      final request = http.MultipartRequest('POST', uri)
        ..fields['name'] = _nameController.text
        ..fields['age'] = _ageController.text
        ..fields['gender'] = _selectedGender
        ..fields['phone'] = _phoneController.text
        ..fields['prediction'] = _className
        ..fields['confidence'] = (_confidenceScore * 100).toStringAsFixed(2)
        ..files.add(await http.MultipartFile.fromPath('image', _image!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        // Navigate to the SuccessPage after successfully saving patient details
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuccessPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save patient details. Please try again.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFC3A0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC3A0),
        centerTitle: true,
        title: const Text(
          'Emphysema Detection',
          style: TextStyle(color: Color(0xFFFFC3A0)),
        ),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
            );
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/detect4.png',
                  width: 250,
                  height: 350,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  items: <String>['Male', 'Female', 'Others'].map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGender = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt, size: 28, color: Colors.white),
                  label: const Text('Take a Picture', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo, size: 28, color: Colors.white),
                  label: const Text('Select from Gallery', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_image != null)
                  Image.file(
                    _image!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 20),
                if (_className.isNotEmpty)
                  SlideTransition(
                    position: _buttonSlideAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 5,
                            color: Colors.black.withOpacity(0.2),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Detection Result:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Class: $_className',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Confidence: ${(_confidenceScore * 100).toStringAsFixed(2)}%',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Text(
                    'Pick an image to start the Emphysema detection!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _savePatientDetails,
                  icon: const Icon(Icons.save, size: 28, color: Colors.white),
                  label: const Text('Save Patient', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
