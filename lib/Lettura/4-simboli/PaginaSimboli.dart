import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:impara_gurbani/Metodi.dart';

class DynamicSymbolPage extends StatefulWidget {
  final String title;
  final List<String> words;
  final List<String> pronunciations;
  final String audioPathPrefix;

  const DynamicSymbolPage({
    Key? key,
    required this.title,
    required this.words,
    required this.pronunciations,
    required this.audioPathPrefix,
  }) : super(key: key);

  @override
  _DynamicSymbolPageState createState() => _DynamicSymbolPageState();
}

class _DynamicSymbolPageState extends State<DynamicSymbolPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentIndex = 0;
  late double _maxWordWidth;

  @override
  void initState() {
    super.initState();
    _maxWordWidth = _calculateMaxWordWidth(widget.words);
  }

  double _calculateMaxWordWidth(List<String> words) {
    double tempMax = 0;
    final textStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );

    for (var word in words) {
      final width = measureTextWidth(word, textStyle);
      final totalWidth = width + 32;
      if (totalWidth > tempMax) {
        tempMax = totalWidth;
      }
    }
    return tempMax + 10;
  }

  double measureTextWidth(String text, TextStyle style) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.size.width;
  }

  void _playAudio(String word) {
    final audioPath = '${widget.audioPathPrefix}/$word.aac';
    _audioPlayer.play(AssetSource(audioPath));
  }

  void _navigate(int direction) {
    setState(() {
      _currentIndex += direction * 8;
      _currentIndex = _currentIndex.clamp(0, widget.words.length - 8);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarTitle(widget.title),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                itemCount: widget.words.length,
                itemBuilder: (context, index) {
                  const visibleItems = 8;
                  if (index < _currentIndex || index >= _currentIndex + visibleItems) {
                    return const SizedBox.shrink();
                  }
                  return PunjabiWordTile(
                    word: widget.words[index],
                    pronunciation: widget.pronunciations[index],
                    onPlay: () => _playAudio(widget.words[index]),
                    maxWidth: _maxWordWidth,
                  );
                },
              ),
            ),
            NavigationButtons(
              currentIndex: _currentIndex,
              maxIndex: widget.words.length - 8,
              onNavigate: _navigate,
            ),
          ],
        ),
      ),
    );
  }
}