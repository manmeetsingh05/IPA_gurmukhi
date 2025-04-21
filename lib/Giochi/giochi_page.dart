import 'package:flutter/material.dart';
import 'package:impara_gurbani/Giochi/indovina_sillaba.dart';
import 'package:impara_gurbani/Giochi/pronuncia_parola.dart';
import 'package:impara_gurbani/Giochi/syllable_game.dart';
import 'package:impara_gurbani/Giochi/words_game.dart';
import 'package:impara_gurbani/Metodi.dart';

class GiochiPage extends StatefulWidget {
  const GiochiPage({super.key});

  @override
  State<GiochiPage> createState() => _GiochiPageState();
}

class _GiochiPageState extends State<GiochiPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarTitle("Lettura"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            BuildMenu(context, "Indovina la sillaba", Icons.font_download, IndovinaSillabaPage()),
            const SizedBox(height: 12),
            BuildMenu(context, "Riconosci la sillaba", Icons.spatial_audio_off_rounded, Sillable2()),
            const SizedBox(height: 12),
            BuildMenu(context, "Indovina la parola", Icons.abc, IndovinaParolaPage()),
            const SizedBox(height: 12),
            BuildMenu(context, "Pronuncia la parola", Icons.spatial_audio_off_rounded, PronunciaParola()),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}