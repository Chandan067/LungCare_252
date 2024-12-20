import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:luncare/success.dart';
import 'package:luncare/login.dart';

import 'newcheckfile.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> with TickerProviderStateMixin {
  final TextEditingController docIdController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phnoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late AnimationController slideAnimController;
  late AnimationController buttonAnimController;
  late AnimationController fadeAnimController;
  late Animation<Offset> slideAnim;
  late Animation<Offset> buttonAnim;
  late Animation<double> fadeAnim;
  late Animation<Offset> rectAnim;

  @override
  void initState() {
    super.initState();

    slideAnimController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    buttonAnimController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    fadeAnimController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    slideAnim = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(slideAnimController);
    buttonAnim = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(buttonAnimController);
    fadeAnim = Tween<double>(begin: 0, end: 1).animate(fadeAnimController);
    rectAnim = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(slideAnimController);

    slideAnimController.forward();
    buttonAnimController.forward();
    fadeAnimController.forward();
  }

  @override
  void dispose() {
    slideAnimController.dispose();
    buttonAnimController.dispose();
    fadeAnimController.dispose();
    super.dispose();
  }

  Future<void> handleSignUp() async {
    // Validate fields
    if (docIdController.text.isEmpty ||
        usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phnoController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter all required information.')));
      return;
    }

    const signUpApiUrl = 'http://180.235.121.245/lungcare/signup.php'; // Ensure this is your correct endpoint

    try {
      final response = await http.post(
        Uri.parse(signUpApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'doc_id': docIdController.text,
          'username': usernameController.text,
          'email': emailController.text,
          'phno': phnoController.text,
          'password': passwordController.text,
        }),
      );

      // Log the response for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Ensure the response is in the correct format
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Sign-up successful
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sign up successful!')));
          // Navigate to the dashboard screen after sign-up
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
        } else {
          // Sign-up failed, show the error message returned from the server
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'] ?? 'Sign up failed. Please try again.')));
        }
      } else {
        // Server returned an error
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server error. Please try again later.')));
      }
    } catch (error) {
      print('Error during signup: $error'); // Log the error for debugging
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign up failed due to an error. Please try again.')));
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFC3A0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC3A0),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideTransition(
                position: slideAnim,
                child: Container(
                  width: 300,
                  height: 300,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFFC3A0),
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Image.asset('assets/signup2.png', fit: BoxFit.cover),
                ),
              ),
              FadeTransition(
                opacity: fadeAnim,
                child: const Padding(
                  padding: EdgeInsets.only(top: 1, bottom: 10),
                  child: Text(
                    'SIGN UP',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF5733),
                    ),
                  ),
                ),
              ),
              SlideTransition(
                position: rectAnim,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF275190),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: docIdController,
                        decoration: InputDecoration(
                          labelText: 'Doctor ID',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: phnoController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SlideTransition(
                position: buttonAnim,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5733),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
