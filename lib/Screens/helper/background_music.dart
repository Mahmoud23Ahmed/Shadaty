import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class MusicPlayer with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Initialize and start playback
  Future<void> init() async {
    // Load the music file from assets
    await _audioPlayer.setSource(AssetSource('sounds/music.mp3'));

    // Set the player to loop
    _audioPlayer.setReleaseMode(ReleaseMode.loop);

    // Start playing the music
    await _audioPlayer.play(AssetSource('sounds/music.mp3'));
  }

  // Dispose of the audio player
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
