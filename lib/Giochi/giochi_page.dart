import 'package:flutter/material.dart';
import 'package:impara_gurbani/Giochi/indovina_sillaba.dart';
import 'package:impara_gurbani/Giochi/pronounciation_game.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgImage = isDark
        ? 'assets/images/sfondo_giochidark.png'
        : 'assets/images/sfondo_giochi.png';

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
              BuildMenu(context, "Indovina la sillaba", Icons.font_download,
                  IndovinaSillabaPage()),
              const SizedBox(height: 12),
              BuildMenu(context, "Riconosci la sillaba",
                  Icons.spatial_audio_off_rounded, Sillable2()),
              const SizedBox(height: 12),
              BuildMenu(context, "Indovina la parola", Icons.abc,
                  IndovinaParolaPage()),
              const SizedBox(height: 12),
              BuildMenu(context, "Pronuncia la parola",
                  Icons.spatial_audio_off_rounded, PronunciaParola()),
            ],
          ),
        ),
      ),
    );
  }
}
