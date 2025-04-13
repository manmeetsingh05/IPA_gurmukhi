import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Aggiungi l'import per GoogleSignIn
import '../main.dart';
import 'SignUpPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  // Variabili per gestire lo stato di caricamento e gli errori
  bool _isLoading = false;
  String _errorMessage = '';

  // Funzione per il login con Google
  Future<void> _loginWithGoogle() async {
  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  try {
    // Inizializza GoogleSignIn
    final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '353235625395-dqrbddig47vaj54etlc5ur7qt604r27d.apps.googleusercontent.com');
    await googleSignIn.signInSilently(); // Metodo per il login silenzioso
    // Avvia il processo di login
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      // L'utente ha annullato il login
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Ottieni l'oggetto di autenticazione di Google
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Crea una credenziale di Firebase con il token di Google
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Accedi con la credenziale di Firebase
    UserCredential userCredential = await _auth.signInWithCredential(credential);
    User? user = userCredential.user;

    // Verifica se l'utente ha già un nome
    if (user != null && user.displayName == null) {
      // Mostra un dialog per inserire un username
      _showUsernameDialog(user);
    } else {
      // Se l'utente ha già un nome, naviga alla home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const MyHomePage(
                title: 'Impara Gurmukhi')), // Modifica in base alla tua home page
      );
    }
  } on FirebaseAuthException catch (e) {
    setState(() {
      _isLoading = false;
      _errorMessage = e.message ?? 'Errore sconosciuto';
    });
  }
}

void _showUsernameDialog(User? user) {
  TextEditingController usernameController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Crea il tuo username'),
        content: TextField(
          controller: usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Aggiorna il displayName dell'utente su Firebase
              try {
                await user?.updateDisplayName(usernameController.text);
                await user?.reload(); // Ricarica l'utente solo se non è nullo
                user = FirebaseAuth.instance.currentUser; // Ritorna l'utente aggiornato
                Navigator.of(context).pop();

                // Naviga alla home
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MyHomePage(
                          title: 'Impara Gurmukhi')),
                );
              } catch (e) {
                setState(() {
                  _errorMessage = 'Errore durante l\'aggiornamento del nome';
                });
              }
            },
            child: const Text('Salva'),
          ),
        ],
      );
    },
  );
}


  // Funzione per il login con email e password
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Effettua il login con email e password
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Se il login ha successo, naviga alla home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const MyHomePage(
                title: 'Impara Gurmukhi')), // Modifica in base alla tua home page
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message ?? 'Errore sconosciuto';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo o icona
            Image.asset(
              'assets/images/dalpanth.png',
              height: 300,
              width: 300,
            ),
            const SizedBox(height: 30),

            // Email Input
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // Password Input
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            // Caricamento o bottone di login
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, 255, 255, 255),
                      backgroundColor: Color.fromARGB(255, 0, 51,
                          102), // Cambia 'primary' con 'backgroundColor'
                    ),
                    child: const Text('Accedi', style: TextStyle(fontSize: 18)),
                  ),
            const SizedBox(height: 20),

            // Naviga alla pagina di registrazione
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  foregroundColor: Color.fromARGB(255, 255, 255, 255),
                  backgroundColor: const Color.fromARGB(255,235,173,61)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpPage(),
                  ),
                );
              },
              child: const Text('Registrati', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),

            // Pulsante per accedere con Google
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Colore di sfondo bianco
                //  onPrimary: Colors.black, // Colore del testo
                side: BorderSide(color: Colors.black), // Bordo
              ),
              onPressed: _loginWithGoogle,
              icon: Image.asset('assets/images/google_logo.png',
                  height: 24), // Aggiungi l'icona di Google
              label: const Text('Accedi con Google',
                  style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),

            // Mostra l'errore se presente
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
