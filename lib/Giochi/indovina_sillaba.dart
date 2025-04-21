import 'package:flutter/material.dart';
import 'package:impara_gurbani/LISTE.dart'; // Contiene muharniCombinations
// Assicurati che il path a funzioni.dart (o game_utils_refactored.dart) sia corretto
import 'package:impara_gurbani/Giochi/funzioni.dart'; // <--- MODIFICA SE NECESSARIO
import 'package:just_audio/just_audio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'dart:async';
import 'package:impara_gurbani/Metodi.dart';

class Sillable2 extends StatefulWidget {
  @override
  _Sillable2State createState() =>
      _Sillable2State();
}

class _Sillable2State
    extends State<Sillable2> {
  // --- Servizi e Dipendenze ---
  late final AudioPlayer _audioPlayer;
  late final AudioService _audioService;
  late final ScoreService _scoreService;
  final Random _random = Random();
  // Firebase/Auth istanze (potrebbero essere iniettate da un provider)
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // --- Stato del Gioco ---
  String _currentSyllable = "";
  String _correctPronunciation = "";
  List<Map<String, String>> _options = [];
  int _score = 0;
  int _maxScore = 0;
  double _timeLeft = GAME_DURATION; // Usa la costante dal file utils
  Timer? _timer;
  bool _isLoading = true; // Stato per caricamento iniziale max score
  bool _gameStarted = false; // Per evitare doppio start

  @override
  void initState() {
    super.initState();
    // Inizializza servizi
    _audioPlayer = AudioPlayer();
    _audioService = AudioService(_audioPlayer);
    _scoreService = ScoreService(_auth, _database);

    // Carica dati iniziali e mostra schermata di avvio
    _initializeGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose(); // Dispose dell'AudioPlayer qui!
    super.dispose();
  }

  // --- Inizializzazione e Gestione Ciclo Vita Gioco ---

  Future<void> _initializeGame() async {
    // Assicura che lo stato venga aggiornato solo se il widget è montato
    if (!mounted) return;
    setState(() => _isLoading = true);
    _maxScore = await _scoreService.loadMaxScore(MAX_SCORE_SILLABA2_PATH); // Usa costante
    if (!mounted) return;
    setState(() => _isLoading = false);

    // Mostra il dialog di inizio solo dopo il caricamento
    // e se il gioco non è già in corso
    if (!_gameStarted && mounted) {
      // Usa addPostFrameCallback per assicurare che il build sia completato
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) { // Controlla di nuovo 'mounted' prima di mostrare il dialog
          showStartGameDialog(context, _startGame);
        }
      });
    }
  }

  void _startGame() {
    if (_gameStarted || !mounted) return; // Evita riavvii multipli e chiamate non montate
    setState(() {
      _score = 0; // Resetta punteggio all'inizio
      _timeLeft = GAME_DURATION;
      _gameStarted = true;
    });
    _generateSyllable();
    _startTimer();
  }

  // --- Logica Core del Gioco ---

  void _generateSyllable() {
    if (!mounted) return; // Controllo se il widget è ancora nell'albero

    final List<String> keys = muharniCombinations.keys.toList(); // Estrai le chiavi qui
    if (keys.isEmpty) {
      print("Errore: muharniCombinations è vuoto!");
      setState(() {
        _currentSyllable = "Errore Dati";
        _correctPronunciation = "";
        _options = [];
      });
      return;
    }

    final randomKey = keys[_random.nextInt(keys.length)];
    final List<Map<String, String>>? combinations = muharniCombinations[randomKey]; // Lista di Map

    if (combinations == null || combinations.isEmpty) {
       print("Errore: Combinazioni vuote per la chiave $randomKey");
       // Prova con un'altra chiave o gestisci
       _generateSyllable(); // Riprova (attenzione a possibili loop infiniti se i dati sono corrotti)
       return;
    }

    final randomCombination = combinations[_random.nextInt(combinations.length)];

    setState(() {
      _currentSyllable = randomCombination.keys.first;
      _correctPronunciation = randomCombination.values.first;
      // Passa le combinazioni per quella chiave a _generateOptions
      _options = _generateOptions(randomKey, _correctPronunciation, List.from(combinations)); // Passa una copia
    });
  }

  List<Map<String, String>> _generateOptions(
      String key, String correctPronunciation, List<Map<String, String>> combinations) {

    final List<Map<String, String>> options = [];
    // Trova la mappa corretta da aggiungere (necessario perché la sillaba è già stata scelta)
    final correctOptionMap = combinations.firstWhere(
            (map) => map.values.first == correctPronunciation,
            orElse: () => {_currentSyllable: correctPronunciation} // Fallback se non trovata (improbabile)
    );
    options.add(correctOptionMap);

    // Crea una copia della lista per non modificare l'originale e rimuovi la corretta
    final List<Map<String, String>> availableCombinations = List.from(combinations);
    availableCombinations.removeWhere((map) => map.values.first == correctPronunciation);

    // Mescola le rimanenti per prendere distrattori casuali
    availableCombinations.shuffle(_random);

    int neededDistractors = 2; // Vogliamo 3 opzioni totali (1 corretta + 2 distrattori)
    int addedDistractors = 0;
    for (var combination in availableCombinations) {
      if (addedDistractors < neededDistractors) {
         final pronunciation = combination.values.first;
         // Assicurati che il distrattore non sia già stato aggiunto
         if (!options.any((opt) => opt.values.first == pronunciation)) {
           options.add(combination);
           addedDistractors++;
         }
      } else {
        break; // Abbiamo abbastanza opzioni
      }
    }

    // Se mancano ancora distrattori (es. solo 1 o 2 combinazioni totali per quella chiave)
    // Questa parte è opzionale e dipende da come vuoi gestire i dati scarsi.
    // Per ora, se non ci sono abbastanza distrattori, il gioco mostrerà meno di 3 opzioni.
    if (options.length < 3) {
       print("Attenzione: Non abbastanza opzioni uniche per la chiave $key. Mostrate ${options.length} opzioni.");
    }

    options.shuffle(_random); // Mescola le opzioni finali (corretta + distrattori)
    return options;
  }


  void _startTimer() {
    _timer?.cancel(); // Cancella timer precedente se esiste
    if (!mounted) return;
    setState(() => _timeLeft = GAME_DURATION); // Resetta il tempo all'inizio

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { // Controlla ad ogni tick
        timer.cancel();
        return;
      }
      setState(() {
        if (_timeLeft > 1) { // Scalo di 1 secondo intero
          _timeLeft -= 1;
        } else if (_timeLeft == 1) { // Ultimo secondo
           _timeLeft = 0; // Imposta a 0
           timer.cancel(); // Ferma il timer
           _handleTimeout(); // Gestisci il timeout
        } else { // Se per qualche motivo timeLeft è <= 0
           timer.cancel();
        }
      });
    });
  }

  void _handleTimeout() {
    if (!mounted) return;
    _audioService.playErrorSound(); // Suono per tempo scaduto
    _showGameResult(isCorrect: false, timeExpired: true);
  }

  Future<void> _playSyllableAudio(String syllable) async {
    // Costruisci il path corretto
    final path = 'assets/SUONI/SILLABE/$syllable.aac';
    await _audioService.playAsset(path);
  }

  void _onOptionSelected(String selectedPronunciation) {
    if (!mounted) return;
    _timer?.cancel(); // Ferma il timer quando viene data una risposta

    bool isCorrect = selectedPronunciation == _correctPronunciation;

    if (isCorrect) {
      // Aggiorna prima lo stato locale
      int newScore = _score + 1;
      int previousMaxScore = _maxScore; // Salva il max score prima dell'aggiornamento
      setState(() {
        _score = newScore;
        if (newScore > _maxScore) {
          _maxScore = newScore;
        }
      });
      // Poi chiama il servizio per aggiornare Firebase se necessario
      if (newScore > previousMaxScore) {
         _scoreService.updateMaxScore(MAX_SCORE_SILLABA2_PATH, newScore, previousMaxScore);
      }
      _showGameResult(isCorrect: true);
    } else {
      _audioService.playErrorSound(); // Suono per risposta errata
      _showGameResult(isCorrect: false);
    }
  }

  // --- Gestione UI e Risultati ---

  void _showGameResult({required bool isCorrect, bool timeExpired = false}) {
    if (!mounted) return;

    String message;
    if (isCorrect) {
      message = "Ottimo lavoro!";
    } else if (timeExpired) {
      message = "Tempo scaduto!\nLa pronuncia corretta era:\n$_correctPronunciation";
    } else {
      message = "La pronuncia corretta era:\n$_correctPronunciation";
    }

    // Usa il dialog centralizzato
    showResultDialog(
      context: context,
      isCorrect: isCorrect,
      correctAnswerText: message, // <-- CORRETTO: Usa il nome parametro corretto
      onContinue: () {
        // Azione da eseguire dopo che l'utente preme "Continua"
        if (!mounted) return; // Controllo sicurezza
        setState(() {
          if (!isCorrect) {
             _score = 0; // Resetta il punteggio solo se sbagliato o scaduto
          }
        });
        _generateSyllable(); // Prepara la prossima domanda
        _startTimer();      // Fa ripartire il timer
      },
    );
  }

   // Usa la funzione del file utils per la conferma uscita
  Future<bool> _handleExit() async {
    if (!mounted) return false; // Non fare nulla se non montato
    bool wasRunning = _timer?.isActive ?? false;
    _timer?.cancel(); // Metti in pausa il timer mentre il dialog è aperto
    bool shouldExit = await showConfirmExitDialog(context);
    if (!shouldExit && _gameStarted && wasRunning && mounted) {
       _startTimer(); // Riprendi il timer se l'utente annulla e il gioco era partito e il timer era attivo
    } else if (shouldExit) {
        // Azioni aggiuntive prima di uscire se necessario (es. stop audio)
        await _audioService.stop();
    }
    return shouldExit; // Permette o nega la navigazione indietro
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return WillPopScope(
      onWillPop: _handleExit, // Usa la funzione per la conferma
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        // Assicurati che AppBarTitle sia importato/definito correttamente
        appBar: AppBarTitle("Indovina la Sillaba"),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: colorScheme.primary)) // Mostra loader iniziale
            : !_gameStarted
                ? Center(child: Text("Premi 'Inizia' per cominciare!", style: textTheme.bodyLarge)) // Messaggio prima del dialog
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0)
                             .copyWith(top: 16.0, bottom: 16.0), // Padding consistente
                    child: Column(
                      children: [
                        // Barra Punteggio e Timer
                        ScoreTimerBar(
                          maxScore: _maxScore,
                          timeLeft: _timeLeft < 0 ? 0 : _timeLeft, // Assicura che non sia < 0
                          maxTime: GAME_DURATION,
                        ),

                        // Sezione centrale del gioco
                        Expanded(
                          child: Center(
                            child: SingleChildScrollView( // Permette scroll se contenuto eccede
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min, // Occupa solo spazio necessario
                                children: [
                                  // Punteggio attuale
                                  Text(
                                    "Punteggio: $_score",
                                    style: textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onBackground,
                                    ),
                                  ),
                                  const SizedBox(height: 40), // Spazio ridotto

                                  // Sillaba da indovinare
                                  if (_currentSyllable.isNotEmpty)
                                    Text(
                                      _currentSyllable,
                                      style: textTheme.displayLarge?.copyWith( // Ancora più grande
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onBackground,
                                      ),
                                      key: ValueKey(_currentSyllable), // Key per animazioni future
                                    )
                                  else
                                     CircularProgressIndicator(), // Placeholder se sillaba non ancora caricata

                                  const SizedBox(height: 40), // Spazio

                                  // Bottoni Opzioni con Audio
                                  if (_options.isNotEmpty) // Mostra solo se ci sono opzioni
                                     ..._options.map((option) {
                                        final syllable = option.keys.first;
                                        final pronunciation = option.values.first;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 7.0), // Spazio ridotto tra bottoni
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              // Bottone con la pronuncia
                                              // Usa OptionButton da funzioni.dart se preferisci stile unificato
                                              ElevatedButton(
                                                onPressed: () => _onOptionSelected(pronunciation),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: colorScheme.primary,
                                                  foregroundColor: colorScheme.onPrimary,
                                                  minimumSize: const Size(210, 55), // Leggermente più stretto
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                  elevation: 5,
                                                  shadowColor: Colors.black38,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(14),
                                                  ),
                                                ),
                                                child: Text(
                                                  pronunciation,
                                                  style: textTheme.titleMedium?.copyWith(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 18 // Dimensione font esplicita
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              // Bottone per ascoltare la sillaba
                                              IconButton(
                                                onPressed: () => _playSyllableAudio(syllable),
                                                icon: Icon(Icons.volume_up_rounded), // Icona audio migliore
                                                color: colorScheme.secondary,
                                                iconSize: 30, // Dimensione icona
                                                tooltip: "Ascolta pronuncia",
                                                splashRadius: 24, // Area splash
                                                padding: EdgeInsets.zero, // Rimuovi padding extra
                                                constraints: BoxConstraints(), // Rimuovi vincoli di dimensione default
                                              ),
                                            ],
                                          ),
                                        );
                                     }).toList()
                                  else if (!_isLoading) // Mostra solo se non sta caricando e le opzioni sono vuote
                                    Text("Caricamento opzioni...", style: textTheme.bodyMedium)

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