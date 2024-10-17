import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:luckywheel/Screens/user/mainscreen.dart';

class ErrorDiScreen extends StatefulWidget {
  @override
  _ErrorDiScreenState createState() => _ErrorDiScreenState();
}

class _ErrorDiScreenState extends State<ErrorDiScreen> {
  RewardedAd? _rewardedAd;
  bool _isAdLoading = true; // Track ad loading state
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Function to increase shadat
  Future<void> _increaseShadat() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentReference userDocRef =
            firestore.collection('users').doc(user.uid);

        await firestore.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(userDocRef);

          if (snapshot.exists) {
            // Get the 'shadat' field as a String
            String? currentValueString = snapshot.get('shadat') as String?;

            // Convert the String to an int, defaulting to 0 if parsing fails
            int currentValue = int.tryParse(currentValueString ?? '') ?? 0;

            // Increment the value
            int updatedValue = currentValue + 1;

            String? currentValueString1 = updatedValue.toString();

            // Update the value in Firestore
            transaction.update(userDocRef, {'shadat': currentValueString1});
          } else {
            print('User document does not exist.');
          }
        });

        print('Shadat increased!');
      } else {
        print('No user is currently signed in.');
      }
    } catch (e) {
      print('Error updating value in Firestore: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _createRewardedAd();
  }

  void _createRewardedAd() {
    RewardedAd.load(
      adUnitId:
          'ca-app-pub-6433990904386636/8003754425', // Replace with your ad unit ID
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          setState(() {
            _rewardedAd = ad;
            _isAdLoading = false; // Ad finished loading
          });
          print('RewardedAd loaded.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          setState(() {
            _isAdLoading = false; // Ad failed to load
          });
          print('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          },
        ),
      ),
      backgroundColor: const Color(0xFFE8E8E8),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/par_3.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          // Content container
          Positioned(
            top: 200,
            left: 40,
            right: 40,
            bottom: 200,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Play button icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: Image.asset(
                      'assets/vid.png',
                      height: 50,
                      width: 50,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Use a Center widget to center the text
                  const Center(
                    child: Text(
                      'للحصول علي الدورات المجانيه يمكنك مشاهده هذا الاعلان الي النهايه',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Show loading indicator or ad button
                  _isAdLoading
                      ? const CircularProgressIndicator()
                      : GestureDetector(
                          onTap: () async {
                            if (_rewardedAd != null) {
                              _rewardedAd!.show(
                                  onUserEarnedReward: (ad, reward) {
                                print(
                                    'User earned reward: ${reward.amount} ${reward.type}');
                                _increaseShadat(); // Increase shadat after watching the ad
                              });
                            } else {
                              print('Rewarded ad is not available.');
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'مشاهدة',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
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
    );
  }
}
