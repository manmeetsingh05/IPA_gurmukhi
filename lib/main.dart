import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'Tema.dart'; // Importa la gestione del tema
import 'Drawer Menu/LoginPage.dart';
import 'Drawer Menu/SettingPage.dart';
import 'Drawer Menu/MyAccount.dart';
import 'Lettura/lettura_page.dart';
import 'Scrittura/scrittura_page.dart';
import 'Giochi/giochi_page.dart';
import 'Metodi.dart';
import 'package:flutter/foundation.dart';

Future<void> initializeFirebase() async {
  if (kIsWeb) {
    // Configurazione per web
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    // Configurazione per mobile (Android/iOS)
    await Firebase.initializeApp();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'Impara Gurmukhi',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: FirebaseAuth.instance.currentUser == null ? const LoginPage() : const MyHomePage(title: 'Impara Gurmukhi'),
    );
  }
}



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Controlla lo stato di autenticazione dell'utente
  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  // Lista dei titoli dei pulsanti
  final List<String> buttonTitles = [
    'Lettura',
    'Scrittura',
    'Giochi',
    'Aiuto',
    'Profilo',
    'Esci'
  ];

  // Lista delle icone corrispondenti ai pulsanti
  final List<IconData> buttonIcons = [
    Icons.book,
    Icons.note_alt,
    Icons.videogame_asset,
    Icons.help,
    Icons.account_circle,
    Icons.exit_to_app
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBarTitle('Impara Gurmukhi'),
      drawer: Drawer(
        shadowColor: AppTheme.secondaryColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              color: AppTheme.secondaryColor,
              height: 340,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Impara Gurmukhi',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Image.asset(
                      'assets/images/dalpanth.png',
                      height: 200,
                      width: 200,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.person, color: theme.colorScheme.onSurface),
              title: Text(
                'Profilo',
                style: theme.textTheme.bodyMedium,
              ),
              onTap: () {
                if (isLoggedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountManagementPage(),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: theme.colorScheme.onSurface),
              title: Text(
                'Impostazioni',
                style: theme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
              },
            ),
            SizedBox(height: screenHeight * 0.45),
            Padding(
              padding: const EdgeInsets.all(AppTheme.defaultPadding),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Versione 1.0.0',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.1,
          vertical: screenHeight * 0.05,
        ),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: buttonTitles.length,
          itemBuilder: (context, index) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.background,
                foregroundColor: theme.colorScheme.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                ),
                elevation: 5,
              ),
              onPressed: () {
                if (index == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LetturaPage(),
                    ),
                  );
                } else if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScritturaPage(),
                    ),
                  );
                } else if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GiochiPage(),
                    ),
                  );
                } else if (index == 4) {
                  if (isLoggedIn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountManagementPage(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  }
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    buttonIcons[index],
                    size: screenWidth * 0.08,
                    color: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    buttonTitles[index],
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}