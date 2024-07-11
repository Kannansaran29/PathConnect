import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pathconnect/home/home_screen.dart';

class VerificationEmailScreen extends StatefulWidget {
  @override
  _VerificationEmailScreenState createState() =>
      _VerificationEmailScreenState();
}

class _VerificationEmailScreenState extends State<VerificationEmailScreen> {
  bool _isVerified = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start the timer to periodically check email verification status
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      checkEmailVerification();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  // Function to send a verification email
  void sendVerificationEmail() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification email sent!'),
        ),
      );
    } else {
      print('User is already verified or user is null.');
    }
  }

  // Function to check email verification status
  void checkEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && user.emailVerified) {
      setState(() {
        _isVerified = true;
      });
      _timer?.cancel(); // Stop the timer when email is verified
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isVerified
        ? HomePage()
        : Scaffold(
            appBar: AppBar(
              title: Text('Verification'),
              actions: [
                IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  icon: Icon(Icons.logout),
                )
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Lottie.asset(
                    'assets/images/email.json', // Path to your Lottie animation file
                    height: 200,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Please verify your email to use our app.',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 20),
                  if (!_isVerified)
                    ElevatedButton(
                      onPressed: () {
                        sendVerificationEmail();
                      },
                      child: Text('Send Verification Email'),
                    ),
                  SizedBox(height: 20),
                  _isVerified
                      ? Text(
                          'Verification email sent!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        )
                      : SizedBox(), // Placeholder for email verification status
                ],
              ),
            ),
          );
  }
}
