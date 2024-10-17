import 'package:flutter/material.dart';

class HistScreen extends StatelessWidget {
  const HistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Layout')),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            // Horizontal Row equivalent
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  // First TextView equivalent
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '00-00-00',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Second TextView equivalent
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '500 uc',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF5722),
                      ),
                    ),
                  ),
                  // Empty space (Expanded)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                    ),
                  ),
                  // Third TextView equivalent
                  Container(
                    color: const Color(0xFFFFA000),
                    padding: const EdgeInsets.all(8.0),
                    child: const Center(
                      child: Text(
                        'جار المعالجة',
                        style: TextStyle(
                          fontSize: 16,
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
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: HistScreen(),
  ));
}
