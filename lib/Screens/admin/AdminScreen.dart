import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:luckywheel/Screens/admin/AllUsers.dart';
import 'package:luckywheel/Screens/admin/Notification.dart';
import 'package:luckywheel/Screens/admin/requestPage.dart';
import 'package:luckywheel/Screens/admin/shadatNumber.dart';
import 'package:luckywheel/Screens/admin/valuePage.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isAppStopped = false; // Track app state

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  Future<void> _checkAppState() async {
    try {
      // Fetch the app state from Firestore
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      if (snapshot.docs.isNotEmpty) {
        bool anyUserRunning =
            snapshot.docs.any((doc) => doc.get('state') == true);
        setState(() {
          _isAppStopped =
              !anyUserRunning; // If any user has state true, set _isAppStopped to false
        });
      }
    } catch (e) {
      print('Error getting app state: $e');
    }
  }

  Future<void> _toggleAppState() async {
    try {
      // Determine the new state
      bool newState = !_isAppStopped; // Toggle the state

      // Update the state in the Firestore collection
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      for (var doc in snapshot.docs) {
        await _firestore.collection('users').doc(doc.id).update({
          'state': newState,
        });
      }

      setState(() {
        _isAppStopped = newState; // Update local state to match Firestore
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newState ? 'تم ايقاف التطبيق' : 'تم تشغيل التطبيق'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error updating app state: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'لوحة الادمن',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 173, 131, 69),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            AdminMenuItem(
              image: const Icon(
                Icons.browse_gallery,
                size: 40,
              ),
              title: 'عدد اللفات',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const shadatNumber()),
                );
              },
            ),
            AdminMenuItem(
              image: Image.asset(
                'assets/pkg.png',
                height: 60,
                width: 60,
              ),
              title: 'رصيد المستخدمين',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ValuePage()),
                );
              },
            ),
            AdminMenuItem(
              image: const Icon(
                Icons.person,
                size: 40,
              ),
              title: 'جميع المستخدمين',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllUsers()),
                );
              },
            ),
            AdminMenuItem(
              image: const Icon(
                Icons.notifications,
                size: 40,
              ),
              title: 'الاشعارات',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationAdmin()),
                );
              },
            ),
            AdminMenuItem(
              image: const Icon(
                Icons.block,
                size: 40,
              ),
              title: _isAppStopped ? 'تشغيل التطبيق' : 'ايقاف التطبيق',
              onTap: _toggleAppState,
            ),
            AdminMenuItem(
              image: const Icon(
                Icons.receipt,
                size: 40,
              ),
              title: 'طلبات السحب',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RequestPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AdminMenuItem extends StatelessWidget {
  final Widget image;
  final String title;
  final VoidCallback? onTap;

  const AdminMenuItem({required this.image, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            image,
            const SizedBox(height: 16.0),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
