import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:impara_gurbani/Metodi.dart';
import 'dart:async';
import 'package:impara_gurbani/Tema.dart';
import 'package:impara_gurbani/main.dart';

class AccountManagementPage extends StatefulWidget {
  const AccountManagementPage({super.key});

  @override
  _AccountManagementPageState createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  late String username;
  late String email;

  @override
  void initState() {
    super.initState();
    // Recupera i dati dell'utente autenticato
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      username = user.displayName ?? "No name provided";
      email = user.email ?? "No email provided";
    } else {
      username = "No name provided";
      email = "No email provided";
    }
  }

  void _editAccountDetails() {
    // Logica per modificare lo username
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController usernameController =
            TextEditingController(text: username);

        return AlertDialog(
          title: Text("Edit Username"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: "Username"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Salva il nuovo username su Firebase
                var user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await user.updateDisplayName(usernameController.text);
                  await user.reload(); // Ricarica i dati dell'utente
                  setState(() {
                    username = usernameController.text;
                  });
                }
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Color.fromARGB(255, 0, 51, 102), // Tasto Save bianco
                foregroundColor: Colors.white, // Colore testo nero
              ),
              child: Text("Salva"),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    // Logica per fare il logout
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pop(); // Torna alla schermata precedente
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Account Deletion"),
          content: DeleteAccountCountdown(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBarTitle('Gestione Account'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Titolo principale
              Text(
                "Dettagli Profilo",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Mostra i dettagli dell'account
              Text(
                "Username: $username",
                style: theme.textTheme.bodyLarge,
              ),
              Text(
                "Email: $email",
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              // Bottone per modificare i dettagli
              ElevatedButton(
                onPressed: _editAccountDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                  ),
                ),
                child: Text(
                  "Cambia Username",
                  style:
                      theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              // Bottone per il logout
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                  ),
                ),
                child: Text(
                  "Esci",
                  style:
                      theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              // Bottone per eliminare l'account
              ElevatedButton(
                onPressed: _deleteAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                  ),
                ),
                child: Text(
                  "Elimina Account",
                  style:
                      theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeleteAccountCountdown extends StatefulWidget {
  const DeleteAccountCountdown({super.key});

  @override
  _DeleteAccountCountdownState createState() => _DeleteAccountCountdownState();
}

class _DeleteAccountCountdownState extends State<DeleteAccountCountdown> {
  int _counter = 5; // Inizia il countdown da 5 secondi
  late Timer _timer;
  bool _isButtonEnabled =
      false; // Stato del tasto per confermare la cancellazione
  bool _isAccountDeleted = false; // Indica se l'account è stato cancellato

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_counter > 0) {
        setState(() {
          _counter--;
        });
      } else {
        // Quando il countdown arriva a zero, abilita il tasto
        setState(() {
          _isButtonEnabled = true;
        });
        _timer.cancel(); // Ferma il countdown
      }
    });
  }

  Future<void> _deleteAccount() async {
    try {
      var user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete(); // Elimina l'account
        setState(() {
          _isAccountDeleted = true; // Marca l'account come cancellato
        });

        // Dopo la cancellazione, attendi un momento e poi naviga alla pagina principale
        await Future.delayed(Duration(
            seconds:
                1)); // Fai una piccola attesa per evitare il flash di navigazione immediata

        // Reindirizza alla MainPage (sostituisci con la tua pagina principale)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MyApp()), // Sostituisci MainPage con la tua pagina principale
        );

        // Mostra un messaggio di successo con SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Account cancellato con successo"),
            backgroundColor: Colors.green, // Colore di sfondo per il messaggio
          ),
        );
      }
    } catch (e) {
      print("Error deleting account: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Il tuo account verrà eliminato tra $_counter secondi.",
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 16),
        // Row per i bottoni di Annulla e Conferma
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Spazio tra i bottoni
          children: [
            // Bottone Annulla
            TextButton(
              onPressed: () {
                _timer.cancel(); // Cancella il countdown se l'utente cancella
                Navigator.of(context).pop(); // Chiudi la finestra di conferma
              },
              child: Text("Annulla"),
            ),
            // Bottone Conferma
            ElevatedButton(
              onPressed: _isButtonEnabled && !_isAccountDeleted
                  ? () {
                      _deleteAccount(); // Procedi con l'eliminazione se il bottone è abilitato
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isButtonEnabled
                    ? Colors.red // Colore rosso quando abilitato
                    : const Color.fromARGB(255, 228, 120,
                        120), // Colore rosso chiaro quando disabilitato
              ),
              child: Text("Conferma",
                  style: TextStyle(color: Colors.white, fontFamily: 'Roboto')),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
