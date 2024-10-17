import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:luckywheel/Screens/admin/AdminScreen.dart';
import 'package:luckywheel/Screens/user/MainScreen.dart';
import 'package:luckywheel/Screens/user/error.dart';
import 'package:luckywheel/Screens/user/privacy.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Random _random = Random();

  bool _isLoading = false; // Track loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/main_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                // Your other UI widgets here
              ),
            ),
            GestureDetector(
              onTap: _isLoading
                  ? null
                  : () async {
                      await _signInWithGoogle(context);
                    }, // Disable button when loading
              child: Container(
                height: 70,
                padding: const EdgeInsets.fromLTRB(50, 8, 50, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isLoading
                        ? CircularProgressIndicator() // Show loading indicator
                        : Image.asset(
                            'assets/goo.png',
                            width: 20,
                            height: 20,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(); // Placeholder widget if image fails to load
                            },
                          ),
                    const SizedBox(width: 8.0),
                    const Text(
                      'تسجيل الدخول بحساب Google',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'innexs',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFECEFF1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn(scopes: ['profile', 'email']).signIn();
      if (googleUser == null) {
        print('Google sign-in failed');
        setState(() {
          _isLoading = false; // Stop loading on failure
        });
        return;
      }

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken!,
        idToken: googleAuth?.idToken!,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final userId = userCredential.user?.uid;
      if (userId == null) {
        print('User ID is null');
        setState(() {
          _isLoading = false; // Stop loading on failure
        });
        return;
      }

      // Check if user already exists
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        // Existing user logic
        final userType = userDoc.get('type');
        final dailyGiftSnapshot = await _firestore
            .collection('DailyGift')
            .where('Email', isEqualTo: userCredential.user?.email)
            .get();

        if (dailyGiftSnapshot.docs.length != 7) {
          for (final doc in dailyGiftSnapshot.docs) {
            await doc.reference.delete();
          }
          await _addDailyGiftRecords(userCredential.user?.email);
        }

        final appState = await _getAppState();

        if (userType == 'user') {
          if (appState) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ErrorScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          }
        } else if (userType == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminScreen()),
          );
        } else {
          print('Unknown user type: $userType');
        }
      } else {
        // New user logic
        final randomNum = await _generateRandomNumber();
        await _firestore.collection('users').doc(userId).set({
          "name": userCredential.user?.displayName,
          "email": userCredential.user?.email,
          "shadat": 3,
          "value": 0,
          "type": "user",
          "state": null,
          "code": randomNum,
          "InvitationCode": [],
        });

        await _addDailyGiftRecords(userCredential.user?.email);

        final appState = await _getAppState();

        if (appState) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ErrorScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PrivacyScreen()),
          );
        }
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false; // Stop loading after sign-in completes
      });
    }
  }

  Future<void> _addDailyGiftRecords(String? email) async {
    for (int i = 0; i <= 6; i++) {
      int cardNum = (i == 6) ? 10 : i + 1; // Set cardNum to 10 if i is 7
      var nextGiftDate = DateTime.now().add(Duration(days: i));
      if (cardNum == 1) {
        nextGiftDate =
            DateTime.now(); // Set NextGiftDate to today if cardNum is 1
      }
      await _firestore.collection('DailyGift').add({
        'Email': email,
        'cardNum': cardNum.toString(), // Card numbers from 1 to 7 or 10
        'date': DateTime.now().toIso8601String(),
        'NextGiftDate': nextGiftDate.toIso8601String(),
        'state': true,
      });
    }
  }

  Future<bool> _getAppState() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('state', isEqualTo: true)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error getting app state: $e');
      return true; // Default to app stopped in case of error
    }
  }

  Future<String> _generateRandomNumber() async {
    String randomNum = ''; // Initialize with an empty string

    bool exists = true;

    while (exists) {
      // Generate a random 6-digit number
      randomNum = (_random.nextInt(900000) + 100000).toString();

      // Check if the generated randomNum already exists in Firestore
      final snapshot = await _firestore
          .collection('users')
          .where('code', isEqualTo: randomNum)
          .limit(1)
          .get();

      exists = snapshot.docs.isNotEmpty;
    }

    return randomNum;
  }
}
