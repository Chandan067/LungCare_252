import 'package:flutter/material.dart';
import 'package:luncare/login.dart'; // Ensure this file exists and the class is named properly

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/star.gif', // Ensure this asset path is correct and added to pubspec.yaml
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Image Container
                Container(
                  width: 225,
                  height: 225,
                  margin: const EdgeInsets.only(bottom: 100, top: 200),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo33.png', // Ensure this asset path is correct and added to pubspec.yaml
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),

                // Text: Lung Care
                const Column(
                  children: [
                    Text(
                      'Lung',
                      style: TextStyle(
                        fontSize: 60,
                        color: Color.fromRGBO(201, 29, 29, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Care',
                      style: TextStyle(
                        fontSize: 60,
                        color: Color.fromRGBO(93, 110, 153, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 100),

                // Get Started Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5733), // Button background color
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black,
                  ),
                  onPressed: () {
                    // Navigating to Login Screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()), // Adjusted class name
                    );
                  },
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
