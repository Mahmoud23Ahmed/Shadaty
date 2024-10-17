import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class adsDialog extends StatefulWidget {
  final int selectedValue;

  adsDialog({required this.selectedValue});

  @override
  _adsDialogState createState() => _adsDialogState();
}

class _adsDialogState extends State<adsDialog> {
  RewardedAd? _rewardedAd;
  bool _isAdLoading = true;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final AudioPlayer _clickSoundPlayer = AudioPlayer();

  Future<void> _increaseShadat() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentReference userDocRef =
            firestore.collection('users').doc(user.uid);

        await firestore.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(userDocRef);

          if (snapshot.exists) {
            String? currentValueString = snapshot.get('shadat') as String?;
            int currentValue = int.tryParse(currentValueString ?? '') ?? 0;
            int updatedValue = currentValue + 1;

            String? currentValueString1 = updatedValue.toString();
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
            _isAdLoading = false;
          });
          print('RewardedAd loaded.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          setState(() {
            _isAdLoading = false;
          });
          print('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 300,
        maxHeight: 400,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.only(top: 40, bottom: 40),
              decoration: BoxDecoration(
                color: const Color(0xfffe5722),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: Colors.orange, width: 5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/vid.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  Material(
                    type: MaterialType.transparency,
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'للحصول علي الدورات المجانيه يمكنك \n مشاهده هذا الاعلان حتي النهايه ',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: 150,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.orange, width: 5),
                      ),
                      child: Material(
                        type: MaterialType.transparency,
                        child: _isAdLoading
                            ? const CircularProgressIndicator()
                            : GestureDetector(
                                onTap: () async {
                                  _clickSoundPlayer
                                      .play(AssetSource('sounds/click.mp3'));
                                  if (_rewardedAd != null) {
                                    _rewardedAd!.show(
                                      onUserEarnedReward: (ad, reward) {
                                        print(
                                            'User earned reward: ${reward.amount} ${reward.type}');
                                        _increaseShadat();
                                        Navigator.pop(
                                            context); // Close dialog after showing the ad
                                      },
                                    );
                                  } else {
                                    print('Rewarded ad is not available.');
                                    // Optionally, you can reload the ad here or handle the scenario
                                  }
                                },
                                child: const Center(
                                  child: Text(
                                    'مشاهدة',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              constraints: const BoxConstraints(
                maxHeight: 500,
              ),
              child: Image.asset(
                'assets/par_3.png',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
