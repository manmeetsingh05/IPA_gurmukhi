import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Per accedere ai servizi
import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart'; // Necessario per ScoreService
import 'package:firebase_database/firebase_database.dart'; // Necessario per ScoreService

// Importa le parti condivise
import 'funzioni.dart'; // Contiene servizi, dialogs, costanti GAME_DURATION ecc.
// Importa le tue liste e widget specifici
import 'package:impara_gurbani/LISTE.dart'; // Per wordCategories, categoryPaths
import 'package:impara_gurbani/Metodi.dart'; // Per AppBarTitle, ScoreTimerBar, OptionButton
// import 'package:impara_gurbani/Tema.dart'; // Se necessario

// Definisci la costante del path (come negli altri esempi)

class IndovinaParolaPage extends StatefulWidget {
  @override
  _IndovinaParolaPageState createState() => _IndovinaParolaPageState();
}

class _IndovinaParolaPageState extends State<IndovinaParolaPage> {
  // --- Servizi e Dipendenze ---
  // Firebase non è usato direttamente qui ma serve a ScoreService
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  // Servizi ottenuti da Provider o inizializzati
  late AudioService _audioService;
  late ScoreService _scoreService; // Inizializzato in initState ora
  final Random _random = Random();

  // --- Stato Specifico del Gioco ---
  List<String> _currentWordOptions = [];
  String _correctWord = "";
  String _correctWordAudioPath = "";
  final Set<String> _usedWords = {}; // Parole già usate in questa sessione

  // --- Stato Comune del Gioco ---
  int _score = 0;
  int _maxScore = 0;
  double _timeLeft = GAME_DURATION; // Usa costante da funzioni.dart
  Timer? _timer;
  bool _isLoading = true; // Stato per caricamento iniziale max score
  bool _gameStarted = false; // Per evitare doppio start e gestire UI
  // bool _gameEnded = false; // Non strettamente necessario, _onGameEnd gestisce la fine

  @override
  void initState() {
    super.initState();
    // Ottieni AudioService da Provider
    _audioService = Provider.of<AudioService>(context, listen: false);
    // Inizializza ScoreService direttamente (non dipende da Provider qui)
    _scoreService = ScoreService(_auth, _database);

    // Carica dati iniziali (max score) e mostra schermata di avvio
    _initializeGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // L'aggiornamento del max score avviene in _onWordSelected
    super.dispose();
  }

  // --- Inizializzazione e Gestione Ciclo Vita Gioco ---

