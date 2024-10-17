import 'package:flutter/material.dart';

void main() {
  runApp(const WinDialogScreen());
}

class WinDialogScreen extends StatelessWidget {
  const WinDialogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        backgroundColor: Colors.grey[900], // Background color of the screen
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400, // Limit the maximum width
              maxHeight: 600, // Limit the maximum height
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 180),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Adjust the Column to the content size
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center children vertically
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Center children horizontally
                  children: [
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal, // Background color
                        borderRadius:
                            BorderRadius.circular(15), // Rounded corners
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // Changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/img__2.png',
                            width: 60, // Adjust width as needed
                            height: 60, // Adjust height as needed
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(
                              height: 10), // Spacing between image and text
                          const Text(
                            'Congratulations!\nYou got 20 coins from daily reward.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.orange, // Background color
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'يجمع',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                        height:
                            20), // Add some space between the two containers
                    Container(
                      constraints: const BoxConstraints(
                        maxHeight: 500, // Limit the maximum height of the image
                      ),
                      child: Image.asset(
                        'assets/par_3.png',
                        fit: BoxFit
                            .cover, // Ensure the image covers the container
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
