import 'package:flutter/material.dart';
import 'package:impara_gurbani/Lettura/3-muharni.dart';
import 'package:impara_gurbani/Lettura/2-vocali.dart';

import 'package:impara_gurbani/Lettura/1-alphabeth.dart';
import 'package:impara_gurbani/Lettura/4-simboli/4-simboli.dart';
import 'package:impara_gurbani/Lettura/5-parole/5-parole.dart';
import 'package:impara_gurbani/Metodi.dart';


class LetturaPage extends StatefulWidget {
  const LetturaPage({super.key});

  @override
  State<LetturaPage> createState() => _LetturaPageState();
}

class _LetturaPageState extends State<LetturaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarTitle("Lettura"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            BuildMenu(context, "Alfabeto", Icons.abc, PunjabiAlphabetPage()),
            const SizedBox(height: 12),
            BuildMenu(context, "Vocali", Icons.font_download, PunjabiVowelsPage()),
            const SizedBox(height: 12),
            BuildMenu(context, "Sillabe", Icons.text_fields, MuharniPage()),
            const SizedBox(height: 12),
            BuildMenu(context, "Altri simboli", Icons.list, SymbolsPage()),
            const SizedBox(height: 12),
            BuildMenu(context, "Parole", Icons.spellcheck, WordsPage()),
          ],
        ),
      ),
    );
  }
}