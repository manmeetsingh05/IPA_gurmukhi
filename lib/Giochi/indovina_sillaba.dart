import 'package:flutter/material.dart';
import 'package:impara_gurbani/Metodi.dart';
import 'package:impara_gurbani/LISTE.dart';
import 'package:impara_gurbani/Giochi/game_utils.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'dart:async';

class PunjabiSyllableGame extends StatefulWidget {
  @override
  _PunjabiSyllableGameState createState() => _PunjabiSyllableGameState();
}

class _PunjabiSyllableGameState extends State<PunjabiSyllableGame> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final FirebaseDatabase _database;
  late final DatabaseReference _databaseRef;

  final GameUtils _gameUtils = GameUtils();

  String _currentSyllable = "";
  String _correctPronunciation = "";
  List<Map<String, String>> _options = [];
  int _score = 0;
  int _maxScore = 0;
  double _timeLeft = 15.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _database = FirebaseDatabase.instance;
    _databaseRef = _database.ref('users/${_auth.currentUser?.uid}/MaxSillabe');
    _loadMaxScore();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gameUtils.showStartScreen(context, () {
        _generateSyllable();
        _startTimer();
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _loadMaxScore() {
    _gameUtils.loadMaxScore((maxScore) {
      setState(() {
        _maxScore = maxScore;
      });
    }, 'users/${_auth.currentUser?.uid}/MaxSillabe');
  }

  void _updateMaxScore() {
    _gameUtils.updateMaxScore(
        _score, 'users/${_auth.currentUser?.uid}/MaxSillabe');
  }

  void _generateSyllable() {
    final keys = muharniCombinations.keys.toList();
    final randomKey = keys[_random.nextInt(keys.length)];
    final combinations = muharniCombinations[randomKey]!;
    final randomCombination =
        combinations[_random.nextInt(combinations.length)];

    setState(() {
      _currentSyllable = randomCombination.keys.first;
      _correctPronunciation = randomCombination.values.first;
      _options = _generateOptions(randomKey, _correctPronunciation);
    });
  }

  List<Map<String, String>> _generateOptions(
      String key, String correctPronunciation) {
    final combinations = muharniCombinations[key]!;
    final options = <Map<String, String>>[];

    options.add({_currentSyllable: correctPronunciation});

    while (options.length < 3) {
      final randomCombination =
          combinations[_random.nextInt(combinations.length)];
      final pronunciation = randomCombination.values.first;
      if (pronunciation != correctPronunciation &&
          !options.any((option) => option.values.first == pronunciation)) {
        options.add(randomCombination);
      }
    }

    options.shuffle();
    return options;
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 15.0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft -= 1;
        } else {
          timer.cancel();
          _showResult(false);
        }
      });
    });
  }

  Future<void> _playAudio(String syllable) async {
    try {
      await _audioPlayer.setAsset('assets/SUONI/SILLABE/$syllable.aac');
      _audioPlayer.play();
    } catch (e) {
      print("Errore nel caricamento dell'audio: $e");
    }
  }

  void _onOptionSelected(String selectedPronunciation) {
    if (selectedPronunciation == _correctPronunciation) {
      _score++;
      if (_score > _maxScore) {
        _maxScore = _score;
        _updateMaxScore();
      }
      _generateSyllable();
      _startTimer();
    } else {
      _gameUtils.playErrorSound();
      _showResult(false);
    }
  }

  void _showResult(bool isCorrect) {
    _timer?.cancel();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                isCorrect
                    ? 'assets/images/right.png'
                    : 'assets/images/wrong.png',
                height: 150,
              ),
              const SizedBox(height: 16),
              Text(
                isCorrect ? "Corretto!" : "Sbagliato!",
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isCorrect
                    ? "Hai indovinato la pronuncia!"
                    : "La pronuncia corretta era: $_correctPronunciation",
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onBackground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (!isCorrect) {
                    setState(() => _score = 0);
                  }
                  _generateSyllable();
                  _startTimer();
                },
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.secondary,
                  textStyle: textTheme.labelLarge,
                ),
                child: const Text("Continua"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return WillPopScope(
      onWillPop: () => UscitaGiochi(context),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBarTitle("Indovina la sillaba"),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(
              16.0, 32.0, 16.0, 8.0), // 👈 più spazio sopra
          child: Column(
            children: [
              // Top bar: Max score a sinistra, timer a destra
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: colorScheme.primary, width: 1.5),
                      ),
                      child: Text(
                        "Max: $_maxScore",
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularTimer(
                          timeLeft: _timeLeft,
                          maxTime: 15.0,
                          size: 90,
                        ),
                        Text(
                          "${_timeLeft.toInt()}",
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onBackground,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Sezione centrale centrata
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Punteggio: $_score",
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                      ),

                      const SizedBox(height: 80), //
                      Text(
                        _currentSyllable,
                        style: textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(
                          height: 20), // 👈 spazio tra la sillaba e i tasti

                      // Bottoni opzioni
                      ..._options.map((option) {
                        final syllable = option.keys.first;
                        final pronunciation = option.values.first;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    _onOptionSelected(pronunciation),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  minimumSize: const Size(220, 55),
                                  elevation: 6,
                                  shadowColor: Colors.black26,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  pronunciation,
                                  style: textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                onPressed: () => _playAudio(syllable),
                                icon: Icon(Icons.play_arrow),
                                color: colorScheme.secondary,
                                iconSize: 30,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
