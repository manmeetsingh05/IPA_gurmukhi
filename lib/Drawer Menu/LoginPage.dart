import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../main.dart'; // Assicurati che MyHomePage sia in main.dart
import 'SignUpPage.dart'; // Assicurati che SignUpPage sia in SignUpPage.dart
import 'RecuperoPassword.dart'; // Assicurati che PasswordResetPage sia in RecuperoPassword.dart

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn(); // Ricorda la configurazione Client ID per web/android/ios

  bool _isLoading = false;
  String _errorMessage = '';

  // --- LOGIN CON GOOGLE ---
  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Esegui il sign-out da eventuali sessioni Google precedenti
      await _googleSignIn.signOut();

      // Avvia il flusso di login con Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Se l'utente annulla
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Ottieni le credenziali Auth
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // **CONTROLLO PREVENTIVO**: Verifica se l'email è già registrata con un altro metodo
      final List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(googleUser.email);

      if (signInMethods.isNotEmpty && !signInMethods.contains(GoogleAuthProvider.PROVIDER_ID)) {
        // L'utente esiste già con un altro metodo (es. email/password)
        setState(() {
          _isLoading = false;
          _errorMessage = 'Account già registrato con email/password. Accedi con quel metodo.';
        });
        await _googleSignIn.signOut(); // Disconnetti da Google
        return; // Interrompi
      }

      // Prosegui con l'accesso a Firebase
      await _auth.signInWithCredential(credential);

      // Login avvenuto con successo, vai alla home
      _navigateToHome();

    } on FirebaseAuthException catch (e) {
       await _handleGoogleLoginError(e); // Gestisci errori Firebase specifici
    } catch (e) {
      // Gestisci altri errori (configurazione ClientID, rete, ecc.)
      setState(() {
        _isLoading = false;
        // Mostra un messaggio generico o l'errore specifico se utile per il debug
        _errorMessage = 'Errore durante l\'accesso con Google. Verifica la configurazione.';
        // Logga l'errore per debug: print('Google Sign-In Error: ${e.toString()}');
      });
      await _googleSignIn.signOut(); // Disconnetti in caso di errore
    } finally {
       // Assicurati che il loading sia false se non è già stato gestito
       if(mounted && _isLoading){
         setState(() => _isLoading = false);
       }
    }
  }

  // --- LOGIN CON EMAIL/PASSWORD ---
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Per favore, inserisci sia email che password.';
      });
      return;
    }

    try {
      // **CONTROLLO PREVENTIVO**: Verifica se l'email è già registrata con Google
      final List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(email);

      if (signInMethods.contains(GoogleAuthProvider.PROVIDER_ID)) {
         // Esiste un account Google collegato a questa email.
         setState(() {
           _isLoading = false;
           _errorMessage = 'Questa email è collegata a un account Google. Per favore, usa il pulsante "Accedi con Google".';
         });
         return; // Interrompi
      }

      // Se il controllo è superato, procedi con il login email/password
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _navigateToHome(); // Login riuscito

    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _mapLoginError(e); // Mappa errore Firebase
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Si è verificato un errore imprevisto.';
         // Logga l'errore per debug: print('Email/Pass Login Error: ${e.toString()}');
      });
    } finally {
        // Assicurati che il loading sia false se non è già stato gestito
       if(mounted && _isLoading){
         setState(() => _isLoading = false);
       }
    }
  }

  // --- HELPERS ---

  // Gestione errori specifici Google Sign-In con Firebase
  Future<void> _handleGoogleLoginError(FirebaseAuthException e) async {
     String errorMessage;
     switch (e.code) {
       case 'account-exists-with-different-credential':
         // Questo caso dovrebbe essere già coperto dal controllo preventivo, ma lo teniamo per sicurezza
         errorMessage = 'Esiste già un account con questa email ma credenziali diverse.';
         break;
       case 'invalid-credential':
         errorMessage = 'Credenziali Google non valide o scadute. Riprova.';
         break;
       case 'operation-not-allowed':
          errorMessage = 'Accesso con Google non abilitato nel tuo progetto Firebase.';
          break;
       case 'user-disabled':
         errorMessage = 'Questo account utente è stato disabilitato.';
         break;
       case 'user-not-found':
         errorMessage = 'Nessun utente trovato per queste credenziali Google.';
         break;
       default:
         errorMessage = 'Errore Firebase: ${e.message ?? e.code}';
     }
     setState(() {
       _isLoading = false;
       _errorMessage = errorMessage;
     });
     await _googleSignIn.signOut();
  }

  // Mappa errori comuni di login email/password
  String _mapLoginError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Formato email non valido.';
      case 'user-disabled':
        return 'Questo account è stato disabilitato.';
      case 'user-not-found':
        // Dopo il nostro controllo preventivo, questo significa "non trovato con password"
        return 'Nessun account trovato per questa combinazione email/password.';
      case 'wrong-password':
        return 'Password errata.';
      case 'invalid-credential': // Più generico per credenziali errate
         return 'Credenziali non valide (email o password errate).';
      default:
        // Restituisci un messaggio generico o il codice/messaggio Firebase per debug
        return 'Errore durante l\'accesso: ${e.message ?? e.code}';
    }
  }

  // Naviga alla pagina principale
  void _navigateToHome() {
     if (!mounted) return; // Controllo sicurezza
     Navigator.of(context).pushReplacement(
       MaterialPageRoute(
         builder: (context) => const MyHomePage(title: 'Impara Gurmukhi'),
       ),
     );
  }

  // Naviga alla pagina di registrazione
  void _navigateToSignUp() {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpPage()),
    );
  }

  // Naviga alla pagina di recupero password
  void _navigateToPasswordReset() {
     if (!mounted) return;
     Navigator.push(
       context,
       MaterialPageRoute(builder: (context) => const PasswordResetPage()),
     );
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- WIDGET BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/dalpanth.png', // Assicurati che il path sia corretto
                    height: 200,
                  ),
                  const SizedBox(height: 40),

                  // Campo Email
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !_isLoading, // Disabilita durante il caricamento
                  ),
                  const SizedBox(height: 16),

                  // Campo Password
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                     enabled: !_isLoading, // Disabilita durante il caricamento
                  ),
                  const SizedBox(height: 8),

                  // Link Password Dimenticata
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _navigateToPasswordReset,
                      child: const Text('Password dimenticata?'),
                    ),
                  ),
                  const SizedBox(height: 16), // Spazio aggiustato

                  // Messaggio di Errore
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),

                   // Indicatore di Caricamento centrale (visibile solo se _isLoading è true)
                   if (_isLoading)
                     const Padding(
                       padding: EdgeInsets.symmetric(vertical: 16.0),
                       child: Center(child: CircularProgressIndicator()),
                     ),
                   // Nascondi i bottoni se sta caricando
                   if (!_isLoading) ...[
                     // Bottone Accedi
                     ElevatedButton(
                       onPressed: _login, // _isLoading già gestito all'interno
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color.fromARGB(255, 0, 51, 102),
                         foregroundColor: Colors.white,
                         padding: const EdgeInsets.symmetric(vertical: 16),
                         textStyle: const TextStyle(fontSize: 18),
                       ),
                       child: const Text('Accedi'),
                     ),
                     const SizedBox(height: 12),

                     // Bottone Registrati
                     ElevatedButton(
                       onPressed: _navigateToSignUp, // _isLoading già gestito all'interno
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color.fromARGB(255, 235, 173, 61),
                         foregroundColor: Colors.white,
                         padding: const EdgeInsets.symmetric(vertical: 16),
                         textStyle: const TextStyle(fontSize: 18),
                       ),
                       child: const Text('Registrati'),
                     ),
                     const SizedBox(height: 24),

                     // Divisore "O"
                     Row(
                       children: const [
                         Expanded(child: Divider()),
                         Padding(
                           padding: EdgeInsets.symmetric(horizontal: 8.0),
                           child: Text('O'),
                         ),
                         Expanded(child: Divider()),
                       ],
                     ),
                     const SizedBox(height: 24),

                     // Bottone Accedi con Google
                     OutlinedButton.icon(
                       onPressed: _loginWithGoogle, // _isLoading già gestito all'interno
                       icon: Image.asset(
                         'assets/images/google_logo.png', // Assicurati che il path sia corretto
                         height: 24.0,
                       ),
                       label: const Text(
                         'Accedi con Google',
                         style: TextStyle(fontSize: 18, color: Colors.black87),
                       ),
                       style: OutlinedButton.styleFrom(
                         padding: const EdgeInsets.symmetric(vertical: 16),
                         side: const BorderSide(color: Colors.grey),
                       ),
                     ),
                   ], // Fine della sezione visibile solo se !_isLoading
                   const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}