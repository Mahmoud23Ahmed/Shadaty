import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clipboard/clipboard.dart';

class refer1Screen extends StatefulWidget {
  const refer1Screen({Key? key}) : super(key: key);

  @override
  _Refer1Screen createState() => _Refer1Screen();
}

class _Refer1Screen extends State<refer1Screen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _referralCodeController = TextEditingController();
  final TextEditingController _CodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchReferralCode();
  }

  Future<void> _fetchReferralCode() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          String referralCode = userDoc.get('code') ?? '000000';
          setState(() {
            _referralCodeController.text = referralCode;
          });
        } else {
          print('User document does not exist');
        }
      }
    } catch (e) {
      print('Error fetching referral code: $e');
    }
  }

  Future<void> _addReferralCodeToList(String referralCode) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Step 1: Check if the referral code exists in any user's 'code' field
        QuerySnapshot codeQuerySnapshot = await _firestore
            .collection('users')
            .where('code', isEqualTo: referralCode)
            .get();

        if (codeQuerySnapshot.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('الرمز خطأ')),
          );
          print('Referral code does not exist in any user document');
          return; // Exit function early if code does not exist in 'code' field
        }

        // Step 2: Fetch current user's document
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          List<dynamic> invitationCodes = userDoc.get('InvitationCode');
          // ignore: unnecessary_null_comparison
          if (invitationCodes != null) {
            // Step 3: Check if the referral code already exists in current user's 'InvitationCode' array
            if (invitationCodes.contains(referralCode)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('هذا الرمز تم ادخاله من قبل')),
              );
              print('Referral code already exists in user\'s InvitationCode');
            } else {
              // Step 4: Check if the referral code belongs to the current user
              if (userDoc.get('code') == referralCode) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('لا يمكنك ادخال رمز إحالتك')),
                );
                print('Referral code belongs to the current user');
              } else {
                // Step 5: Update current user's document with the new referral code and increase shadat count
                await _firestore.collection('users').doc(user.uid).update({
                  'InvitationCode': FieldValue.arrayUnion([referralCode]),
                  'shadat':
                      (userDoc.get('shadat') ?? 0) + 1, // Increment shadat by 1
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم اضافة الرمز بنجاح'),
                  ),
                );
                print('Referral code added successfully');
              }
            }
          } else {
            // Step 6: Initialize InvitationCode field as an empty array and add the referral code
            await _firestore.collection('users').doc(user.uid).update({
              'InvitationCode': [referralCode],
              'shadat': 1, // Initialize shadat to 1
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم اضافة الرمز بنجاح'),
              ),
            );
            print('Referral code added successfully');
          }
        } else {
          print('User document does not exist');
        }
      }
    } catch (e) {
      print('Error adding referral code to list: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشلت الدعوة. يرجى المحاولة مرة أخرى.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/bg_ref1gjj.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(30),
                    child: const Row(
                      children: [
                        // Add children here
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/img__2.png',
                    width: 150,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  Column(
                    children: [
                      const Text(
                        'أدخل رمز إحالة الصديق',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                        controller: _CodeController,
                        decoration: const InputDecoration(
                          hintText: 'xxxxxx',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextButton(
                        onPressed: () {
                          String enteredCode = _CodeController.text.trim();
                          if (enteredCode.isNotEmpty) {
                            _addReferralCodeToList(enteredCode);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('الرجاء إدخال رمز الإحالة'),
                              ),
                            );
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue),
                        ),
                        child: const Text(
                          'تأكيد',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                  const Text(
                    'قم بدعوة الأصدقاء أو العائلة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _referralCodeController.text,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextButton(
                    onPressed: () {
                      FlutterClipboard.copy(_referralCodeController.text)
                          .then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم نسخ الرمز إلى الحافظة'),
                          ),
                        );
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                    ),
                    child: const Text(
                      'Tap to Copy',
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
          ],
        ),
      ),
    );
  }
}
