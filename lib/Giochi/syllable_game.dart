import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Assicurati di averlo nei pubspec.yaml
import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Importa le parti condivise
import 'funzioni.dart'; // Contiene ScoreService, AudioService, dialogs, etc.
// Importa le tue liste e widget specifici
import 'package:impara_gurbani/LISTE.dart'; // Per muharniCombinations
import 'package:impara_gurbani/Metodi.dart'; // Per AppBarTitle, ScoreTimerBar, OptionButton etc.
// import 'package:impara_gurbani/Tema.dart'; // Se necessario


class IndovinaSillabaPage extends StatefulWidget {
  @override
  _IndovinaSillabaPageState createState() => _IndovinaSillabaPageState();
}

class _IndovinaSillabaPageState extends State<IndovinaSillabaPage> {
  // --- Servizi e Dipendenze ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  // AudioService sarà preso dal Provider
  late AudioService _audioService;
  // ScoreService inizializzato direttamente
  late ScoreService _scoreService;
  final Random _random = Random();

  // --- Stato del Gioco ---
  List<String> _currentSyllableOptions = []; // Sillabe scritte come opzioni
  String _correctSyllable = ""; // La sillaba scritta corretta
  String _correctSyllableAudioFileName = ""; // Nome file per l'audio (pronuncia o sillaba)
  final Set<String> _usedSyllables = {}; // Sillabe già usate in questa sessione

  // Mappa e lista per accesso rapido alle sillabe
  late Map<String, String> _allSyllables;
  late List<String> _allSyllableKeys;

  // Stato comune del gioco (gestione Max Score come nel primo esempio)
  int _score = 0;
  int _maxScore = 0;
  double _timeLeft = GAME_DURATION;
  Timer? _timer;
  bool _isLoading = true; // Stato per caricamento iniziale max score
  bool _gameStarted = false; // Per evitare doppio start e gestire UI

  @override
  void initState() {
    super.initState();
    // Prendi AudioService dal Provider
    // `listen: false` è importante in initState
    _audioService = Provider.of<AudioService>(context, listen: false);
    // Inizializza ScoreService
    _scoreService = ScoreService(_auth, _database);

    // Prepara i dati delle sillabe (sincrono)
    _prepareSyllableData();

    // Carica dati iniziali (max score) e mostra schermata di avvio
    _initializeGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Non serve aggiornare il max score qui se lo facciamo già durante il gioco
    super.dispose();
  }

  // --- Inizializzazione e Gestione Ciclo Vita Gioco ---

  // Crea una mappa unica sillaba -> pronuncia e una lista di tutte le sillabe
  void _prepareSyllableData() {
    _allSyllables = {};
    muharniCombinations.values.forEach((combinationsList) {
      combinationsList.forEach((syllableMap) {
        // Assumendo che ogni mappa interna abbia una sola coppia sillaba:pronuncia
        if (syllableMap.isNotEmpty) {
          _allSyllables.putIfAbsent(
              syllableMap.keys.first, () => syllableMap.values.first);
        }
      });
    });
    _allSyllableKeys = _allSyllables.keys.toList();
    // print("Numero totale di sillabe uniche: ${_allSyllableKeys.length}");
  }

