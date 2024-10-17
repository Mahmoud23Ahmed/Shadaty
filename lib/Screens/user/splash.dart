import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:luckywheel/Screens/admin/AdminScreen.dart';
import 'package:luckywheel/Screens/login.dart';
import 'package:luckywheel/Screens/user/MainScreen.dart';
import 'package:luckywheel/Screens/user/error.dart';
import 'package:luckywheel/Screens/helper/background_music.dart';
import 'package:luckywheel/Screens/user/privacy.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    Provider.of<MusicPlayer>(context, listen: false).init();
    _handleAuth();
  }

  Future<void> _handleAuth() async {
    // Wait for 3 seconds before checking authentication
    await Future.delayed(const Duration(seconds: 3));

    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      // User is logged in, check if they exist in Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (userDoc.exists) {
        // User exists, check their type and app state
        String userType = userDoc.get('type');
        bool appState = await _getAppState();

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
          // Navigate to login if the user type is unknown
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      } else {
        // User does not exist in Firestore, navigate to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } else {
      // No user is logged in, navigate to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  Future<bool> _getAppState() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('state', isEqualTo: true)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error getting app state: $e');
      return true; // Default to app stopped in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/pu_back.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(5),
              ),
            ),
            Container(
              width: screenWidth * 0.9, // Set width to 90% of the screen width
              height:
                  screenHeight * 0.2, // Set height to 20% of the screen height
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/mmmm.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: screenHeight *
                        0.03, // Dynamically position based on screen height
                    left: screenWidth *
                        0.09, // Dynamically position based on screen width
                    child: const Text(
                      'اربح شدات مع عجله الحظ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  '© Kinnexs',
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
}
