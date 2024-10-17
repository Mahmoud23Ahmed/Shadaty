import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:luckywheel/Screens/user/end.dart';

class RedimeScreen extends StatefulWidget {
  const RedimeScreen({super.key});

  @override
  State<RedimeScreen> createState() => _RedimeScreenState();
}

class _RedimeScreenState extends State<RedimeScreen> {
  bool _showRewards = false;
  bool _showTransactions = false;
  bool _transactionsSelected = false;
  bool _rewardsSelected = false;

  @override
  void initState() {
    super.initState();
    _showRewards = true; // Make السحب the default visible section
    _rewardsSelected = true;
    _showTransactions = false;
    _transactionsSelected = false;
  }

  Future<String> _getUserValue() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final User? user = _auth.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          return userDoc['value']?.toString() ?? '0';
        } else {
          return '0'; // Return default value if document does not exist
        }
      } catch (e) {
        print('Error fetching user value: $e');
        return '0'; // Return default value in case of error
      }
    } else {
      return '0'; // Return default value if no user is logged in
    }
  }

  Future<List<Map<String, dynamic>>> _getPubgIdRecords() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final User? user = _auth.currentUser;

    if (user != null) {
      try {
        QuerySnapshot pubgIdDocs = await _firestore
            .collection('pubgIds')
            .where('email', isEqualTo: user.email)
            .get();

        return pubgIdDocs.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      } catch (e) {
        print('Error fetching PUBG IDs: $e');
        return []; // Return empty list in case of error
      }
    } else {
      return []; // Return empty list if no user is logged in
    }
  }

  Future<bool> _canNavigateToEndScreen500() async {
    final userValue = await _getUserValue();
    final value = int.tryParse(userValue) ?? 0;
    return value >= 500;
  }

  Future<bool> _canNavigateToEndScreen1000() async {
    final userValue = await _getUserValue();
    final value = int.tryParse(userValue) ?? 0;
    return value >= 1000;
  }

  Future<bool> _canNavigateToEndScreen1500() async {
    final userValue = await _getUserValue();
    final value = int.tryParse(userValue) ?? 0;
    return value >= 1500;
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
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/bg_ref1gjj.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 250,
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/boton.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'السحب',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          '     شدة   ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: FutureBuilder<String>(
                            future: _getUserValue(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text(
                                  'Loading...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return const Text(
                                  'Error',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                );
                              } else {
                                return Text(
                                  snapshot.data ?? '0',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        const Text(
                          '     : الرصيد المتوفر',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 2,
                      color: const Color(0xFFFF5722),
                      margin: const EdgeInsets.only(top: 50),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              _showRewards = false;
                              _showTransactions = true;
                              _transactionsSelected = true;
                              _rewardsSelected = false;
                            });
                          },
                          child: Container(
                            width: 180,
                            height: 35,
                            decoration: BoxDecoration(
                              color: _transactionsSelected
                                  ? const Color(0xFFFF5722)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              'المعاملات',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 31,
                        ),
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              _showRewards = true;
                              _showTransactions = false;
                              _transactionsSelected = false;
                              _rewardsSelected = true;
                            });
                          },
                          child: Container(
                            width: 180,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _rewardsSelected
                                  ? const Color(0xFFFF5722)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              'السحب',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 2,
                      color: const Color(0xFFFF5722),
                      margin: const EdgeInsets.only(top: 1),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: Visibility(
                        visible: _showRewards,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                bool canNavigate =
                                    await _canNavigateToEndScreen500();
                                if (canNavigate) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const EndScreen(
                                              Widgetvalue: 500,
                                            )),
                                  );
                                } else {
                                  _showMessageToast('لا يوجد رصيد كافي');
                                }
                              },
                              child: Container(
                                width: 350,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 150,
                                      height: 55,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          'assets/pkg.png',
                                          width: 55,
                                          height: 55,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 200,
                                      padding: const EdgeInsets.all(15),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF5722),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          '500 uc',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            GestureDetector(
                              onTap: () async {
                                bool canNavigate =
                                    await _canNavigateToEndScreen1000();
                                if (canNavigate) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EndScreen(
                                              Widgetvalue: 1000,
                                            )),
                                  );
                                } else {
                                  _showMessageToast('لا يوجد رصيد كافي');
                                }
                              },
                              child: Container(
                                width: 350,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 350,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 150,
                                            height: 55,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                'assets/pkg.png',
                                                width: 55,
                                                height: 55,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 200,
                                            padding: const EdgeInsets.all(15),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFFF5722),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                '1000 uc',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            GestureDetector(
                              onTap: () async {
                                bool canNavigate =
                                    await _canNavigateToEndScreen1500();
                                if (canNavigate) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EndScreen(
                                              Widgetvalue: 1500,
                                            )),
                                  );
                                } else {
                                  _showMessageToast('لا يوجد رصيد كافي');
                                }
                              },
                              child: Container(
                                width: 350,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 150,
                                      height: 55,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          'assets/pkg.png',
                                          width: 55,
                                          height: 55,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 200,
                                      padding: const EdgeInsets.all(15),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF5722),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          '1500 uc',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _showTransactions,
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: _getPubgIdRecords(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return const Center(
                              child: Text('Error fetching records'),
                            );
                          } else {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data?.length,
                              itemBuilder: (context, index) {
                                // Fetching the date and value
                                final date =
                                    snapshot.data?[index]['date'].toString() ??
                                        '';
                                final value =
                                    snapshot.data?[index]['value'].toString() ??
                                        '';

                                return Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                        'التاريخ : $date',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'قيمه السحب : $value',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const Divider(
                                      color: Colors
                                          .grey, // Set the color of the divider
                                      thickness:
                                          1.0, // Set the thickness of the divider
                                      indent:
                                          16.0, // Optional: indent from the left
                                      endIndent:
                                          16.0, // Optional: indent from the right
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
