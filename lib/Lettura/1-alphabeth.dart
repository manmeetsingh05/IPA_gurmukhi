import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../LISTE.dart';
import '../Metodi.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alfabeto Punjabi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PunjabiAlphabetPage(),
    );
  }
}

class PunjabiAlphabetPage extends StatefulWidget {
  const PunjabiAlphabetPage({super.key});

  @override
  _PunjabiAlphabetPageState createState() => _PunjabiAlphabetPageState();
}

class _PunjabiAlphabetPageState extends State<PunjabiAlphabetPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();



  int _currentIndex = 0; // Tracks the starting index for displayed letters

  // Play the pronunciation audio for a given letter
  void _playAudio(String letter) {
  String audioPath = 'SUONI/ALFABETO/$letter.aac'; // Percorso relativo negli asset
  _audioPlayer.play(AssetSource(audioPath)); // Usa AssetSource per i file negli asset
  }

  // Navigate between pages of letters
  void _navigate(int direction) {
    setState(() {
      _currentIndex += direction * 5;
      // Adjust to show 6 letters on the last page
      if (_currentIndex >= punjabiAlphabet.length - 6 && direction > 0) {
        _currentIndex = punjabiAlphabet.length - 6;
      } else {
        _currentIndex = _currentIndex.clamp(0, punjabiAlphabet.length - 5);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarTitle("Alfabeto"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the list of letters
            Expanded(
              child: ListView.builder(
               padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                shrinkWrap: true,
                itemCount: punjabiAlphabet.length,
                itemBuilder: (context, index) {
                  // Determine how many letters to display (5 or 6)
                  int visibleItems = _currentIndex >= punjabiAlphabet.length - 6 ? 6 : 5;
                  if (index < _currentIndex || index >= _currentIndex + visibleItems) {
                    return SizedBox.shrink(); // Hide letters outside the visible range
                  }
                  return PunjabiLetterTile(
                    letter: punjabiAlphabet[index],
                    pronunciation: punjabiPronunciations[index],
                    onPlay: () => _playAudio(punjabiAlphabet[index]),
                  );
                },
              ),
            ),

            // Navigation buttons
            NavigationButtons(
              currentIndex: _currentIndex,
              maxIndex: punjabiAlphabet.length - 6,
              onNavigate: _navigate,
            ),
          ],
        ),
      ),
    );
  }
}




