import 'package:flutter/material.dart';
import 'package:impara_gurbani/LISTE.dart';
import 'package:impara_gurbani/Metodi.dart';
import 'PaginaSimboli.dart'; // Importa la nuova pagina dinamica

class SymbolsPage extends StatelessWidget {
  const SymbolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarTitle("Parole"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(30, 160, 30, 30),
        child: Column(
          children: [
            BuildMenu(context, "Tippi", "ੰ", DynamicSymbolPage(
              title: "Parole con Tippi",
              words: TippiWords,
              pronunciations: TippiPronunciations,
              audioPathPrefix: 'SUONI/NASALE-PARTICOLARE(Tippi)',
            )),
            const SizedBox(height: 20),
            BuildMenu(context, "Bindi", "ਂ", DynamicSymbolPage(
              title: "Parole con Bindi",
              words: BindiWords,
              pronunciations: BindiPronunciations,
              audioPathPrefix: 'SUONI/NASALE_GENERALE(Bindi)',
            )),
            const SizedBox(height: 20),
            BuildMenu(context, "Adhak", "ੱ", DynamicSymbolPage(
              title: "Parole con Adhak",
              words: AdhakWords,
              pronunciations: AdhakPronunciations,
              audioPathPrefix: 'SUONI/ACCENTO-PESANTE(Addhak)',
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}