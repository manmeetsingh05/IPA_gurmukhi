import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:impara_gurbani/Tema.dart'; // importa il tuo file di tema

class GameUtils {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<void> loadMaxScore(Function(int) setMaxScore, String path) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DatabaseReference ref = _database.ref('$path/${user.uid}');
        final snapshot = await ref.get();
        setMaxScore(snapshot.exists ? (snapshot.value as int) : 0);
      } else {
        setMaxScore(0);
      }
    } catch (e) {
      print("Errore durante il caricamento del punteggio massimo: $e");
      setMaxScore(0);
    }
  }

  Future<void> updateMaxScore(int currentScore, String path) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DatabaseReference ref = _database.ref('$path/${user.uid}');
        final snapshot = await ref.get();
        num currentMaxScore = snapshot.exists ? (snapshot.value as num) : 0;

        if (currentScore > currentMaxScore) {
          await ref.set(currentScore);
          print("Max streak aggiornata: $currentScore");
        }
      }
    } catch (e) {
      print("Errore durante l'aggiornamento della streak massima: $e");
    }
  }

  void showStartScreen(BuildContext context, Function onStart) {
  final theme = Theme.of(context);
  final textColor = theme.textTheme.bodyMedium?.color;

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/saluto.png', // Assicurati che l'immagine esista
              height: 180,
            ),
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

  void showEndScreen(BuildContext context, Function onRestart) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text(
            "Complimenti!",
            style: AppTheme.headlineStyle.copyWith(color: AppTheme.accentColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Hai indovinato tutte le parole disponibili!",
                style: AppTheme.bodyStyle.copyWith(color: textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Icon(Icons.star, size: 50, color: theme.colorScheme.secondary),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRestart();
              },
              child: Text(
                "Ricomincia",
                style: AppTheme.bodyStyle
                    .copyWith(color: theme.colorScheme.secondary),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> playAudio(String path) async {
    try {
      await _audioPlayer.setAsset(path);
      await _audioPlayer.play();
    } catch (e) {
      print("Errore nel caricamento dell'audio: $e");
    }
  }

  Future<void> playErrorSound() async {
    try {
      await _audioPlayer.setAsset('SUONI/error_sound.mp3');
      await _audioPlayer.play();
    } catch (e) {
      print("Errore nel caricamento dell'audio di errore: $e");
    }
  }
}

Future<bool> UscitaGiochi(BuildContext context) async {
  final theme = Theme.of(context);
  final textColor = theme.textTheme.bodyMedium?.color;

  bool? shouldPop = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/question.png', // <-- Assicurati che l'immagine esista nel tuo progetto
              height: 150,
            ),
            const SizedBox(height: 16),
            Text(
              "Conferma uscita",
              style: AppTheme.titleStyle.copyWith(
                color: theme.colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Se interrompi il gioco ora, perderai il punteggio attuale.",
              style: AppTheme.bodyStyle.copyWith(
                color: theme.colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.secondary,
                    textStyle: theme.textTheme.labelLarge,
                  ),
                  child: const Text("Esci"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: textColor,
                    textStyle: theme.textTheme.labelLarge,
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

  return shouldPop ?? false;
}