  // Carica il max score e prepara il gioco (come nel primo esempio)
  Future<void> _initializeGame() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      _maxScore = await _scoreService.loadMaxScore(MAX_SCORE_SILLABA_PATH); // Usa la costante
    } catch (e) {
      print("Errore caricamento max score: $e");
      // Gestisci l'errore se necessario (es. imposta maxScore a 0)
       _maxScore = 0;
    } finally {
       if (!mounted) return;
       setState(() => _isLoading = false);
    }


    // Mostra il dialog di inizio solo dopo il caricamento
    // e se il gioco non è già in corso
    if (!_gameStarted && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Usa il dialog di avvio standard
          showStartGameDialog(context, _startGame);
        }
      });
    }
  }

  // Fa partire il gioco vero e proprio (come nel primo esempio)
  void _startGame() {
    if (_gameStarted || !mounted) return;
    setState(() {
      _score = 0;
      _timeLeft = GAME_DURATION;
      _usedSyllables.clear(); // Resetta sillabe usate all'inizio
      _gameStarted = true; // Segna che il gioco è attivo
      // _isLoading è già false da _initializeGame
    });
    _generateNewRound();
    _startTimer();
  }

   void _restartGame() {
     // Chiamando initialize, ricaricherà anche il max score (utile se è cambiato altrove)
     // e poi mostrerà di nuovo il dialog di start.
     // Se vuoi un riavvio immediato senza dialog, chiama _startGame direttamente.
     // In questo caso, seguiamo la logica del dialog.
     setState(() {
       _gameStarted = false; // Resetta lo stato per permettere un nuovo start
       _isLoading = true; // Mostra loading mentre ricarica
     });
     _initializeGame(); // Ricarica max score e mostra dialog
   }

  // --- Logica Core del Gioco (Specifica per IndovinaSillaba) ---

  void _generateNewRound() {
    if (!mounted) return;

    // Trova sillabe disponibili non ancora usate
    final List<String> availableSyllables = _allSyllableKeys
        .where((syllable) => !_usedSyllables.contains(syllable))
        .toList();

    // Controllo se ci sono abbastanza sillabe per un round (1 corretta + 2 distrattori)
    if (availableSyllables.length < 3) {
      print("Gioco finito! Non ci sono abbastanza sillabe disponibili.");
      _onGameEnd(allSyllablesUsed: true); // Passa info sul motivo fine gioco
      return;
    }

    // Seleziona la sillaba corretta
    availableSyllables.shuffle(_random);
    _correctSyllable = availableSyllables[0];
    _usedSyllables.add(_correctSyllable); // Aggiungi subito alle usate

    // Determina il nome file audio (ASSUNZIONE: il file ha il nome della SILLABA stessa)
    // Se i file audio sono nominati con la pronuncia (es. "ka.aac"), dovrai cambiarlo:
    // _correctSyllableAudioFileName = _allSyllables[_correctSyllable] ?? _correctSyllable;
    _correctSyllableAudioFileName = _correctSyllable; // Assumiamo file = sillaba (es. ਕ.aac)

    // Genera le opzioni (la sillaba corretta + 2 sbagliate)
    List<String> options = [_correctSyllable];
    List<String> distractorsPool = availableSyllables.sublist(1); // Le altre disponibili
    distractorsPool.shuffle(_random);

    int distractorsNeeded = 2;
    options.addAll(distractorsPool.take(distractorsNeeded));

    // Assicurati che ci siano 3 opzioni (dovrebbe esserci sempre se availableSyllables.length >= 3)
    if(options.length < 3) {
       print("ERRORE: Non abbastanza opzioni generate per $_correctSyllable");
       // Potrebbe essere necessario gestire questo caso limite, ma la logica sopra dovrebbe prevenirlo
    }

    options.shuffle(_random);

    setState(() {
      _currentSyllableOptions = options;
    });

    // Riproduci l'audio della sillaba corretta
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
          _timeLeft = 0; // Imposta a 0 prima di fermare
          timer.cancel();
          _handleIncorrectAnswer(isTimeout: true); // Gestisci timeout
        }
      });
    });
  }

  Future<void> _playCorrectAudio() async {
    // Assicurati che il path e l'estensione siano corretti!
    // Potrebbe essere .mp3, .wav, .m4a ecc. a seconda dei tuoi file
    final audioPath = 'assets/SUONI/SILLABE/$_correctSyllableAudioFileName.aac'; // O .mp3 ecc.
    try {
       await _audioService.playAsset(audioPath);
    } catch (e) {
       print("Errore riproduzione audio '$audioPath': $e");
       // Mostra un messaggio all'utente o logga l'errore
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Errore audio per: $_correctSyllable'), duration: Duration(seconds: 2))
          );
       }
    }

  }

  // --- Gestione Risposte e Risultati ---

  void _onSyllableSelected(String selectedSyllable) {
    if (!mounted) return;
    _timer?.cancel(); // Ferma il timer alla risposta

    bool isCorrect = selectedSyllable == _correctSyllable;

    if (isCorrect) {
      // Logica aggiornamento punteggio (come nel primo esempio)
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
        _scoreService.updateMaxScore(MAX_SCORE_SILLABA_PATH, newScore, previousMaxScore);
      }

      // Mostra risultato positivo
      showResultDialog(
        context: context,
        isCorrect: true,
        correctAnswerText: "Corretto!", // Messaggio semplice per risposta giusta
        onContinue: () {
          if (!mounted) return;
          _generateNewRound(); // Prepara il prossimo round
          _startTimer(); // Fa ripartire il timer
        },
      );
    } else {
      // Risposta sbagliata
      _handleIncorrectAnswer();
    }
  }

  void _handleIncorrectAnswer({bool isTimeout = false}) {
     if (!mounted) return;
     _timer?.cancel(); // Assicura che sia fermo
     _audioService.playErrorSound(); // Suono errore

     // Mostra risultato negativo
     showResultDialog(
       context: context,
       isCorrect: false,
       correctAnswerText: isTimeout
           ? "Tempo scaduto!\nLa sillaba era: $_correctSyllable"
           : "Sbagliato!\nLa sillaba era: $_correctSyllable",
       onContinue: () {
         if (!mounted) return;
         // Resetta il punteggio quando si sbaglia o scade il tempo
         setState(() {
           _score = 0;
         });
         _generateNewRound(); // Prepara nuovo round
         _startTimer(); // Fa ripartire il timer
       },
     );
   }

   void _onGameEnd({bool allSyllablesUsed = false}) {
     _timer?.cancel();
     if (!mounted) return;
     // Non è necessario impostare _gameEnded = true qui,
     // perché la fine è gestita dal dialog che porta al restart o all'uscita.
     // Assicurati che il punteggio massimo sia salvato (già fatto in _onSyllableSelected)

     // Mostra un dialog di fine specifico se le sillabe sono finite
     if (allSyllablesUsed) {
        showDialog(
          context: context,
          barrierDismissible: false, // Impedisce chiusura accidentale
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Complimenti!"),
              content: Text("Hai completato tutte le sillabe disponibili!\nPunteggio finale: $_score"),
              actions: <Widget>[
                TextButton(
                  child: Text("Ricomincia"),
                  onPressed: () {
                    Navigator.of(context).pop(); // Chiudi questo dialog
                    _restartGame(); // Chiama il restart
                  },
                ),
                TextButton(
                  child: Text("Esci"),
                  onPressed: () {
                     Navigator.of(context).pop(); // Chiudi questo dialog
                     Navigator.of(context).pop(); // Torna indietro dalla pagina del gioco
                  },
                ),
              ],
            );
          },
        );
     } else {
       // Se il gioco finisce per altri motivi (es. uscita manuale),
       // viene gestito da _handleExit e WillPopScope
        print("Fine gioco non gestita esplicitamente (es. uscita utente)");
     }
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
        // Azioni prima di uscire (es. stop audio)
        await _audioService.stop();
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
        appBar: AppBarTitle("Indovina la sillaba"), // Usa il tuo AppBar
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: colorScheme.primary)) // Loader iniziale
            : !_gameStarted
                ? Center(child: Text("Premi 'Inizia' per cominciare!", style: textTheme.bodyLarge)) // Messaggio pre-gioco
                : SafeArea( // SafeArea per evitare notch/barre di sistema
                    child: Column(
                      children: [
                        // Barra Punteggio e Timer (dal tuo Metodi.dart o funzioni.dart)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0), // Aggiungi padding sopra la barra
                          child: ScoreTimerBar(
                            maxScore: _maxScore,
                            timeLeft: _timeLeft < 0 ? 0 : _timeLeft, // Non mostrare negativi
                            maxTime: GAME_DURATION,
                          ),
                        ),


                        // Area centrale del gioco
                        Expanded(
                          child: Center(
                            child: SingleChildScrollView( // Permette scroll verticale
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min, // Occupa solo spazio necessario
                                children: [
                                  // Punteggio Attuale
                                  Text(
                                    "Punteggio: $_score",
                                    style: textTheme.headlineMedium?.copyWith( // Leggermente più grande
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onBackground,
                                    ),
                                  ),
                                  const SizedBox(height: 30), // Spazio

                                  // Bottone Riascolta Audio
                                  ElevatedButton.icon(
                                    onPressed: _playCorrectAudio,
                                    icon: Icon(Icons.volume_up_rounded, size: 28, color: colorScheme.onSecondary), // Icona e colore
                                    label: Text(
                                        "Riascolta",
                                        style: textTheme.titleMedium?.copyWith(color: colorScheme.onSecondary, fontWeight: FontWeight.w600)
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.secondary, // Colore secondario
                                      foregroundColor: colorScheme.onSecondary,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40), // Spazio aumentato

                                  // Bottoni Opzioni Sillabe
                                  if (_currentSyllableOptions.isNotEmpty)
                                    ..._currentSyllableOptions.map((syllable) {
                                      // Usa OptionButton se definito in Metodi.dart/funzioni.dart
                                      // Assicurati che possa mostrare caratteri Gurmukhi correttamente
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 7.0), // Spazio tra bottoni
                                        child: OptionButton(
                                          text: syllable,
                                          // Potresti dover passare uno stile specifico per Gurmukhi
                                          // textStyle: textTheme.headlineSmall?.copyWith( fontFamily: 'GurbaniFont' ), // Esempio
                                         textTheme: textTheme.headlineSmall?.copyWith(
                                              fontWeight: FontWeight.bold, // Grassetto per leggibilità
                                              fontSize: 26 // Dimensione font più grande per sillabe
                                          ),
                                          onPressed: () => _onSyllableSelected(syllable),
                                        ),
                                      );
                                    }).toList()
                                  else if (_gameStarted && !_isLoading) // Mostra solo se il gioco è partito ma le opzioni non ci sono ancora
                                      Padding(
                                       padding: const EdgeInsets.only(top: 20.0),
                                       child: CircularProgressIndicator(), // Loading opzioni
                                      ),

                                   const SizedBox(height: 20), // Spazio in fondo
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