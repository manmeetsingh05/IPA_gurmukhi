import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../LISTE.dart';
import '../Metodi.dart';


class MuharniPage extends StatefulWidget {
  const MuharniPage({super.key});

  @override
  _MuharniPageState createState() => _MuharniPageState();
}

class _MuharniPageState extends State<MuharniPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Metodo per riprodurre l'audio di una combinazione
  void _playAudio(String vowel) {
    String audioPath =
        'SUONI/SILLABE/$vowel.aac'; // Percorso del file audio
    _audioPlayer.play(AssetSource(audioPath));
  }

  // Metodo per navigare alla pagina delle combinazioni
  void _navigateToCombinations(String letter) {
    List<Map<String, String>> combinations = muharniCombinations[letter] ?? [];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SyllablesPage(
          letter: letter,
          combinations: combinations,
          playAudio: _playAudio,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarTitle("Muharni"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // Numero di colonne
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: MuharniBase.length,
          itemBuilder: (context, index) {
            String letter = MuharniBase[index];
            return AnimatedGridButton(
              letter: letter,
              onPressed: () => _navigateToCombinations(letter),
            );
          },
        ),
      ),
    );
  }
}



class SyllablesPage extends StatelessWidget {
  final String letter;
  final List<Map<String, String>> combinations;
  final Function(String) playAudio;

  const SyllablesPage({super.key, 
    required this.letter,
    required this.combinations,
    required this.playAudio,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarTitle("Sillabe per  $letter"),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        children: combinations.map((combination) {
          String symbol = combination.keys.first;
          String pronunciation = combination[symbol]!;

          // Usa `PunjabiLetterTile` per mostrare ogni combinazione
          return PunjabiLetterTile(
            letter: symbol,
            pronunciation: pronunciation,
            onPlay: () => playAudio(symbol), // Riproduci l'audio
          );
        }).toList(),
      ),
    );
  }
}
