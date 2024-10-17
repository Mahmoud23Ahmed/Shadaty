import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import the fluttertoast package
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Import Google Mobile Ads
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:luckywheel/Screens/helper/winMessage3.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyScreen extends StatefulWidget {
  const DailyScreen({Key? key}) : super(key: key);

  @override
  _DailyScreenState createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  RewardedAd? _rewardedAd;
  bool _isAdLoading = true;
  bool _hasAdBeenShown = false;
  bool isConnected = false;
  final AudioPlayer _winSoundPlayer = AudioPlayer();
  final AudioPlayer _clickSoundPlayer = AudioPlayer();
  FirebaseFirestore? firestore;
  String currentUserId = 'user1'; // Replace with your actual user ID

  DateTime? lastOpenedDate;
  Timer? _timer;

  int _currentIndex = 0;
  List<String> _cardNumbers = ['1', '2', '3', '4', '5', '6', '10'];

  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      checkAndUpdateGiftStates();
    });
    initializeFlutterFire();
    checkConnectivity();
    Connectivity().onConnectivityChanged.listen((results) {
      setState(() {
        isConnected =
            results.any((result) => result != ConnectivityResult.none);
      });
    });

    _timer = Timer.periodic(Duration(seconds: 8), (timer) {
      if (lastOpenedDate == null ||
          !isSameDay(DateTime.now(), lastOpenedDate!)) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _cardNumbers.length;
        });
        saveLastOpenedDate();
      }
    });

    getLastOpenedDate();

    // Load and show the ad when the screen is opened
    _loadAndShowInterstitialAd();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _interstitialAd?.dispose(); // Dispose the ad
    super.dispose();
  }

  void initializeFlutterFire() async {
    await Firebase.initializeApp();
    firestore = FirebaseFirestore.instance;
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<void> checkAndUpdateGiftStates() async {
    DateTime now = DateTime.now();
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('DailyGift').get();

    for (DocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      DateTime nextGiftDate = DateTime.parse(doc['NextGiftDate']);
      if (isSameDay(now, nextGiftDate)) {
        await FirebaseFirestore.instance
            .collection('DailyGift')
            .doc(doc.id)
            .update({'state': false});
      }
    }
  }

  Future<bool> fetchCardState(String cardNumber) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('DailyGift')
          .where('cardNum', isEqualTo: cardNumber)
          .limit(1)
          .get()
          .then((querySnapshot) => querySnapshot.docs.first);

      return snapshot.get('state') ?? false; // Ensure 'state' is a boolean
    } catch (e) {
      print('Error fetching card state: $e');
      return false; // Return a default value or throw an exception
    }
  }

  Future<void> incrementValueInFirestore(int incrementBy) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentReference userDocRef =
            firestore!.collection('users').doc(user.uid);

        await firestore!.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(userDocRef);

          if (snapshot.exists) {
            int currentValue = int.parse(snapshot.get('value')) ?? 0;
            int updatedValue = currentValue + incrementBy;
            String updatedValueStr = updatedValue.toString();
            transaction.update(userDocRef, {'value': updatedValueStr});
          }
        });
      }
    } catch (e) {
      print('Error updating value in Firestore: $e');
    }
  }

  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  Future<void> getLastOpenedDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dateString = prefs.getString('lastOpenedDate');
    if (dateString != null && dateString.isNotEmpty) {
      lastOpenedDate = DateTime.parse(dateString);
    }
  }

  Future<void> saveLastOpenedDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastOpenedDate', DateTime.now().toIso8601String());
  }

  void _loadAndShowInterstitialAd() {
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

          // Show the ad only if it hasn't been shown yet
          if (!_hasAdBeenShown) {
            _showAd();
            setState(() {
              _hasAdBeenShown = true;
            });
          }
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

  void _showAd() {
    if (_rewardedAd != null && !_isAdLoading) {
      // Pause sound when ad is shown
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          print('User earned reward: ${reward.amount}');
        },
      );
    }
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd?.show();
    }
  }

  void _showCongratulationsDialog(int selectedValue) {
    _winSoundPlayer.play(AssetSource('sounds/win.mp3'));
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CongratulationsDialog3(selectedValue: selectedValue),
        );
      },
    );
  }

  Future<void> _handleClaimButtonTap() async {
    List<QueryDocumentSnapshot> docs =
        (await firestore?.collection('DailyGift').get())?.docs ?? [];
    bool giftAvailable = false;

    for (var doc in docs) {
      String cardNumber = doc.get('cardNum');
      DateTime nextGiftDate = DateTime.parse(doc.get('NextGiftDate'));

      // Check if the NextGiftDate is today
      if (isSameDay(DateTime.now(), nextGiftDate)) {
        // Update the next gift date based on the card number
        switch (cardNumber) {
          case '1':
          case '2':
          case '3':
          case '4':
          case '5':
          case '6':
          case '10':
            nextGiftDate = nextGiftDate.add(Duration(days: 7));
            break;
          default:
            break;
        }

        // Update the Firestore document
        DocumentReference docRef = doc.reference;
        await docRef.update({
          'NextGiftDate':
              DateFormat('yyyy-MM-ddTHH:mm:ss.S').format(nextGiftDate),
          'state': false,
        });
        _showCongratulationsDialog(int.parse(cardNumber));
        // Increment the value in Firestore by the card number's value
        await incrementValueInFirestore(int.parse(cardNumber));

        // Since you only want to open one card at a time, break the loop
        giftAvailable = true;
        break;
      }
    }

    if (!giftAvailable) {
      // Show a toast message if no gift is available
      Fluttertoast.showToast(
          msg: "لقد قمت بالمطالبه بالفعل حاول مره اخري غدا ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Expanded(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg_ref1gjj.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                child: Column(
                  children: [
                    const SizedBox(height: 150),
                    // Connectivity status
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.white,
                      child: Text(
                        isConnected ? 'Server: متصل' : 'Server: غير متصل',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isConnected ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Cards
                    StreamBuilder<QuerySnapshot>(
                      stream: firestore?.collection('DailyGift').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<QueryDocumentSnapshot> docs =
                              snapshot.data!.docs;
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  buildCard(docs, 'assets/pkg.png', '2'),
                                  const SizedBox(width: 16),
                                  buildCard(docs, 'assets/pkg.png', '1'),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  buildCard(docs, 'assets/pkg.png', '4'),
                                  const SizedBox(width: 16),
                                  buildCard(docs, 'assets/pkg.png', '3'),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  buildCard(docs, 'assets/pkg.png', '6'),
                                  const SizedBox(width: 16),
                                  buildCard(docs, 'assets/pkg.png', '5'),
                                ],
                              ),
                              const SizedBox(height: 15),
                              buildLargeCard(docs, 'assets/pkg.png', '10'),
                            ],
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 45),
              // Footer
              GestureDetector(
                onTap: () {
                  _clickSoundPlayer.play(AssetSource('sounds/click.mp3'));
                  _handleClaimButtonTap();
                },
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFe7ac6a),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'مطالبة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard(
      List<QueryDocumentSnapshot> docs, String imagePath, String number) {
    return FutureBuilder<bool>(
      future: fetchCardState(number),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show a loader while waiting
        } else if (snapshot.hasError) {
          return Text('Error fetching state'); // Handle errors
        } else {
          bool isTrue = snapshot.data ?? false;
          return GestureDetector(
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: isTrue ? Color(0xfffe5722) : Color(0xffbf360c),
              child: Container(
                width: 180,
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      imagePath,
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      number,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget buildLargeCard(
      List<QueryDocumentSnapshot> docs, String imagePath, String number) {
    return FutureBuilder<bool>(
      future: fetchCardState(number),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show a loader while waiting
        } else if (snapshot.hasError) {
          return Text('Error fetching state'); // Handle errors
        } else {
          bool isTrue = snapshot.data ?? false;
          return GestureDetector(
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              color: isTrue
                  ? Color.fromARGB(255, 238, 189, 116)
                  : Color(0xffff9700),
              child: Container(
                width: 350,
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      imagePath,
                      width: 60,
                      height: 60,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      number,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
