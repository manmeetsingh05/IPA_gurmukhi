import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:impara_gurbani/Tema.dart'; // Importa il tuo tema
import 'package:impara_gurbani/Metodi.dart'; // Per CircularTimer, AppBarTitle

// --- Costanti e Helper ---
const double GAME_DURATION = 15.0; // Durata del timer in secondi
const String MAX_SCORE_PAROLA_PATH = 'MaxParola';
const String MAX_SCORE_SILLABA_PATH = 'MaxSillabe';
const String MAX_SCORE_SILLABA2_PATH = 'MaxSillabe2';
// --- Servizi (Logica Non-UI) ---

class AudioService {
  final AudioPlayer _audioPlayer;

  // AudioPlayer viene iniettato
  AudioService(this._audioPlayer);

  Future<void> playAsset(String path) async {
    try {
      // Stoppa riproduzioni precedenti prima di iniziarne una nuova
      await _audioPlayer.stop();
      await _audioPlayer.setAsset(path);
      await _audioPlayer.play();
    } catch (e) {
      print("Errore nel caricamento/riproduzione dell'audio '$path': $e");
      // Potresti voler mostrare un messaggio all'utente qui
    }
  }

  Future<void> playErrorSound() async {
    // Assicurati che il path sia corretto e definito come costante se possibile
    await playAsset('assets/SUONI/error_sound.mp3');
  }

  // Potresti aggiungere un metodo stop() se necessario
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  // Importante: Chi fornisce l'AudioPlayer è responsabile del suo dispose
  // Se AudioPlayer è fornito da un Provider che ne gestisce il ciclo vita,
  // non serve un dispose qui. Altrimenti, aggiungilo.
  // void dispose() {
  //   _audioPlayer.dispose();
  // }
}

class ScoreService {
  final FirebaseAuth _auth;
  final FirebaseDatabase _database;

  // Dipendenze iniettate
  ScoreService(this._auth, this._database);

 Future<int> loadMaxScore(String gameScorePath) async {
  try {
    User? user = _auth.currentUser;

    if (user != null) {
      DatabaseReference ref = _database.ref('users/${user.uid}/$gameScorePath');
      final snapshot = await ref.get();
      print('users/${user.uid}/$gameScorePath');

      if (snapshot.exists) {
        final value = snapshot.value;
        // Metodo più sicuro: controlla se è un int
        if (value is int) {
          return value;
        }
        // Potresti anche gestire il caso in cui sia un double senza decimali
        else if (value is double && value == value.truncate()) {
           return value.toInt();
        }
        // Potresti anche gestire il caso in cui sia una stringa numerica (meno ideale)
        else if (value is String) {
           return int.tryParse(value) ?? 0; // Tenta di parsare, se fallisce ritorna 0
        }
        // Se non è un tipo gestibile, ritorna 0
        else {
           print("Valore inatteso per '$gameScorePath': $value (Tipo: ${value.runtimeType})");
           return 0;
        }
      } else {
        // Il nodo non esiste, quindi non c'è punteggio salvato
        return 0;
      }
    } else {
      // Nessun utente loggato
      return 0;
    }
  } catch (e) {
    print("Errore durante il caricamento del punteggio massimo per '$gameScorePath': $e");
    return 0; // Ritorna 0 in caso di errore generico
  }
}

  Future<void> updateMaxScore(String gameScorePath, int currentScore, int currentMaxScore) async {
    // Evita scritture inutili se il punteggio non è maggiore
    if (currentScore <= currentMaxScore) return;

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DatabaseReference ref = _database.ref('users/${user.uid}/$gameScorePath');
        await ref.set(currentScore);
        print("Max score per '$gameScorePath' aggiornato: $currentScore");
      }
    } catch (e) {
      print("Errore durante l'aggiornamento del max score per '$gameScorePath': $e");
    }
  }
}

// --- Componenti UI Condivise ---

// Dialog iniziale
void showStartGameDialog(BuildContext context, VoidCallback onStart) {
  final theme = Theme.of(context);
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/saluto.png', height: 180),
            const SizedBox(height: 16),
            Text(
              "Benvenuto!",
              style: AppTheme.titleStyle.copyWith(
                color: theme.colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Sei pronto per iniziare il gioco?",
              style: AppTheme.bodyStyle.copyWith(
                color: theme.colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onStart();
              },
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.secondary,
                textStyle: theme.textTheme.labelLarge,
              ),
              child: const Text("Inizia"),
            ),
          ],
        ),
      );
    },
  );
}

