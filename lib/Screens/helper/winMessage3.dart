import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class CongratulationsDialog3 extends StatefulWidget {
  final int selectedValue;

  CongratulationsDialog3({required this.selectedValue});

  @override
  _CongratulationsDialog3State createState() => _CongratulationsDialog3State();
}

class _CongratulationsDialog3State extends State<CongratulationsDialog3> {
  final AudioPlayer _clickSoundPlayer = AudioPlayer();

  @override
  void dispose() {
    // Dispose the click sound player
    super.dispose();
  }

  Future<void> _playClickSound() async {
    await _clickSoundPlayer.setSourceAsset('sounds/coin_add.mp3');
    await _clickSoundPlayer.resume();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 300, // Limit the maximum width
        maxHeight: 400, // Limit the maximum height
      ),
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
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.only(top: 60, bottom: 60),
              decoration: BoxDecoration(
                color: const Color(0xfffe5722), // Background color
                borderRadius: BorderRadius.circular(50), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // Changes position of shadow
                  ),
                ],
                border: Border.all(color: Colors.orange, width: 5),
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
                  const SizedBox(height: 10), // Spacing between image and text
                  Material(
                    type: MaterialType.transparency, // Add this line
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: widget.selectedValue == 0
                                ? 'اوبس \n'
                                : 'تهانينا  \n',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(
                            text: 'من الهدايا اليوميه  ',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(
                            text: 'uc لقد حصلت علي ',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: '${widget.selectedValue} ',
                            style: const TextStyle(
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
                  const SizedBox(height: 35),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Background color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      side: BorderSide(color: Colors.orange, width: 5),
                    ),
                    onPressed: () async {
                      await _playClickSound(); // Play the click sound
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'يجمع',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
                height: 20), // Add some space between the two containers
            Container(
              constraints: const BoxConstraints(
                maxHeight: 500, // Limit the maximum height of the image
              ),
              child: Image.asset(
                'assets/par_3.png',
                fit: BoxFit.cover, // Ensure the image covers the container
              ),
            ),
          ],
        ),
      ),
    );
  }
}
