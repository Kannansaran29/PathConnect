import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pathconnect/constants.dart';
import 'package:pathconnect/home/verification.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseUIAuth.configureProviders([EmailAuthProvider()]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: defaultPropertyBackgroundColour,
        // useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: const AuthWidget(),
    );
  }
}

class AuthWidget extends StatefulWidget {
  const AuthWidget({super.key});

  @override
  State<AuthWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  void _showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Terms and Conditions'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // Place your terms and conditions text here
                  '''
                  These terms and conditions ("Terms") govern your access to and use of the PathConnect mobile application provided by PathConnect Inc.. By accessing or using the App, you agree to be bound by these Terms. If you do not agree to these Terms, you may not access or use the App.
                  
                  User Eligibility: You must be at least 18 years old to use the App. By accessing or using the App, you represent and warrant that you are at least 18 years old.
                  
                  Account Registration: To access certain features of the App, you may be required to create an account. You agree to provide accurate, current, and complete information during the registration process and to update such information to keep it accurate, current, and complete. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.
                  
                  User Conduct: You agree to use the App in compliance with all applicable laws, regulations, and these Terms. You further agree not to:
                  • Use the App for any unlawful purpose or in any manner that violates these Terms.
                  • Interfere with or disrupt the operation of the App or the servers or networks used to make the App available.
                  • Attempt to gain unauthorized access to any portion of the App or any other systems or networks connected to the App.
                  
                  Privacy: Your privacy is important to us. Our Privacy Policy explains how we collect, use, and disclose information about you. By accessing or using the App, you consent to the collection, use, and disclosure of your information as described in the Privacy Policy.
                  
                  Intellectual Property: The App and its contents, including but not limited to text, graphics, images, logos, and software, are protected by copyright, trademark, and other laws. Except as expressly authorized by PathConnect, you may not modify, reproduce, distribute, or create derivative works based on the App or its contents.
                  
                  Disclaimer of Warranties: THE APP IS PROVIDED ON AN "AS IS" AND "AS AVAILABLE" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED. PATHCONNECT DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.
                  
                  Limitation of Liability: TO THE MAXIMUM EXTENT PERMITTED BY LAW, PATHCONNECT SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, OR ANY LOSS OF PROFITS OR REVENUES, WHETHER INCURRED DIRECTLY OR INDIRECTLY, OR ANY LOSS OF DATA, USE, GOODWILL, OR OTHER INTANGIBLE LOSSES, ARISING OUT OF OR IN CONNECTION WITH YOUR ACCESS TO OR USE OF THE APP.
                  
                  Governing Law: These Terms shall be governed by and construed in accordance with the laws of India, without regard to its conflict of law principles.
                  
                  Changes to Terms: PathConnect reserves the right to modify these Terms at any time, in its sole discretion. If we make material changes to these Terms, we will notify you by email or by posting a notice on the App. Your continued use of the App after the effective date of the revised Terms constitutes your acceptance of the revised Terms.
                  
                  Contact Us: If you have any questions about these Terms, please contact us at pathconnect5@gmail.com.
                  ''',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return VerificationEmailScreen();
        }
        return SignInScreen(
          subtitleBuilder: (context, action) {
            final actionText = switch (action) {
              AuthAction.signIn => 'Please sign in to continue.',
              AuthAction.signUp => 'Please create an account to continue',
              _ => throw Exception('Invalid action: $action'),
            };

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Welcome to PathConnect! $actionText.'),
            );
          },
          footerBuilder: (context, action) {
            final actionText = switch (action) {
              AuthAction.signIn => 'signing in',
              AuthAction.signUp => 'registering',
              _ => throw Exception('Invalid action: $action'),
            };

            return Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: GestureDetector(
                      onTap: () {
                        _showTermsAndConditions(context);
                      },
                      child: Text(
                        'By $actionText, you agree to our terms and conditions.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          headerBuilder: (context, constraints, shrinkOffset) {
            return Center(
              child: Image.asset('assets/images/icon.png',
                  width: 100, height: 100),
            );
          },
          providers: [EmailAuthProvider()],
          actions: [
            AuthStateChangeAction<UserCreated>((context, state) async {
              _createUserDocument(state.credential.user!);
              if (kDebugMode) {
                print('New User Created');
              }
            }),
            AuthStateChangeAction<SignedIn>((context, state) {}),
          ],
        );
      },
    );
  }

  void _createUserDocument(User user) {
    FirebaseFirestore.instance
        .collection('pathconnectUsers')
        .doc(user.uid)
        .set({
      'userId': user.uid,
      'userAlias': "User",
      'userName': "User",
      'userEmail': user.email,
      'userRole': 'user',
      'userPhone': '',
      'userGender': '',
      'userAge': '',
      'userProfileImage': ''
          'https://cdn-icons-png.flaticon.com/512/666/666201.png',
      'userAddress': '',
    });
  }
}
