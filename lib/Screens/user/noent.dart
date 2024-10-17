import 'package:flutter/material.dart';

class NoentScreen extends StatelessWidget {
  const NoentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Background ImageView equivalent
                Image.asset(
                  'assets/par3.png', // Ensure this asset is included in pubspec.yaml
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                // RelativeLayout equivalent
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/par1.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    height: 400,
                    margin: const EdgeInsets.symmetric(horizontal: 80),
                    padding: const EdgeInsets.all(8),
                    child: Stack(
                      children: [
                        // First LinearLayout equivalent
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/ic_signal_wifi_off_white.png', // Ensure this asset is included in pubspec.yaml
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        'برجاء الاتصال بالإنترنت لمتابعة استخدام التطبيق ',
                                        textAlign: TextAlign.center,
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
                        // Second LinearLayout equivalent
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: NoentScreen(),
  ));
}
