import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EndScreen extends StatefulWidget {
  final int Widgetvalue;
  const EndScreen({super.key, required this.Widgetvalue});

  @override
  _EndScreenState createState() => _EndScreenState();
}

class _EndScreenState extends State<EndScreen> {
  int value = 0;
  bool canSend = false;
  final _textController = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _getData(); // Fetch user data when initializing
  }

  Future<void> _getData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists) {
          // Convert value from string to int safely
          final int intValue = userData['value'];

          setState(() {
            value = intValue;
            canSend = intValue >= 500;
          });
        } else {
          setState(() {
            canSend = false;
          });
        }
      } else {
        setState(() {
          canSend = false;
        });
      }
    } catch (e) {
      setState(() {
        canSend = false;
      });
    }
  }

  Future<void> _sendIdAndUpdateValue() async {
    final user = auth.currentUser;
    if (user != null) {
      final userDocRef = firestore.collection('users').doc(user.uid);
      final pubgIdCollectionRef = firestore.collection('pubgIds');

      try {
        await firestore.runTransaction((transaction) async {
          // Fetch the user's current data
          final userDoc = await transaction.get(userDocRef);

          // Safely parse the value as int
          final currentValue = userDoc['value'];

          // Update or add PUBG ID
          final pubgIdDocs = await pubgIdCollectionRef
              .where('email', isEqualTo: user.email)
              .get();

          // Add a new document if the user doesn't exist
          transaction.set(pubgIdCollectionRef.doc(), {
            'email': user.email,
            'gameId': _textController.text,
            'value': widget.Widgetvalue,
            'date': DateFormat('d-M-y').format(DateTime.now()),
            'status': false,
          });

          // Decrease the user's value by 500
          transaction.update(userDocRef, {
            'value': currentValue - widget.Widgetvalue,
          });

          // Notify the user of success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ID sent successfully'),
            ),
          );

          // Return to the previous screen
          Navigator.pop(context);
        });
      } catch (e) {
        // Handle transaction errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating value: $e'),
          ),
        );
      }
    } else {
      // Handle the case where the user is not logged in
      print('User is not logged in');
    }
  }

  void _showMessageToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black
          .withOpacity(0.7), // Make the background slightly transparent
      textColor: Colors.white,
      fontSize: 15.0, // Reduce the font size
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
          children: [
            // TextInputLayout with TextField
            Container(
              width: double.infinity, // Take up full width
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'PUBG ID',
                  labelStyle: TextStyle(color: Color(0xFF607D8B)),
                ),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16), // Space between elements
            // Button with Text
            Container(
              width: 150,
              height: 70,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37), // Gold color if enabled

                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: TextButton(
                  onPressed: _sendIdAndUpdateValue,
                  // Handle ID sending and value update
                  child: const Text(
                    'سحب',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
