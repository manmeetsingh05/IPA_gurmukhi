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
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bgImage = isDark
      ? "assets/images/sfondo_letturadark.png"
      : "assets/images/sfondo_lettura.png";

  return Scaffold(
    appBar: AppBarTitle("Lettura"),
    body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(bgImage),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.7),
            BlendMode.dstATop,
          ),
        ),
      ),
      child: SingleChildScrollView(
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
    ),
  );
}
}
