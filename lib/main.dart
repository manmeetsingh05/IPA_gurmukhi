import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // Aggiunto import
import 'package:impara_gurbani/Metodi.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart'; // Aggiunto import per AudioPlayer

import 'firebase_options.dart';
import 'Tema.dart';
import 'Drawer%20Menu/LoginPage.dart'; // Usa %20 o rinomina la cartella senza spazi
import 'Drawer%20Menu/SettingPage.dart';
import 'Drawer%20Menu/MyAccount.dart';
import 'Lettura/lettura_page.dart';
import 'Scrittura/scrittura_page.dart';
import 'Giochi/giochi_page.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

// Importa i file dei servizi e delle pagine di gioco (assicurati che i percorsi siano corretti)
import 'Giochi/funzioni.dart';
// Potresti non aver bisogno di importare le pagine di gioco qui se la navigazione parte da GiochiPage
// import 'Giochi/indovina_parola_page.dart';
// import 'Giochi/indovina_sillaba_page.dart';

Future<void> initializeFirebase() async {
  if (defaultTargetPlatform == TargetPlatform.android) {
    // Configurazione per Android
    await Firebase.initializeApp();
  } else {
    // Configurazione per tutte le altre piattaforme (iOS, Web, macOS, Windows, Linux)
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();

  runApp(
    // *** INIZIO MODIFICA: Usa MultiProvider come radice ***
    MultiProvider(
      providers: [
        // 1. Provider per il tema (il tuo esistente)
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider()..init(),
        ),

        // 2. Provider per le istanze base (Firebase, AudioPlayer)
        Provider<FirebaseAuth>.value(value: FirebaseAuth.instance),
        Provider<FirebaseDatabase>.value(value: FirebaseDatabase.instance),
        Provider<AudioPlayer>(
          create: (_) => AudioPlayer(),
          dispose: (_, player) => player.dispose(), // Gestisce il dispose
        ),

        // 3. Provider per i servizi che dipendono dalle istanze base
        //    (Usa ProxyProvider per iniettare le dipendenze)
        ProxyProvider<AudioPlayer, AudioService>(
          update: (_, audioPlayer, previousAudioService) =>
              AudioService(audioPlayer),
          // Non serve dispose qui, l'AudioPlayer è gestito sopra
        ),
        ProxyProvider2<FirebaseAuth, FirebaseDatabase, ScoreService>(
          update: (_, auth, database, previousScoreService) =>
              ScoreService(auth, database),
        ),
      ],
      // Il child del MultiProvider è MyApp, che costruirà MaterialApp
      // In questo modo, MaterialApp e tutte le sue pagine avranno accesso ai provider
      child: const MyApp(),
    ),
    // *** FINE MODIFICA ***
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ora possiamo accedere a ThemeProvider perché è fornito da MultiProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Impara Gurmukhi',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      // La logica per decidere la home page rimane invariata
      home: FirebaseAuth.instance.currentUser == null
          ? const LoginPage()
          : const MyHomePage(title: 'Impara Gurmukhi'),
      // Se usi named routes, assicurati che siano definite qui
      // routes: {
      //   '/giochi': (context) => GiochiPage(),
      //   '/lettura': (context) => LetturaPage(),
      //   ... altre routes
      // }
    );
  }
}

// Il resto del codice (MyHomePage, _MyHomePageState, ecc.) rimane invariato
// perché la logica di costruzione dell'UI e della navigazione è corretta.
// Quando navighi verso GiochiPage (e da lì ai giochi specifici),
// queste pagine saranno costruite all'interno del contesto di MaterialApp
// e quindi avranno accesso ai provider definiti nel MultiProvider.

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  final List<String> buttonTitles = [
    'Lettura',
    'Scrittura',
    'Giochi',
    'Aiuto',
  ];

  final List<IconData> buttonIcons = [
    Icons.book,
    Icons.note_alt,
    Icons.videogame_asset,
    Icons.help,
  ];

  Future<void> _launchHelpWebsite() async {
    final Uri url = Uri.parse('https://www.dalpanthitaly.com/');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        print('Impossibile aprire $url');
        // Considera di mostrare un messaggio all'utente qui
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossibile aprire il sito web.')),
        );
      }
    } catch (e) {
      print('Errore durante l\'apertura di $url: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nell\'apertura del sito web.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final effectiveThemeMode = themeProvider.getEffectiveThemeMode();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBarTitle('Impara Gurmukhi'),
      drawer: Drawer(
        surfaceTintColor: theme.colorScheme.surfaceTint,
        // *** INIZIO MODIFICA: Usa Column invece di ListView ***
        child: Column(
          children: [
            // Parte Superiore (Header e Riga) - Non cambia
            SizedBox(
              height: 300,
              width: 310,
              child: DrawerHeader(
                padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Impara Gurmukhi',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Image.asset(
                      'assets/images/dalpanth.png',
                      height: 180,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 10.0,
              width: double.infinity,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: 15),
            // Voci di Menu - Non cambiano
            ListTile(
              leading:
                  Icon(Icons.person, color: theme.colorScheme.onSurfaceVariant),
              title: Text(
                'Profilo',
                style: theme.textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.pop(context); // Chiudi drawer
                if (isLoggedIn) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AccountManagementPage()));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()));
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.settings,
                  color: theme.colorScheme.onSurfaceVariant),
              title: Text(
                'Impostazioni',
                style: theme.textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.pop(context); // Chiudi drawer
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()));
              },
            ),

            // *** MODIFICA: Usa Spacer per spingere il testo della versione in fondo ***
            const Spacer(), // Occupa tutto lo spazio verticale rimanente

            // Testo della Versione (ora in fondo)
            Padding(
              padding: const EdgeInsets.all(16.0), // Padding attorno al testo
              child: Text(
                'Versione 1.0.0',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline),
                textAlign: TextAlign.center,
              ),
            ),
            // const SizedBox(height: 10), // Puoi rimuovere o tenere questo spazio sotto la versione
            // Aggiungi un piccolo SafeArea per evitare che il testo vada sotto la barra di sistema inferiore, se presente
            SafeArea(
              top: false, // Solo il fondo
              child: const SizedBox(
                  height: 5), // Piccolo spazio aggiuntivo se necessario
            )
          ],
        ),
        // *** FINE MODIFICA ***
      ),
      body: Container(
        // ... (Codice del body invariato) ...
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              effectiveThemeMode == ThemeMode.dark
                  ? "assets/images/SfondoDark.png"
                  : "assets/images/SfondoLight.png",
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.1,
            vertical: screenHeight * 0.05,
          ),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.1,
            ),
            itemCount: buttonTitles.length,
            itemBuilder: (context, index) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      theme.colorScheme.surfaceVariant.withOpacity(0.85),
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.buttonRadius),
                      side: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.3))),
                  elevation: 3,
                ),
                onPressed: () {
                  Widget? nextPage;
                  switch (index) {
                    case 0:
                      nextPage = const LetturaPage();
                      break;
                    case 1:
                      nextPage = const ScritturaPage();
                      break;
                    case 2:
                      nextPage = GiochiPage();
                      break;
                    case 3:
                      _launchHelpWebsite();
                      break;
                  }

                  if (nextPage != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => nextPage!),
                    );
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      buttonIcons[index],
                      size: screenWidth * 0.1,
                      color: theme.brightness == Brightness.dark
                          ? theme.colorScheme.secondary // Colore per tema scuro
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      buttonTitles[index],
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
