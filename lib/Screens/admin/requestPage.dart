import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestPage extends StatefulWidget {
  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _data = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('pubgIds')
          .where('status', isEqualTo: false)
          .get();

      setState(() {
        _data = snapshot.docs.toList();
      });
    } catch (e) {
      print('Error loading users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء تحميل البيانات'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<String> _getUserName(String email) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first['name'];
      } else {
        return 'Unknown';
      }
    } catch (e) {
      print('Error fetching user name: $e');
      return 'Error fetching name';
    }
  }

  void _approveRequest(String userEmail, DocumentSnapshot requestDoc) async {
    try {
      final QuerySnapshot userSnapshot = await _firestore
          .collection('pubgIds')
          .where('email', isEqualTo: userEmail)
          .get();

      if (userSnapshot.docs.isEmpty) {
        throw Exception('User document not found in pubgIds collection');
      }

      final DocumentSnapshot userDoc = userSnapshot.docs.first;
      await _firestore.collection('pubgIds').doc(userDoc.id).update({
        'status': true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم قبول الطلب'),
          duration: Duration(seconds: 2),
        ),
      );

      _loadUsers();
    } catch (e) {
      print('Error approving request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء معالجة الطلب'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _rejectRequest(DocumentSnapshot requestDoc) async {
    try {
      final String email = requestDoc['email'];
      int pubgIdValue = requestDoc['value'];

      final QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userSnapshot.docs.isEmpty) {
        throw Exception('User document not found in users collection');
      }

      final DocumentSnapshot userDoc = userSnapshot.docs.first;
      final int currentUserValue = userDoc['value'];

      final int updatedValue = currentUserValue + pubgIdValue;

      await _firestore.collection('users').doc(userDoc.id).update({
        'value': updatedValue,
      });
      await _firestore.collection('pubgIds').doc(requestDoc.id).update({
        'status': true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم رفض الطلب واسترجاع الشدات للمستخدم'),
          duration: Duration(seconds: 2),
        ),
      );

      _loadUsers();
    } catch (e) {
      print('Error rejecting request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء رفض الطلب'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'طلبات السحب',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 173, 131, 69),
      ),
      body: ListView.builder(
        itemCount: _data.length,
        itemBuilder: (context, index) {
          final DocumentSnapshot requestDoc = _data[index];
          final String email = requestDoc['email'];
          return FutureBuilder<String>(
            future: _getUserName(email),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final String userName = snapshot.data!;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name: $userName',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Email: ${requestDoc['email']}',
                                style: const TextStyle(fontSize: 13.0),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Pubg Id: ${requestDoc['gameId']}',
                                style: const TextStyle(fontSize: 14.0),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'الشدات المطلوب سحبها: ${requestDoc['value']}',
                                style: const TextStyle(fontSize: 14.0),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          itemBuilder: (context) => [
                            const PopupMenuItem<String>(
                              value: 'approve',
                              child: Text('قبول الطلب وخصم الرصيد'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'reject',
                              child: Text('رفض الطلب'),
                            ),
                          ],
                          onSelected: (String value) {
                            if (value == 'approve') {
                              _approveRequest(email, requestDoc);
                            } else if (value == 'reject') {
                              _rejectRequest(requestDoc);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
