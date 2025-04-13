import 'package:flutter/material.dart';
import 'package:impara_gurbani/Metodi.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:impara_gurbani/Tema.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Funzione per effettuare il logout
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacementNamed('/login'); // Torna alla pagina di login
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBarTitle('Impostazioni'),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Toggle per il tema
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Modalità Scura'),
            trailing: Switch(
              value: themeProvider.themeMode == ThemeMode.dark ||
                  (themeProvider.themeMode == ThemeMode.system &&
                      MediaQuery.of(context).platformBrightness ==
                          Brightness.dark),
              onChanged: (value) {
                themeProvider.setThemeMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },
            ),
          ),
          const Divider(),

          // Account
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Modifica Profilo'),
            onTap: () {
              // Aggiungi la navigazione alla pagina di modifica del profilo
              Navigator.of(context).pushNamed('/profile');
            },
          ),
          const Divider(),

          // Informazioni sull'app
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Informazioni sull\'App'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Impara Gurmukhi',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.book),
                children: [
                  const Text(
                      'Un\'app per imparare l\'alfabeto Gurmukhi in modo interattivo.'),
                ],
              );
            },
          ),
          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
