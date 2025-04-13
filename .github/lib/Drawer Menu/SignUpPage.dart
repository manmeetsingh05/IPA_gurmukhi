import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'LoginPage.dart'; // Modifica in base al percorso della pagina di login

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController(); // Nuovo controller per lo username
  final _auth = FirebaseAuth.instance;

  // Variabili per gestire lo stato di caricamento e gli errori
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Effettua la registrazione con email e password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Aggiorna il profilo dell'utente con lo username
      User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(_usernameController.text); // Aggiorna lo username
        await user.reload(); // Ricarica il profilo aggiornato
      }

      // Se la registrazione ha successo, naviga alla pagina di login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        // Gestione errori più specifici
        if (e.code == 'weak-password') {
          _errorMessage =
              'La password è troppo debole. Prova con una più lunga e complessa.';
        } else if (e.code == 'email-already-in-use') {
          _errorMessage =
              'Un account con questa email esiste già. Prova a fare il login.';
        } else if (e.code == 'invalid-email') {
          _errorMessage = 'L\'email inserita non è valida.';
        } else {
          // Gestione di errori generici
          _errorMessage =
              e.message ?? 'Errore sconosciuto durante la registrazione';
        }
      });
    } catch (e) {
      // Gestione di altri tipi di errori (non FirebaseAuthException)
      setState(() {
        _isLoading = false;
        _errorMessage = 'Si è verificato un errore imprevisto: $e';
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

            // Username Input (Nuovo campo)
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),

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

            // Caricamento o bottone di registrazione
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 0, 51, 102),
                    ),
                    child: const Text('Registrati', style: TextStyle(fontSize: 18)),
                  ),
            const SizedBox(height: 20),

            // Mostra l'errore se presente
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Pulsante per accedere
            TextButton(
              onPressed: () {
                // Naviga alla pagina di login
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Hai già un account? Accedi',
                  style: TextStyle(fontSize: 18, color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}
