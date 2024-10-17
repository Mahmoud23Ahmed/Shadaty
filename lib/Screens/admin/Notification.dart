import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationAdmin extends StatefulWidget {
  const NotificationAdmin({Key? key}) : super(key: key);

  @override
  _NotificationAdminState createState() => _NotificationAdminState();
}

class _NotificationAdminState extends State<NotificationAdmin> {
  TextEditingController _textFieldController = TextEditingController();
  TextEditingController _numberFieldController =
      TextEditingController(); // New controller for number field

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            '  الاشعارات  ',
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
            const SizedBox(height: 145),
            Center(
              child: SizedBox(
                width: 200, // Set desired width of the TextField
                child: TextField(
                  controller: _textFieldController,
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.center, // Center text in TextField
                  decoration: const InputDecoration(
                    labelText: 'ادخل  محتوي الاشعار ',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                _sendNotification(); // Call function to send notification
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(70),
                // Make the button take full width
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
              child: const Text('ارسال'),
            ),
          ],
        ),
      ),
    );
  }

  void _sendNotification() async {
    try {
      String notificationMessage =
          _textFieldController.text.trim(); // Get the notification message

      // Check if the message is not empty
      if (notificationMessage.isNotEmpty) {
        // Add notification message to Firestore collection 'Notification'
        await _firestore.collection('Notification').add({
          'message': notificationMessage,
          // Parse the number
          'timestamp': Timestamp.now(),
        });

        // Show success message using SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال الإشعار بنجاح'),
            duration: Duration(seconds: 2), // Adjust the duration as needed
          ),
        );

        // Clear the text fields after sending notification
        _textFieldController.clear();
        _numberFieldController.clear();
      } else {
        // Show error message using SnackBar if the message is empty
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الرجاء إدخال محتوى الإشعار وعدد اللفات'),
            duration: Duration(seconds: 2), // Adjust the duration as needed
          ),
        );
      }
    } catch (e) {
      print('Error sending notification: $e');
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء إرسال الإشعار'),
          duration: Duration(seconds: 2), // Adjust the duration as needed
        ),
      );
    }
  }
}
