import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:luncare/signup.dart'; // Assuming you have a Signup page
import 'newcheckfile.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  late AnimationController slideAnimController;
  late AnimationController inputAnimController;
  late AnimationController buttonAnimController;
  late AnimationController fadeAnimController;

  late Animation<Offset> slideAnim;
  late Animation<Offset> inputAnim;
  late Animation<Offset> buttonAnim;
  late Animation<double> fadeAnim;

  final TextEditingController docIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // Animation controllers for sliding and fading effects
    slideAnimController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    inputAnimController = AnimationController(
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

    // Setting up animations
    slideAnim = Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero)
        .animate(slideAnimController);
    inputAnim = Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
        .animate(inputAnimController);
    buttonAnim =
        Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero)
            .animate(buttonAnimController);
    fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(fadeAnimController);

    // Start animations
    slideAnimController.forward();
    inputAnimController.forward();
    buttonAnimController.forward();
    fadeAnimController.forward();
  }

  @override
  void dispose() {
    // Dispose animation controllers
    slideAnimController.dispose();
    inputAnimController.dispose();
    buttonAnimController.dispose();
    fadeAnimController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    String docId = docIdController.text.trim();
    String password = passwordController.text.trim();

    if (docId.isEmpty || password.isEmpty) {
      // Show error if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter both Doc ID and Password'),
      ));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Send login request to PHP server
      var url = Uri.parse('http://180.235.121.245/lungcare/login.php'); // Replace with your PHP URL
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'doc_id': docId,
          'password': password,
        }),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CancerDetectionPage()),
          );
        } else {
          // Show error message if login failed
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(jsonResponse['message']),
          ));
        }
      } else {
        // Show error if server response is not 200 OK
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to connect to server. Please try again.'),
        ));
      }
    } catch (e) {
      // Catch any other exceptions
      print("Exception during login: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('An error occurred. Please try again.'),
      ));
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFC3A0),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideTransition(
                position: slideAnim,
                child: Container(
                  width: 275,
                  height: 275,
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                  ),
                  child: Image.asset('assets/login2.png', fit: BoxFit.cover),
                ),
              ),
              FadeTransition(
                opacity: fadeAnim,
                child: const Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 27),
                  child: Text(
                    'WELCOME!!',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF5733),
                    ),
                  ),
                ),
              ),
              SlideTransition(
                position: inputAnim,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  width: 375,
                  decoration: BoxDecoration(
                    color: const Color(0xFF753AC1),
                    borderRadius: BorderRadius.circular(20),
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
                          labelText: 'Doc ID',
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
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
              ),
              SlideTransition(
                position: buttonAnim,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5733),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 50,
                      ),
                      elevation: 5,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text.rich(
                  TextSpan(
                    text: "Don't have an account? ",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: 'Sign up',
                        style: const TextStyle(
                          color: Color(0xFFFF5733),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Signup()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
