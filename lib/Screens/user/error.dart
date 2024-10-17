import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/bgc.png'), // Replace with your drawable background image
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // HorizontalScrollView equivalent
            Container(
              height: 100, // Adjust height as needed
              child: ListView(
                scrollDirection: Axis.horizontal,
              ),
            ),
            SizedBox(height: 16), // Space between elements
            // ImageView equivalent
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/ic_block_white.png'), // Replace with your drawable image
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16), // Space between elements
            // TextView equivalent
            const Text(
              'التطبيق في وضع الصيانة الان',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16), // Space between elements
            // HorizontalScrollView equivalent
            Container(
              height: 100, // Adjust height as needed
              child: ListView(
                scrollDirection: Axis.horizontal,
              ),
            ),
            const SizedBox(height: 16), // Space between elements
            // TextView equivalent
            const Text(
              'error',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16), // Space between elements
            // HorizontalScrollView equivalent
            Container(
              height: 100, // Adjust height as needed
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Add children here
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ErrorScreen(),
  ));
}
