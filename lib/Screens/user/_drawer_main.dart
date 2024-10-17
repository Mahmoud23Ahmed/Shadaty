import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:luckywheel/Screens/user/Notification.dart';
import 'package:luckywheel/Screens/user/account.dart';
import 'package:luckywheel/Screens/user/daily.dart';
import 'package:luckywheel/Screens/login.dart';
import 'package:luckywheel/Screens/user/redime.dart';
import 'package:luckywheel/Screens/user/refer.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package
import 'package:share_plus/share_plus.dart'; // Import the share_plus package
import 'dart:io'; // Import the dart:io library

class DrawerMainScreen extends StatelessWidget {
  const DrawerMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // White background for the drawer
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 200,
            margin: const EdgeInsets.only(bottom: 20),
            alignment: Alignment.center,
            child: Image.asset(
              'assets/img_3.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
          _buildMenuItem(
            'الحساب  ',
            'assets/ic_account_circle_black.png',
            context,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'الجائزة اليومية',
            'assets/ic_redeem_black.png',
            context,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DailyScreen()),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'السحب  ',
            'assets/wandth.png',
            context,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RedimeScreen()),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'الاشعارات  ',
            const Icon(Icons.notifications),
            context,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationPage()),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            ' دعوه الاصدقاء  ',
            const Icon(Icons.person_add),
            context,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const refer1Screen()),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'دعم العملاء  ',
            'assets/supp.png',
            context,
            () {
              _launchWhatsApp('+905526413151');
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'مشاركة  ',
            'assets/share.png',
            context,
            () {
              String appUrl = '';
              if (Platform.isAndroid) {
                appUrl =
                    'https://play.google.com/store/apps/details?id=com.example.your_app_id';
              } else if (Platform.isIOS) {
                appUrl =
                    'https://apps.apple.com/us/app/your-app-name/idyour_app_id';
              } else {
                appUrl =
                    'https://example.com'; // Default value if platform is neither Android nor iOS
              }
              Share.share('Check out this app: $appUrl');
            },
          ),
          _buildDivider(),
          const SizedBox(height: 50),
          Container(
            margin: const EdgeInsets.only(top: 50),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFBF360C),
              borderRadius: BorderRadius.circular(30), // Rounded corners
            ),
            child: GestureDetector(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'تسجيل خروج',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    'assets/ic_exit_to_app_white.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      String text, dynamic icon, BuildContext context, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (icon is String) // Check if icon is a path string
            Image.asset(
              icon,
              width: 30, // Adjust size as needed
              height: 30,
              fit: BoxFit.contain,
            ),
          if (icon is Icon) // Check if icon is an Icon widget
            icon,
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      color: Color(0xFFBF360C),
    );
  }

  void _launchWhatsApp(String phone) async {
    String url = 'https://wa.me/$phone';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
