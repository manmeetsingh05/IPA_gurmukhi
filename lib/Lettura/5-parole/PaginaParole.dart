import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:impara_gurbani/LISTE.dart';
import 'package:impara_gurbani/Metodi.dart';

class DynamicWordsPage extends StatefulWidget {
  final String vowel;
  final List<String> words;
  final List<String> pronunciations;
  final String audioPath;

  const DynamicWordsPage({
    super.key,
    required this.vowel,
    required this.words,
    required this.pronunciations,
    required this.audioPath,

  });

  @override
  _DynamicWordsPageState createState() => _DynamicWordsPageState();
} 

class _DynamicWordsPageState extends State<DynamicWordsPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentIndex = 0; 
  late double _maxWordWidth; // Larghezza massima calcolata

  @override
  void initState() {
    super.initState();
    
    // Calcola la larghezza massima per la parola più lunga
    _maxWordWidth = 0; 
    final textStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );

    double tempMax = 0;
    for (var word in MuktaWords) {
      // Misura la larghezza della parola
      final width = measureTextWidth(word, textStyle);
      // Aggiungi un margine (ad esempio 32 pixel totali per padding)
      final totalWidth = width + 30; 
      if (totalWidth > tempMax) {
        tempMax = totalWidth;
      }
    }
    _maxWordWidth = tempMax+25;
  }

  /// Funzione di utilità per misurare la larghezza del testo
  double measureTextWidth(String text, TextStyle style) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.size.width;
  }

  /// Riproduce l'audio della parola
  void _playAudio(String letter) {
    final audioPath = '${widget.audioPath}/$letter.aac';
    _audioPlayer.play(AssetSource(audioPath));
  }

  /// Naviga tra le pagine (8 parole per volta)
  void _navigate(int direction) {
    setState(() {
      _currentIndex += direction * 8; 
      _currentIndex = _currentIndex.clamp(0, MuktaWords.length - 8);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarTitle(widget.vowel),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Visualizza la lista delle parole (8 per pagina)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                itemCount: MuktaWords.length,
                itemBuilder: (context, index) {
                  const visibleItems = 8;
                  if (index < _currentIndex || index >= _currentIndex + visibleItems) {
                    return const SizedBox.shrink(); // Nascondi parole fuori dalla pagina corrente
                  }
                  return PunjabiWordTile(
                    word: widget.words[index],
                    pronunciation: widget.pronunciations[index],
                    onPlay: () => _playAudio(widget.words[index]),
                    maxWidth: _maxWordWidth, // Passa la larghezza massima calcolata
                  );
                },
              ),
            ),

            // Bottoni di navigazione
            NavigationButtons(
              currentIndex: _currentIndex,
              maxIndex: MuktaWords.length - 8,
              onNavigate: _navigate,
            ),
          ],
        ),
      ),
    );
  }
}




