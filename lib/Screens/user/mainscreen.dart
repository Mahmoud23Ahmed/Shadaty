import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:luckywheel/Screens/helper/adsWatch.dart';
import 'package:luckywheel/Screens/helper/winMessage.dart';
import 'package:luckywheel/Screens/helper/winMessage2.dart';
import 'package:luckywheel/Screens/user/_drawer_main.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  String buttonText = 'Loading...';
  final selected = BehaviorSubject<int>();
  String shadat = '';
  String value = '0';

  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      _giftSubscription;
  RewardedAd? _rewardedAd;
  Timer? _timer;
  bool _isAdLoading = true;
  bool _hasAdBeenShown = false; // Flag to track if ad has been shown
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late AnimationController _textAnimationController;
  late Animation<double> _textAnimation;
  bool isSpinEnabled = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final AudioPlayer _winSoundPlayer = AudioPlayer();
  final AudioPlayer _clickSoundPlayer = AudioPlayer();
  final List<int> wheelValues = [1, 2, 4, 5, 8, 10, 40, 0];
  int selectedValue = 0;
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> _subscription;
  final AudioPlayer _spinSoundPlayer = AudioPlayer();
  String nextGiftDateStr = "";

  @override
  void initState() {
    super.initState();
    _fetchNextGiftDate();
    _setupRealTimeListener();
    _startTimer();
    // Initialize Ad
    _createRewardedAd();

    // Initialize Animation Controllers
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _textAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _textAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 15, // Rotate to 15 degrees
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward(); // Start the rotation animation

    // Fetch data and update state
    _getData();

    _spinSoundPlayer.setReleaseMode(ReleaseMode.stop);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textAnimationController.dispose();
    _controller.dispose();
    selected.close();
    _subscription.cancel();
    _spinSoundPlayer.dispose();
    _clickSoundPlayer.dispose();
    _winSoundPlayer.dispose();
    _giftSubscription.cancel();
    super.dispose();
  }

  void _pauseSound() {
    _winSoundPlayer.pause();
    _clickSoundPlayer.pause();
    _spinSoundPlayer.pause();
  }

  void _resumeSound() {
    _winSoundPlayer.resume();
    _clickSoundPlayer.resume();
    _spinSoundPlayer.resume();
  }

  void _setupRealTimeListener() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userEmail = user.email!;
      _giftSubscription = FirebaseFirestore.instance
          .collection('hourgift')
          .where('email', isEqualTo: userEmail)
          .snapshots()
          .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.docs.isNotEmpty) {
          var doc = snapshot.docs.first;
          DateTime now = DateTime.now();
          DateTime nextGiftDate = DateTime.parse(doc['nextGiftDate']);
          final difference = nextGiftDate.difference(now);
          final hourDifference = difference.inHours;

          setState(() {
            if (hourDifference >= 1) {
              buttonText = 'جمع'; // It's time to collect the gift
            } else {
              buttonText = DateFormat('jm').format(nextGiftDate);
            }
          });
        } else {
          setState(() {
            buttonText = 'جمع'; // Default state if no document
          });
        }
      });
    } else {
      setState(() {
        buttonText = 'User not logged in';
      });
    }
  }

  Future<void> _fetchNextGiftDate() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DateTime now = DateTime.now();
        String userEmail = user.email!;

        var querySnapshot = await FirebaseFirestore.instance
            .collection('hourgift')
            .where('email', isEqualTo: userEmail)
            .get();

        print('Query Snapshot: ${querySnapshot.docs.length}');

        if (querySnapshot.docs.isNotEmpty) {
          var doc = querySnapshot.docs.first;
          DateTime nextGiftDate = DateTime.parse(doc['nextGiftDate']);
          nextGiftDateStr = DateTime.parse(doc['nextGiftDate']).toString();
          print('Next Gift Date: $nextGiftDate');

          final difference = nextGiftDate.difference(now);
          final hourDifference = difference.inHours;

          setState(() {
            if (hourDifference >= 1) {
              // If the difference is 0 or less, it means it's time to collect the gift
              buttonText = 'جمع';
            } else {
              // Otherwise, show the next gift date

              buttonText = DateFormat('jm').format(nextGiftDate);
            }
          });
        } else {
          setState(() {
            buttonText = 'جمع';
          });
        }
      } else {
        setState(() {
          buttonText = 'User not logged in';
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        buttonText = 'Error fetching date';
      });
    }
  }

  void _createRewardedAd() {
    RewardedAd.load(
      adUnitId:
          'ca-app-pub-64339909043866536/4206727604', // Replace with your ad unit ID
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
      _pauseSound(); // Pause sound when ad is shown
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          print('User earned reward: ${reward.amount}');
        },
      );
    }
  }

  Future<void> _getData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _subscription = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data()!;
          setState(() {
            shadat = data['shadat']?.toString() ?? 'No data';
            value = data['value']?.toString() ?? '0';
            isSpinEnabled = int.parse(shadat) > 0;
          });
        } else {
          setState(() {
            shadat = 'User data not found';
          });
        }
      });
    } else {
      setState(() {
        shadat = 'Not logged in';
      });
    }
  }

  Future<void> _spinWheel() async {
    if (int.parse(shadat) == 0) {
      // If shadat is 0, show the ads dialog
      _showadsDialog();
      return;
    }

    if (!isSpinEnabled) return;

    // Play the spin sound
    _spinSoundPlayer.play(AssetSource('sounds/spin.mp3'));

    final random = Random();

    // Initialize spinValue
    int spinValue;

    // Check if the user's value is >= 400
    if (int.parse(value) >= 400) {
      // If so, the spinValue is either 0 or 1
      spinValue = random.nextBool() ? 0 : 1;
      print('Pinwheel value: $spinValue');
    } else {
      // If value is less than 400, choose between 10 or 40
      spinValue = random.nextBool() ? 10 : 40;
      print('Spinwheel value for < 400: $spinValue');
    }

    setState(() {
      selectedValue = spinValue;
      selected.add(wheelValues.indexOf(spinValue));
    });

    _controller.forward().then((_) async {
      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        // Update the value and decrease shadat
        value = (int.parse(value) + selectedValue).toString();
        if (int.parse(shadat) > 0) {
          shadat = (int.parse(shadat) - 1).toString();
        }
        isSpinEnabled = int.parse(shadat) > 0;
      });

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          // Update user data in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'value': value,
            'shadat': shadat,
          });
        } catch (e) {
          // Handle the error if needed
          print('Error updating Firestore: $e');
        }
      } else {
        // Handle the case where user is not logged in
        print('User not logged in.');
      }

      // Reset the controller
      _controller.reset();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkNextGiftDate();
    });
  }

  void _checkNextGiftDate() {
    DateTime now = DateTime.now();
    DateTime nextGiftDate = DateTime.parse(nextGiftDateStr);

    if (now.isAfter(nextGiftDate) || now.isAtSameMomentAs(nextGiftDate)) {
      setState(() {
        buttonText = 'جمع';
      });
    }
  }

  Future<void> _updateHourlyGift() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DateTime now = DateTime.now();
        String userEmail = user.email!;

        // Retrieve the document for the current user in the hourgift collection
        var querySnapshot = await FirebaseFirestore.instance
            .collection('hourgift')
            .where('email', isEqualTo: userEmail)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Document exists, check the nextGiftDate
          var doc = querySnapshot.docs.first;
          DateTime nextGiftDate = DateTime.parse(doc['nextGiftDate']);

          // Check if nextGiftDate is at least one hour from now
          if (now.isAfter(nextGiftDate) || now.isAtSameMomentAs(nextGiftDate)) {
            // Update the shadat in the hourgift collection
            await FirebaseFirestore.instance
                .collection('hourgift')
                .doc(doc.id)
                .update({
              'nextGiftDate': now
                  .add(Duration(hours: 1))
                  .toIso8601String(), // Update nextGiftDate
            });

            // Increment the shadat value in the users collection
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({
              'shadat': FieldValue.increment(1), // Increment the shadat value
            });

            _showCongratulationsDialoghours();
          } else {
            nextGiftDateStr = DateFormat('jm').format(nextGiftDate);
            _showMessageToast(
                'سوف تكون قادر علي جمع المكافأه في $nextGiftDateStr ');
          }
        } else {
          // Document does not exist, create a new one
          DateTime nextGiftDate = now.add(Duration(hours: 1));
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'shadat': FieldValue.increment(1), // Increment the shadat value
          });

          await FirebaseFirestore.instance.collection('hourgift').add({
            'email': userEmail,
            'nextGiftDate': nextGiftDate.toIso8601String(),
          });

          _showCongratulationsDialoghours();
        }
      } else {
        _showMessage('User not logged in');
      }
    } catch (e) {
      _showMessage('Error updating gift: $e');
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

  void _showMessage(String message) {
    // Display a message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showCongratulationsDialog() {
    _winSoundPlayer.play(AssetSource('sounds/win.mp3'));
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CongratulationsDialog(selectedValue: selectedValue),
        );
      },
    );
  }

  void _showCongratulationsDialoghours() {
    _winSoundPlayer.play(AssetSource('sounds/win.mp3'));
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CongratulationsDialog2(selectedValue: 1),
        );
      },
    );
  }

  void _showadsDialog() {
    _winSoundPlayer.play(AssetSource('sounds/win.mp3'));
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: adsDialog(selectedValue: 1),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: SizedBox(
        width: screenWidth / 2,
        child: const DrawerMainScreen(),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/main_background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 50),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenHeight * 0.001,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenHeight * 0.001,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1DEBD),
                      borderRadius: BorderRadius.circular(25.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Image.asset('assets/spin.png',
                            width: screenWidth * 0.06,
                            height: screenHeight * 0.03),
                        const SizedBox(width: 8),
                        Text(
                          shadat,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenHeight * 0.001,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        _scaffoldKey.currentState?.openEndDrawer();
                      },
                      child: Image.asset(
                        'assets/ic_border_all_white.png',
                        width: screenWidth * 0.09,
                        height: screenHeight * 0.05,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: screenHeight * 0.001,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1DEBD),
                        borderRadius: BorderRadius.circular(25.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/baka.png',
                              width: screenWidth * 0.06,
                              height: screenHeight * 0.02),
                          const SizedBox(width: 8),
                          Text(
                            value,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 50, left: 25),
                            child: SizedBox(
                              height: screenHeight * 0.39, // Increased height
                              width: screenWidth * 0.83, // Increased width
                              child: FortuneWheel(
                                selected: selected.stream,
                                animateFirst: false,
                                items: [
                                  for (int i = 0; i < wheelValues.length; i++)
                                    FortuneItem(
                                      style: FortuneItemStyle(
                                        color: i % 2 == 0
                                            ? const Color(0xfff1debd)
                                            : Colors.white,
                                        borderColor: Colors.white,
                                        borderWidth: 2,
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      child: Text(
                                        wheelValues[i].toString(),
                                        style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 25,
                                        ),
                                      ),
                                    ),
                                ],
                                onAnimationEnd: () {
                                  setState(() {
                                    selectedValue = wheelValues[selected.value];
                                  });
                                  _showCongratulationsDialog(); // Show the dialog
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            bottom: 10,
                            child: Container(
                              width: screenWidth * 1.2, // Increased width
                              height: screenHeight * 1.2, // Increased height
                              child: Image.asset(
                                'assets/icon2.png',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 25),
                            child: Positioned(
                              child: Image.asset(
                                'assets/img.png',
                                width: screenWidth * 0.6, // Increased width
                                height: screenHeight * 0.6, // Increased height
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: screenHeight * 0.015, // Reduced padding
                        left: screenWidth *
                            0.35, // Increased left padding for a smaller button
                        right: screenWidth *
                            0.35, // Increased right padding for a smaller button
                      ),
                      child: GestureDetector(
                        onTap: () {
                          _clickSoundPlayer
                              .play(AssetSource('sounds/click.mp3'));
                          _spinWheel();
                        },
                        child: AnimatedBuilder(
                          animation: _textAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _textAnimation.value,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        screenWidth * 0.04, // Adjusted width
                                    vertical:
                                        screenHeight * 0.01), // Adjusted height
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFf3d34a),
                                      Color(0xFFf3d34a)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      30), // Adjusted border radius
                                  border: Border.all(
                                    color: const Color(0xFFfe6527),
                                    width: 5, // Adjusted border width
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'التدوير',
                                    style: TextStyle(
                                        fontSize: screenWidth *
                                            0.03, // Adjusted font size
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: screenWidth * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          _clickSoundPlayer
                              .play(AssetSource('sounds/click.mp3'));
                          await _updateHourlyGift(); // Check and update the hourly gift
                          // Optionally perform other actions if needed
                        },
                        child: Column(
                          children: [
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                // Determine the current angle based on animation progress
                                double angle = _rotationAnimation.value;
                                if (_controller.value > 0.5) {
                                  angle = 15 -
                                      (angle - 15); // Move back to 0 degrees
                                }
                                return Transform.rotate(
                                  angle: angle *
                                      pi /
                                      180, // Convert degrees to radians
                                  child: Column(
                                    children: [
                                      Image.asset('assets/box.png',
                                          width: screenWidth * 0.2,
                                          height: screenHeight * 0.1),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.04),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Colors.orange,
                                              Colors.yellow
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(
                                            buttonText,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Text(
                        DateFormat('d-M-y').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
