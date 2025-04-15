import 'package:flutter/material.dart';
import 'package:impara_gurbani/Metodi.dart';
import 'dart:async';
import 'dart:math';
import 'package:just_audio/just_audio.dart';
import 'package:impara_gurbani/LISTE.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:impara_gurbani/Giochi/game_utils.dart';

class IndovinaParolaPage extends StatefulWidget {
  @override
  _IndovinaParolaPageState createState() => _IndovinaParolaPageState();
}

class _IndovinaParolaPageState extends State<IndovinaParolaPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final FirebaseDatabase _database;
  late final DatabaseReference _databaseRef;

  final GameUtils _gameUtils = GameUtils();

  List<String> _currentWords = [];
  String _correctWord = "";
  int _score = 0;
  int _maxScore = 0;
  double _timeLeft = 15.0;
  Timer? _timer;
  final Set<String> _usedWords = {};

  late String _currentCategoryPath;

  @override
  void initState() {
    super.initState();
    _database = FirebaseDatabase.instance;
    _loadMaxScore();
    requestMicrophonePermission();
  }

  void _loadMaxScore() {
    _gameUtils.loadMaxScore((maxScore) {
      setState(() {
        _maxScore = maxScore;
      });
    }, 'users/${_auth.currentUser?.uid}/MaxParola');
  }

  void _updateMaxScore() {
    _gameUtils.updateMaxScore(
        _score, 'users/${_auth.currentUser?.uid}/MaxParola');
  }

  Future<void> requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMaxScore();
      _gameUtils.showStartScreen(context, () {
        _generateWords();
        _startTimer();
      });
    });
  }

  @override
  void dispose() {
    _updateMaxScore();
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _generateWords() {
    final List<String> category =
        wordCategories.keys.elementAt(_random.nextInt(wordCategories.length));

    _currentCategoryPath = categoryPaths[wordCategories[category]]!;

    final List<String> availableWords =
        category.where((word) => !_usedWords.contains(word)).toList();

    if (availableWords.length < 3) {
      _gameUtils.showEndScreen(context, () {
        setState(() {
          _usedWords.clear();
          _score = 0;
          _maxScore = 0;
        });
        _generateWords();
        _startTimer();
      });
      return;
    }

    _currentWords = availableWords..shuffle(_random);
    _currentWords = _currentWords.take(3).toList();

    _correctWord = _currentWords[_random.nextInt(3)];
    _usedWords.add(_correctWord);

    setState(() {});
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
    _playAudio();
  }

  Future<void> _playAudio() async {
    try {
      await _audioPlayer.setAsset('$_currentCategoryPath/$_correctWord.aac');
      await _audioPlayer.play();
    } catch (e) {
      print("Errore nel caricamento dell'audio: $e");
    }
  }

  void _onWordSelected(String word) {
    if (word == _correctWord) {
      _score++;
      if (_score > _maxScore) {
        _maxScore = _score;
        _updateMaxScore();
      }
      _generateWords();
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
                    ? "Hai indovinato la parola!"
                    : "La parola corretta era: $_correctWord",
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
                  _generateWords();
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return WillPopScope(
      onWillPop: () => UscitaGiochi(context),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBarTitle("Indovina la parola"),
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
                      const SizedBox(height: 80),
                      ElevatedButton.icon(
                        onPressed: _playAudio,
                        icon: const Icon(Icons.volume_up),
                        label: Text("Riascolta audio",
                            style: textTheme.titleMedium),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: colorScheme.onSecondary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bottoni parole
                      ..._currentWords.map((word) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton(
                            onPressed: () => _onWordSelected(word),
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
                              word,
                              style: textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
