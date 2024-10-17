import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ValuePage extends StatefulWidget {
  const ValuePage({Key? key}) : super(key: key);

  @override
  _ValuePageState createState() => _ValuePageState();
}

class _ValuePageState extends State<ValuePage> {
  bool _isForIncrease = true;
  TextEditingController _textFieldController = TextEditingController();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            ' رصيد المستخدمين ',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 173, 131, 69),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(width: 50),
                const Text(' زياده'),
                Radio<bool>(
                  value: true,
                  groupValue: _isForIncrease,
                  onChanged: (value) {
                    setState(() {
                      _isForIncrease = value!;
                    });
                  },
                ),
                const SizedBox(width: 50),
                const Text(' نقص'),
                Radio<bool>(
                  value: false,
                  groupValue: _isForIncrease,
                  onChanged: (value) {
                    setState(() {
                      _isForIncrease = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 70),
            const Center(
              child: Text(
                'لجميع المستخدمين',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 60),
            Center(
              child: SizedBox(
                width: 200,
                child: TextField(
                  controller: _textFieldController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'ادخل الرصيد هنا',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateFirestore,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
              child: const Text('متابعة'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateFirestore() async {
    // Get the value from the TextField
    String inputValue = _textFieldController.text.trim();
    int value = int.tryParse(inputValue) ?? 0;

    // Determine increment or decrement based on radio button selection
    int incrementValue = _isForIncrease ? value : -value;

    try {
      // Update Firestore collection 'users'
      await _firestore.collection('users').get().then((snapshot) {
        snapshot.docs.forEach((doc) async {
          await _firestore.collection('users').doc(doc.id).update({
            'value': FieldValue.increment(incrementValue),
          });
        });
      });

      // Show success message using SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت التعديلات على رصيد المستخدمين'),
          duration: Duration(seconds: 2),
        ),
      );

      print('Firestore updated successfully.');
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }
}