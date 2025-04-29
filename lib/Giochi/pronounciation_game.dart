import 'package:flutter/material.dart';
import 'package:impara_gurbani/Metodi.dart';
import 'package:impara_gurbani/LISTE.dart';
import 'package:impara_gurbani/Giochi/funzioni.dart';
import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:impara_gurbani/Tema.dart';

class PronunciaParola extends StatefulWidget {
  @override
  _PronunciaParolaState createState() => _PronunciaParolaState();
}

class _PronunciaParolaState extends State<PronunciaParola> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final Random _random = Random();
  final stt.SpeechToText _speech = stt.SpeechToText();

  // Stato del gioco
  String _correctWord = "";
  final Set<String> _usedWords = {};
  int _score = 0;
  int _maxScore = 0;
  double _timeLeft = GAME_DURATION;
  Timer? _timer;
  bool _isLoading = true;
  bool _gameStarted = false;
  bool _isShowingResult = false;
  bool _hasGuessed = false;

  // Riconoscimento vocale
  bool _isListening = false;
  String _recognizedText = "";
  bool _speechAvailable = false;
  DateTime? _lastListeningStart;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initializeSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) => print("Stato Microfono: $status"),
      onError: (error) => print("Errore riconoscimento: ${error.errorMsg}"),
    );
  }

  Future<void> _initializeGame() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await _requestPermission();

    try {
      _maxScore = await _loadMaxScore();
    } catch (e) {
      print("Errore caricamento max score: $e");
      _maxScore = 0;
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }

    if (!_gameStarted && mounted && !_isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showStartGameDialog(context, _startGame);
        }
      });
    }
  }

  Future<int> _loadMaxScore() async {
    final user = _auth.currentUser;
    if (user == null) return 0;
    
    final ref = _database.ref('users/${user.uid}/$MAX_SCORE_PRONUNCIA');
    final snapshot = await ref.get();
    return snapshot.value as int? ?? 0;
  }

  void _updateMaxScore() {
    final user = _auth.currentUser;
    if (user == null || _score <= _maxScore) return;
    
    final ref = _database.ref('users/${user.uid}/$MAX_SCORE_PRONUNCIA');
    ref.set(_score);
    setState(() => _maxScore = _score);
  }

  void _startGame() {
    if (_gameStarted || !mounted) return;
    setState(() {
      _score = 0;
      _timeLeft = GAME_DURATION;
      _usedWords.clear();
      _gameStarted = true;
      _isLoading = false;
      _isShowingResult = false;
      _recognizedText = "";
      _hasGuessed = false;
    });
    _generateWordAndStart();
  }

  void _restartGame() {
    _timer?.cancel();
    _stopListening();

    setState(() {
      _gameStarted = false;
      _isLoading = true;
      _correctWord = "";
      _recognizedText = "";
      _hasGuessed = false;
    });
    _initializeGame();
  }

  Future<void> _requestPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Permesso microfono necessario per giocare!')),
          );
        }
      }
    }
  }

  void _generateWordAndStart() {
    if (!mounted || !_gameStarted) return;

    _timer?.cancel();
    _stopListening();

    setState(() {
      _hasGuessed = false;
      _isShowingResult = false;
      _recognizedText = "";
      _correctWord = "";
    });

    final List<List<String>> availableCategories = wordCategories.keys
        .where((category) => category.any((word) => !_usedWords.contains(word)))
        .toList();

    if (availableCategories.isEmpty) {
      _onGameEnd(allWordsUsed: true);
      return;
    }

    final List<String> category =
        availableCategories[_random.nextInt(availableCategories.length)];

    final List<String> availableWords =
        category.where((word) => !_usedWords.contains(word)).toList();

    if (availableWords.isEmpty) {
      Future.delayed(Duration(milliseconds: 50), _generateWordAndStart);
      return;
    }

    _correctWord = availableWords[_random.nextInt(availableWords.length)];
    _usedWords.add(_correctWord);

    setState(() {
      _timeLeft = GAME_DURATION;
    });

    _startTimer();
    _startContinuousListening();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!mounted || !_gameStarted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_timeLeft > 0) {
          _timeLeft -= 0.1;
        } else {
          _timeLeft = 0;
          timer.cancel();
          if (!_hasGuessed && !_isShowingResult) {
            _handleResult(false, isTimeout: true);
          }
        }
      });
    });
  }

  void _startContinuousListening() {
    if (!_speechAvailable || !mounted || !_gameStarted || _isShowingResult || _hasGuessed) return;

    // Se è passato meno di 1 secondo dall'ultimo avvio, aspetta
    if (_lastListeningStart != null && 
        DateTime.now().difference(_lastListeningStart!) < Duration(seconds: 1)) {
      Future.delayed(Duration(milliseconds: 500), _startContinuousListening);
      return;
    }

    _lastListeningStart = DateTime.now();
    
    _speech.listen(
      onResult: (result) {
        if (!mounted || _isShowingResult || !_gameStarted) return;

        setState(() {
          _recognizedText = result.recognizedWords;
          if (_containsCorrectWord(_recognizedText)) {
            _hasGuessed = true;
            _handleResult(true);
          }
        });
      },
      localeId: "pa-IN",
      listenMode: stt.ListenMode.dictation,
      cancelOnError: true,
      partialResults: true,
      listenFor: Duration(seconds: 5),
      onSoundLevelChange: (level) {
        // Mantiene attivo il microfono rilevando il livello del suono
        if (!_isListening && mounted) {
          setState(() => _isListening = true);
        }
      },
    ).then((_) {
      // Quando l'ascolto termina, riavvialo immediatamente
      if (mounted && _gameStarted && !_isShowingResult && !_hasGuessed) {
        _startContinuousListening();
      }
    });

    setState(() => _isListening = true);
  }

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
    } catch (e) {
      print("Errore durante lo stop: $e");
    }
    if (mounted) {
      setState(() => _isListening = false);
    }
  }

  bool _containsCorrectWord(String recognizedText) {
    if (_correctWord.isEmpty || recognizedText.isEmpty) return false;

    final words = recognizedText
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 1)
        .toList();

    return words.contains(_correctWord.toLowerCase());
  }

  void _handleResult(bool isCorrect, {bool isTimeout = false}) {
    if (_isShowingResult || !mounted || !_gameStarted) return;

    _isShowingResult = true;
    _timer?.cancel();
    _stopListening();

    if (isCorrect) {
      _score++;
      if (_score > _maxScore) {
        _updateMaxScore();
      }
    } else {
      _score = 0;
    }

    showResultDialog(
      context: context,
      isCorrect: isCorrect,
      correctAnswerText: isCorrect
          ? "Hai pronunciato correttamente: $_correctWord"
          : "La parola corretta era: $_correctWord${isTimeout ? "" : "\nTu hai detto: $_recognizedText"}",
      onContinue: () {
        if (mounted && _gameStarted) {
          _isShowingResult = false;
          _generateWordAndStart();
        }
      },
    );
  }

  void _onGameEnd({bool allWordsUsed = false}) {
    _timer?.cancel();
    _stopListening();
    if (!mounted) return;

    if (allWordsUsed) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Complimenti!"),
            content: Text(
                "Hai esaurito tutte le parole disponibili!\nPunteggio finale: $_score\nPunteggio Massimo: $_maxScore"),
            actions: <Widget>[
              TextButton(
                child: Text("Ricomincia"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _restartGame();
                },
              ),
              TextButton(
                child: Text("Esci"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<bool> _handleExit() async {
    if (!mounted) return false;

    _timer?.cancel();
    await _stopListening();

    bool shouldExit = await showConfirmExitDialog(context);

    if (shouldExit) {
      if (mounted) setState(() => _gameStarted = false);
      return true;
    } else {
      if (mounted && _gameStarted) {
        _startTimer();
        _startContinuousListening();
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return WillPopScope(
      onWillPop: _handleExit,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBarTitle('Pronuncia la Parola'),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
            : !_gameStarted
                ? Center(child: Text("Premi 'Inizia' nel dialogo", style: textTheme.bodyLarge))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ScoreTimerBar(
                          maxScore: _maxScore,
                          timeLeft: max(0, _timeLeft),
                          maxTime: GAME_DURATION,
                        ),
                        const SizedBox(height: 40),

                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Punteggio: $_score",
                                  style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 60),

                              if (_correctWord.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                                  decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: colorScheme.primary, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        )
                                      ]),
                                  child: Text(_correctWord,
                                      style: textTheme.displaySmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onPrimaryContainer),
                                      textAlign: TextAlign.center),
                                )
                              else if (_gameStarted)
                                CircularProgressIndicator(),

                              const SizedBox(height: 40),

                              // Indicatore stato microfono
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _isListening 
                                      ? colorScheme.primary.withOpacity(0.1)
                                      : colorScheme.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isListening ? Icons.mic : Icons.mic_off,
                                      color: _isListening 
                                          ? colorScheme.primary 
                                          : colorScheme.error,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      _isListening ? "Microfono attivo" : "Microfono disattivo",
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: _isListening 
                                            ? colorScheme.primary 
                                            : colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              if (_recognizedText.isNotEmpty)
                                Container(
                                  constraints: BoxConstraints(minHeight: 50),
                                  padding: const EdgeInsets.all(12.0),
                                  margin: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceVariant.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                                    border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    _recognizedText,
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                              Spacer(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}