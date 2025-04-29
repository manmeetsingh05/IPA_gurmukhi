import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../main.dart';
import 'SignUpPage.dart';
import 'RecuperoPassword.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(googleUser.email);

      if (signInMethods.isNotEmpty && !signInMethods.contains(GoogleAuthProvider.PROVIDER_ID)) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Account già registrato con email/password. Accedi con quel metodo.';
        });
        await _googleSignIn.signOut();
        return;
      }

      await _auth.signInWithCredential(credential);
      _navigateToHome();

    } on FirebaseAuthException catch (e) {
      await _handleGoogleLoginError(e);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Errore durante l\'accesso con Google. Verifica la configurazione.';
      });
      await _googleSignIn.signOut();
    } finally {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

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
      final List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(email);

      if (signInMethods.contains(GoogleAuthProvider.PROVIDER_ID)) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Questa email è collegata a un account Google. Per favore, usa il pulsante "Accedi con Google".';
        });
        return;
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _navigateToHome();

    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _mapLoginError(e);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Si è verificato un errore imprevisto.';
      });
    } finally {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleLoginError(FirebaseAuthException e) async {
    String errorMessage;
    switch (e.code) {
      case 'account-exists-with-different-credential':
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

  String _mapLoginError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Formato email non valido.';
      case 'user-disabled':
        return 'Questo account è stato disabilitato.';
      case 'user-not-found':
        return 'Nessun account trovato per questa combinazione email/password.';
      case 'wrong-password':
        return 'Password errata.';
      case 'invalid-credential':
        return 'Credenziali non valide (email o password errate).';
      default:
        return 'Errore durante l\'accesso: ${e.message ?? e.code}';
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Impara Gurmukhi')),
    );
  }

  void _navigateToSignUp() {
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
  }

  void _navigateToPasswordReset() {
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (context) => const PasswordResetPage()));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color googleTextColor = isDarkMode ? Colors.white : Colors.black;
    final Color googleBorderColor = isDarkMode ? Colors.white : Colors.black;
    final Color forgotPasswordColor = isDarkMode
        ? Theme.of(context).colorScheme.secondary
        : Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/images/dalpanth.png', height: 200),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : _navigateToPasswordReset,
                    child: Text(
                      'Password dimenticata?',
                      style: TextStyle(color: forgotPasswordColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Accedi'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _navigateToSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEBAD3D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Registrati'),
                  ),
                  const SizedBox(height: 24),
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
                  OutlinedButton.icon(
                    onPressed: _loginWithGoogle,
                    icon: Image.asset(
                      'assets/images/google_logo.png',
                      height: 24.0,
                    ),
                    label: Text(
                      'Accedi con Google',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: googleTextColor,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: googleBorderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