// Dialog di fine gioco (tutte le parole/sillabe indovinate)
void showEndGameDialog(BuildContext context, VoidCallback onRestart) {
  final theme = Theme.of(context);
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: theme.cardColor, // O theme.colorScheme.surface
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Complimenti!",
          style: AppTheme.headlineStyle.copyWith(color: AppTheme.accentColor), // Usa theme?
           textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Hai completato tutte le sfide disponibili!",
              style: AppTheme.bodyStyle.copyWith(color: theme.colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Icon(Icons.star, size: 50, color: theme.colorScheme.secondary),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRestart();
            },
            child: Text(
              "Ricomincia",
              style: AppTheme.bodyStyle.copyWith(color: theme.colorScheme.secondary),
            ),
          ),
        ],
      );
    },
  );
}

// Dialog di risultato (corretto/sbagliato)
void showResultDialog({
  required BuildContext context,
  required bool isCorrect,
  required String correctAnswerText, // Es: "La parola corretta era: ..."
  required VoidCallback onContinue,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  showDialog(
    barrierDismissible: false, // Impedisce la chiusura toccando fuori
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              isCorrect ? 'assets/images/right.png' : 'assets/images/wrong.png',
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
              correctAnswerText,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Chiude il dialog
                onContinue(); // Esegue l'azione successiva (es. prossima domanda)
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

// Dialog di conferma uscita
Future<bool> showConfirmExitDialog(BuildContext context) async {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  bool? shouldPop = await showDialog<bool>( // Specifica il tipo restituito
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/question.png', height: 150),
            const SizedBox(height: 16),
            Text(
              "Conferma uscita",
              style: AppTheme.titleStyle.copyWith(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Se interrompi il gioco ora, perderai il punteggio attuale.",
              style: AppTheme.bodyStyle.copyWith(
                color: colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true), // Ritorna true
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.secondary,
                    textStyle: textTheme.labelLarge,
                  ),
                  child: const Text("Esci"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // Ritorna false
                  style: TextButton.styleFrom(
                    foregroundColor: textTheme.bodyMedium?.color,
                    textStyle: textTheme.labelLarge,
                  ),
                  child: const Text("Annulla"),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );

  // Ritorna il valore scelto dall'utente, o false se il dialog viene chiuso in altro modo
  return shouldPop ?? false;
}

// Widget Barra Superiore (Punteggio Max e Timer)
class ScoreTimerBar extends StatelessWidget {
  final int maxScore;
  final double timeLeft;
  final double maxTime;

  const ScoreTimerBar({
    Key? key,
    required this.maxScore,
    required this.timeLeft,
    required this.maxTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Punteggio Massimo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.primary, width: 1.5),
            ),
            child: Text(
              "Max: $maxScore",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          // Timer
          Stack(
            alignment: Alignment.center,
            children: [
              // Assicurati che CircularTimer sia definito in Metodi.dart
              // o usa un CircularProgressIndicator come fallback
              SizedBox(
                width: 60, // Dimensioni ridotte per il timer
                height: 60,
                child: CircularTimer( // O il tuo widget timer
                   timeLeft: timeLeft,
                   maxTime: maxTime,
                   size: 60, // Passa la dimensione corretta
                 ),
                // Fallback se CircularTimer non esiste:
                // child: CircularProgressIndicator(
                //   value: timeLeft / maxTime,
                //   strokeWidth: 6,
                //   backgroundColor: colorScheme.surfaceVariant,
                //   valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                // ),
              ),
              Text(
                "${timeLeft.toInt()}",
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// Bottone Opzione Riutilizzabile
class OptionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon; // Icona opzionale (per riascoltare audio sillaba)

  const OptionButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon, TextStyle? textTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget buttonContent = Text(
      text,
      style: textTheme.titleLarge?.copyWith( // Leggermente più grande? O titleMedium
        color: colorScheme.onPrimary, // Testo bianco su sfondo primario
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );

    if (icon != null) {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min, // Non occupa tutta la larghezza
        children: [
           Icon(icon, color: colorScheme.onPrimary),
           const SizedBox(width: 8),
           buttonContent,
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(240, 55), // Larghezza leggermente maggiore?
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          elevation: 5,
          shadowColor: Colors.black38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: buttonContent,
      ),
    );
  }
}


// Placeholder per CircularTimer se non definito altrove
class CircularTimer extends StatelessWidget {
 final double timeLeft;
 final double maxTime;
 final double size;

 const CircularTimer({
   Key? key,
   required this.timeLeft,
   required this.maxTime,
   required this.size,
 }) : super(key: key);

 @override
 Widget build(BuildContext context) {
   final colorScheme = Theme.of(context).colorScheme;
   return SizedBox(
     width: size,
     height: size,
     child: CircularProgressIndicator(
       value: (maxTime > 0) ? timeLeft / maxTime : 0.0,
       strokeWidth: 6,
       backgroundColor: colorScheme.surfaceVariant,
       valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
     ),
   );
 }
}