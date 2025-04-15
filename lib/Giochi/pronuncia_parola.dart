import 'package:flutter/material.dart';
import 'package:impara_gurbani/Metodi.dart';
import 'package:impara_gurbani/LISTE.dart';
import 'package:impara_gurbani/Giochi/game_utils.dart';
import 'dart:async';
import 'dart:math';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:impara_gurbani/Tema.dart';

class PronunciaParola extends StatefulWidget {
  @override
  _PronunciaParolaState createState() => _PronunciaParolaState();
}

class _PronunciaParolaState extends State<PronunciaParola> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = "";
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();
  final GameUtils _gameUtils = GameUtils();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final FirebaseDatabase _database;

  List<String> _currentWords = [];
  String _correctWord = "";
  int _score = 0;
  int _maxScore = 0;
  double _timeLeft = 10.0;
  Timer? _timer;
  Timer? _listeningTimer;
  final Set<String> _usedWords = {};
  bool _hasGuessed = false;
  bool _showRecognizedText = false;

  late String _currentCategoryPath;
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _database = FirebaseDatabase.instance;
    _loadMaxScore();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMaxScore();
      _gameUtils.showStartScreen(context, () {
        _generateWords();
      });
    });
  }

  Future<void> _requestPermission() async {
    var status = await Permission.microphone.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      print("Permesso microfono negato!");
    }
  }

  bool _isInitializingMic = false;
  Future<void> _startListening() async {
    if (_isInitializingMic || _isListening) return;

    _isInitializingMic = true;
    bool available = await _speech.initialize(
      onStatus: (status) {
        print("Stato del microfono: $status");
        if (mounted) {
          setState(() {
            _isListening = (status == "listening");
            _isInitializingMic = false;
          });
        }
      },
      onError: (errorNotification) {
        print("Errore: $errorNotification");
        if (mounted) {
          setState(() {
            _isInitializingMic = false;
          });
        }
      },
    );

    if (available && mounted) {
      setState(() {
        _isListening = true;
        _recognizedText = "";
        _showRecognizedText = true;
      });

      _speech.listen(
        onResult: (result) {
          if (!mounted || _isShowingResult) return;

          setState(() {
            _recognizedText = result.recognizedWords;
            if (_containsCorrectWord(_recognizedText)) {
              _hasGuessed = true;
              _stopListening();
              _showResult(true);
            }
          });
        },
        localeId: "pa-IN",
        listenMode: stt.ListenMode.dictation,
        cancelOnError: true,
        partialResults: true,
      );

      _listeningTimer = Timer(Duration(seconds: 10), () {
        if (!_hasGuessed && mounted && !_isShowingResult) {
          _stopListening();
          if (_timeLeft <= 0.5) {
            _showResult(false);
          }
        }
      });
    }
    _isInitializingMic = false;
  }

  bool _containsCorrectWord(String recognizedText) {
    final words = recognizedText
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 1)
        .toList();

    return words.contains(_correctWord.toLowerCase());
  }

  void _stopListening() async {
    _listeningTimer?.cancel();
    await _speech.stop();
    if (mounted) {
      setState(() {
        _isListening = false;
        _showRecognizedText = false;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _timer?.cancel();
    _listeningTimer?.cancel();
    _speech.stop();
    super.dispose();
  }

  void _loadMaxScore() {
    _gameUtils.loadMaxScore((maxScore) {
      setState(() {
        _maxScore = maxScore;
      });
    }, 'users/${_auth.currentUser?.uid}/MaxPronuncia');
  }

  void _updateMaxScore() {
    _gameUtils.updateMaxScore(
        _score, 'users/${_auth.currentUser?.uid}/MaxPronuncia');
  }

  void _generateWords() {
    _timer?.cancel();
    _listeningTimer?.cancel();
    _hasGuessed = false;

    final List<List<String>> availableCategories = wordCategories.keys
        .where((category) => category.any((word) => !_usedWords.contains(word)))
        .toList();

    if (availableCategories.isEmpty) {
      _gameUtils.showEndScreen(context, () {
        setState(() {
          _usedWords.clear();
          _score = 0;
          _maxScore = 0;
        });
        _generateWords();
      });
      return;
    }

    final List<String> category =
        availableCategories[_random.nextInt(availableCategories.length)];

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
      });
      return;
    }

    _currentWords = availableWords..shuffle(_random);
    _currentWords = _currentWords.take(3).toList();

    _correctWord = _currentWords[_random.nextInt(3)];
    _usedWords.add(_correctWord);

    setState(() {
      _recognizedText = "";
      _showRecognizedText = false;
      _timeLeft = 10.0;
    });

    _playAudio();
  }

  Future<void> _playAudio() async {
    if (_isPlayingAudio || !mounted || _isShowingResult) return;
    _isPlayingAudio = true;

    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAsset('$_currentCategoryPath/$_correctWord.aac');

      _startListening();

      await _audioPlayer.play();
      _startTimer();
    } catch (e) {
      print("Errore nel caricamento dell'audio: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
        });
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = 10.0;
    });

    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft -= 0.1;
          } else {
            timer.cancel();
            if (!_hasGuessed && !_isShowingResult) {
              _stopListening();
              Future.delayed(Duration(milliseconds: 50), () {
                if (!_hasGuessed && !_isShowingResult && mounted) {
                  _showResult(false);
                }
              });
            }
          }
        });
      }
    });
  }

  bool _isShowingResult = false;
  void _showResult(bool isCorrect) {
    if (_isShowingResult || !mounted) return;

    if (!isCorrect && _timeLeft > 0.5) {
      return;
    }

    _isShowingResult = true;
    _timer?.cancel();
    _listeningTimer?.cancel();

    if (isCorrect) {
      _score++;
      if (_score > _maxScore) {
        _maxScore = _score;
        _updateMaxScore();
      }
    } else {
      _score = 0;
    }

    if (mounted) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final textTheme = theme.textTheme;

      showDialog(
        context: context,
        barrierDismissible: false,
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
                      ? "Hai pronunciato correttamente!"
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
                    _isShowingResult = false;
                    if (mounted) {
                      setState(() {
                        _recognizedText = "";
                      });
                      _generateWords();
                    }
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
  }

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Usa il tema di MaterialApp
    final colorScheme = theme.colorScheme; // Schema colore del tema

    return WillPopScope(
      onWillPop: () => UscitaGiochi(context),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBarTitle('Ripeti la parola'),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(
              16.0, 32.0, 16.0, 8.0), // Più spazio sopra
          child: Column(
            children: [
              // Top bar: Max score a sinistra, timer a destra
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Max score
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    // Timer
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
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onBackground,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20), // Spazio tra top bar e punteggio

              // Sezione centrale centrata
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Centro: punteggio attuale
                      Text(
                        "Punteggio: $_score",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                      ),

                      const SizedBox(height: 80), 
                      ElevatedButton(
                        onPressed: _playAudio,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.buttonRadius),
                          ),
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: colorScheme.onSecondary,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: AppTheme.defaultPadding,
                          ),
                        ),
                        child: Text(
                          "Riascolta audio",
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),

                      const SizedBox(
                          height: 20), // Spazio tra riascolta audio e risultato

                      // Risultato riconosciuto
                      if (_showRecognizedText)
                        Container(
                          padding: EdgeInsets.all(AppTheme.defaultPadding),
                          decoration: BoxDecoration(
                            color: colorScheme.background,
                            borderRadius:
                                BorderRadius.circular(AppTheme.cardRadius),
                            border: Border.all(color: colorScheme.outline),
                          ),
                          child: Text(
                            _recognizedText.isNotEmpty
                                ? _recognizedText
                                : "Sto ascoltando...",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      const SizedBox(
                          height:
                              20), // Spazio tra risultato e bottone microfono

                      // Bottoni per avviare/fermare ascolto
                      ElevatedButton(
                        onPressed:
                            _isListening ? _stopListening : _startListening,
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(20),
                          backgroundColor: _isListening
                              ? colorScheme.error
                              : colorScheme.tertiary ?? Colors.green,
                          foregroundColor:
                              colorScheme.onTertiary ?? Colors.white,
                        ),
                        child: Icon(
                          _isListening ? Icons.mic_off : Icons.mic,
                          size: AppTheme.iconSize,
                        ),
                      ),
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
