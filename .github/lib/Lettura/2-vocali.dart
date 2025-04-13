import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../LISTE.dart';
import '../Metodi.dart';

class PunjabiVowelsPage extends StatefulWidget {
  const PunjabiVowelsPage({super.key});

  @override
  _PunjabiVowelsPageState createState() => _PunjabiVowelsPageState();
}

class _PunjabiVowelsPageState extends State<PunjabiVowelsPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  int _currentIndex = 0;

  // Metodo per riprodurre l'audio di una vocale o segno
  void _playAudio(String sound) {
    String audioPath = 'SUONI/VOCALI-GREZZE-E-COMPLETE/$sound.aac';
    _audioPlayer.play(AssetSource(audioPath));
  }

  // Metodo per navigare tra le pagine
  void _navigate(int direction) {
    setState(() {
      _currentIndex += direction;
      _currentIndex = _currentIndex.clamp(0, (punjabiVowels.length ~/ 2) - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarTitle("Vocali"),
      body: Column(
        children: [
          // Bottone fisso per navigare alla pagina di "segniVocali"
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 80, 0, 10),
            child: Center(
                child: SpecialButton(
                  context: context,
                    title: "Segni Vocali",
                    page: SegniVocaliPage(playAudio: _playAudio))),
          ),
          // Mostra le vocali correnti
          Expanded(
            child: Center(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 50, horizontal: 30),
                itemCount: 2,
                itemBuilder: (context, index) {
                  int actualIndex = _currentIndex * 2 + index;
                  if (actualIndex >= punjabiVowels.length) {
                    return SizedBox.shrink();
                  }
                  return PunjabiLetterTile(
                    letter: punjabiVowels[actualIndex],
                    pronunciation: punjabiVowelPronunciations[actualIndex],
                    onPlay: () => _playAudio(punjabiVowels[actualIndex]),
                  );
                },
              ),
            ),
          ),
          // Pulsanti di navigazione
          NavigationButtons(
            currentIndex: _currentIndex,
            maxIndex: (punjabiVowels.length ~/ 2) - 1,
            onNavigate: _navigate,
          ),
        ],
      ),
    );
  }
}

// Pagina per mostrare i "segni vocali"
class SegniVocaliPage extends StatelessWidget {
  final Function(String) playAudio;

  const SegniVocaliPage({super.key, required this.playAudio});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarTitle("Segni Vocali"),
      body: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: segniVocali.length,
        itemBuilder: (context, index) {
          MapEntry<String, String> entry = segniVocali[index].entries.first;
          return PunjabiLetterTile(
            letter: entry.key,
            pronunciation: entry.value,
            onPlay: () => playAudio(entry.value),
          );
        },
      ),
    );
  }
}