  Future<void> _initializeGame() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      _maxScore = await _scoreService.loadMaxScore(MAX_SCORE_PAROLA_PATH); // Usa la costante
    } catch (e) {
      print("Errore caricamento max score: $e");
      _maxScore = 0; // Fallback
    } finally {
       if (!mounted) return;
       setState(() => _isLoading = false);
    }


    // Mostra il dialog di inizio solo dopo il caricamento
    // e se il gioco non è già in corso
    if (!_gameStarted && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showStartGameDialog(context, _startGame);
        }
      });
    }
  }

  void _startGame() {
    if (_gameStarted || !mounted) return;
    setState(() {
      _score = 0;
      _timeLeft = GAME_DURATION;
      _usedWords.clear(); // Resetta le parole usate
      _gameStarted = true; // Segna che il gioco è attivo
      // _isLoading è già false
    });
    _generateNewRound();
    _startTimer();
  }

  void _restartGame() {
     setState(() {
       _gameStarted = false;
       _isLoading = true; // Mostra loading mentre ricarica
     });
     _initializeGame(); // Ricarica max score e mostra dialog
   }

  // --- Logica Core del Gioco (Specifica per IndovinaParola) ---

  void _generateNewRound() {
    if (!mounted) return;

    // Trova una categoria e parole disponibili non ancora usate
    List<String> availableWords = [];
    String selectedCategory = "";
    String? categoryPath; // Può essere null se non trovato

    // Mappa le chiavi (liste) alle categorie (stringhe) per facilitare la ricerca del path
    final List<MapEntry<List<String>, String>> categoryEntries = wordCategories.entries.toList();
    categoryEntries.shuffle(_random); // Mescola le categorie

    bool foundCategory = false;
    for (final entry in categoryEntries) {
       final List<String> wordsInCategory = entry.key;
       final List<String> currentAvailable = wordsInCategory.where((word) => !_usedWords.contains(word)).toList();

       if (currentAvailable.length >= 3) { // Necessarie 1 corretta + 2 opzioni
          availableWords = currentAvailable..shuffle(_random);
          selectedCategory = entry.value; // Nome della categoria
          // Trova il path corrispondente al nome della categoria
          categoryPath = categoryPaths[selectedCategory];
          if (categoryPath != null) {
              foundCategory = true;
              break;
          } else {
             print("Attenzione: Path non trovato per la categoria '$selectedCategory'");
             // Continua a cercare un'altra categoria valida
          }
       }
    }

    // Se non ci sono abbastanza parole in nessuna categoria valida
    if (!foundCategory || categoryPath == null) {
        print("Gioco finito! Non ci sono abbastanza parole o categorie valide.");
        _onGameEnd(allWordsUsed: true); // Indica che le parole sono finite
        return;
    }

    // Seleziona la parola corretta e le opzioni
    _correctWord = availableWords[0];
    _usedWords.add(_correctWord); // Aggiungi la parola corretta alle usate
    // Costruisci il path audio, assicurati che l'estensione sia corretta (.aac, .mp3, ecc.)
    _correctWordAudioPath = '$categoryPath/$_correctWord.aac'; // <-- CAMBIA ESTENSIONE SE NECESSARIO

    // Prendi altre 2 parole diverse dalla stessa lista `availableWords`
    List<String> options = [_correctWord];
    options.addAll(availableWords.sublist(1).take(2)); // Prende i successivi 2 elementi

    // Assicurati che ci siano 3 opzioni (dovrebbe essere garantito da `currentAvailable.length >= 3`)
    if (options.length < 3) {
        print("ERRORE: Generazione opzioni fallita per $_correctWord");
        // Gestione fallback o rigenerazione? Per ora, si procede con meno opzioni.
    }

    options.shuffle(_random); // Mescola le opzioni finali

    setState(() {
      _currentWordOptions = options;
      // Resetta qui eventuali stati di errore precedenti
    });

    // Riproduci l'audio della parola corretta
    _playCorrectAudio();
  }

  void _startTimer() {
    _timer?.cancel();
    if (!mounted) return;
    setState(() => _timeLeft = GAME_DURATION);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_timeLeft > 1) {
          _timeLeft -= 1;
        } else {
          _timeLeft = 0;
          timer.cancel();
          _handleIncorrectAnswer(isTimeout: true);
        }
      });
    });
  }

  Future<void> _playCorrectAudio() async {
     try {
       await _audioService.playAsset(_correctWordAudioPath);
     } catch (e) {
       print("Errore riproduzione audio '$_correctWordAudioPath': $e");
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Errore audio per parola'), duration: Duration(seconds: 2))
          );
       }
     }
  }

  // --- Gestione Risposte e Risultati ---

  void _onWordSelected(String selectedWord) {
    if (!mounted) return;
    _timer?.cancel();

    bool isCorrect = selectedWord == _correctWord;

    if (isCorrect) {
      // Logica aggiornamento punteggio (come negli altri esempi)
      int newScore = _score + 1;
      int previousMaxScore = _maxScore;
      setState(() {
        _score = newScore;
        if (newScore > _maxScore) {
          _maxScore = newScore;
        }
      });

      // Aggiorna Firebase SE il max score è stato superato
      if (newScore > previousMaxScore) {
        _scoreService.updateMaxScore(MAX_SCORE_PAROLA_PATH, newScore, previousMaxScore);
      }

      // Mostra risultato positivo
      showResultDialog(
        context: context,
        isCorrect: true,
        correctAnswerText: "Corretto!",
        onContinue: () {
          if (!mounted) return;
          _generateNewRound();
          _startTimer();
        },
      );
    } else {
      // Risposta sbagliata
      _handleIncorrectAnswer();
    }
  }

  void _handleIncorrectAnswer({bool isTimeout = false}) {
     if (!mounted) return;
     _timer?.cancel();
     _audioService.playErrorSound();

     // Mostra risultato negativo
     showResultDialog(
       context: context,
       isCorrect: false,
       correctAnswerText: isTimeout
           ? "Tempo scaduto!\nLa parola era: $_correctWord"
           : "Sbagliato!\nLa parola era: $_correctWord",
       onContinue: () {
         if (!mounted) return;
         // Resetta punteggio
         setState(() {
           _score = 0;
         });
         _generateNewRound();
         _startTimer();
       },
     );
   }

   void _onGameEnd({bool allWordsUsed = false}) {
     _timer?.cancel();
     if (!mounted) return;
     // Non è necessario `_gameEnded = true` o `_updateMaxScore` qui

     if (allWordsUsed) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Complimenti!"),
              content: Text("Hai completato tutte le parole disponibili!\nPunteggio finale: $_score"),
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
                     Navigator.of(context).pop(); // Chiudi dialog
                     Navigator.of(context).pop(); // Esci dalla pagina
                  },
                ),
              ],
            );
          },
        );
     }
     // Altre condizioni di fine gioco sono gestite dall'uscita utente
   }

   // Usa la funzione del file utils per la conferma uscita
   Future<bool> _handleExit() async {
     if (!mounted) return false;
     bool wasRunning = _timer?.isActive ?? false;
     _timer?.cancel(); // Pausa timer
     bool shouldExit = await showConfirmExitDialog(context);
     if (!shouldExit && _gameStarted && wasRunning && mounted) {
        _startTimer(); // Riprendi timer se annullato
     } else if (shouldExit) {
        await _audioService.stop(); // Stop audio prima di uscire
     }
     return shouldExit; // Permette o nega il pop
   }

  // --- Build UI ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return WillPopScope(
      onWillPop: _handleExit, // Usa la funzione per la conferma
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBarTitle("Indovina la parola"), // Usa il tuo AppBar
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
            : !_gameStarted
                ? Center(child: Text("Premi 'Inizia' per cominciare!", style: textTheme.bodyLarge))
                : SafeArea(
                    child: Column(
                      children: [
                        // Barra Punteggio e Timer
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ScoreTimerBar(
                            maxScore: _maxScore,
                            timeLeft: _timeLeft < 0 ? 0 : _timeLeft,
                            maxTime: GAME_DURATION,
                          ),
                        ),


                        // Area centrale del gioco
                        Expanded(
                          child: Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Punteggio Attuale
                                  Text(
                                    "Punteggio: $_score",
                                    style: textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onBackground,
                                    ),
                                  ),
                                  const SizedBox(height: 30),

                                  // Bottone Riascolta Audio
                                  ElevatedButton.icon(
                                    onPressed: _playCorrectAudio,
                                    icon: Icon(Icons.volume_up_rounded, size: 28, color: colorScheme.onSecondary),
                                    label: Text(
                                        "Riascolta",
                                        style: textTheme.titleMedium?.copyWith(color: colorScheme.onSecondary, fontWeight: FontWeight.w600)
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.secondary,
                                      foregroundColor: colorScheme.onSecondary,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),

                                  // Bottoni delle Opzioni
                                  if (_currentWordOptions.isNotEmpty)
                                    ..._currentWordOptions.map((word) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 7.0),
                                        child: OptionButton(
                                          text: word,
                                          // Puoi aggiungere uno stile specifico se necessario
                                          // textStyle: textTheme.titleLarge,
                                          onPressed: () => _onWordSelected(word),
                                        ),
                                      );
                                    }).toList()
                                  else if (_gameStarted && !_isLoading)
                                      Padding(
                                       padding: const EdgeInsets.only(top: 20.0),
                                       child: CircularProgressIndicator(),
                                      ),

                                   const SizedBox(height: 20),
                                ],
                              ),
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