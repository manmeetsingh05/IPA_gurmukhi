import 'package:flutter/material.dart';
import 'package:impara_gurbani/Lettura/5-parole/PaginaParole.dart';
import 'package:impara_gurbani/Metodi.dart';
import 'package:impara_gurbani/LISTE.dart';

final List<String> NomiVocali = [
  "Mukta",
  "Kanna",
  "Sihari",
  "Bihari",
  "Onkarh",
  "Dulenkarh",
  "Lavaa",
  "Dulaava",
  "Horha",
  "Knaurha",
];

class WordsPage extends StatelessWidget {
  const WordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarTitle("Parole"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            BuildMenu(
              context,
              NomiVocali[0],
              "◌",
              DynamicWordsPage(
                vowel: NomiVocali[0],
                words: MuktaWords,
                pronunciations: MuktaPronunciations,
                audioPath: 'SUONI/${NomiVocali[0]}',
              ),
            ),
            const SizedBox(height: 2),
            BuildMenu(
              context,
              NomiVocali[1],
              "ਾ",
              DynamicWordsPage(
                vowel: NomiVocali[1],
                words: KannaWords,
                pronunciations: KannaPronunciations,
                audioPath: 'SUONI/${NomiVocali[1]}',
              ),
            ),
            const SizedBox(height: 2),
            BuildMenu(
              context,
              NomiVocali[2],
              "ਿ",
              DynamicWordsPage(
                vowel: NomiVocali[2],
                words: SihariWords,
                pronunciations: SihariPronunciations,
                audioPath: 'SUONI/${NomiVocali[2]}',
              ),
            ),
            const SizedBox(height: 2),
            BuildMenu(
              context,
              NomiVocali[3],
              "ੀ",
              DynamicWordsPage(
                vowel: NomiVocali[3],
                words: BihariWords,
                pronunciations: BihariPronunciations,
                audioPath: 'SUONI/${NomiVocali[3]}',
              ),
            ),
            const SizedBox(height: 2),
            BuildMenu(
              context,
              NomiVocali[4],
              "ੁ",
              DynamicWordsPage(
                vowel: NomiVocali[4],
                words: OnkarhWords,
                pronunciations: OnkarhPronunciations,
                audioPath: 'SUONI/${NomiVocali[4]}',
              ),
            ),
            const SizedBox(height: 2),
            BuildMenu(
              context,
              NomiVocali[5],
              "ੂ",
              DynamicWordsPage(
                vowel: NomiVocali[5],
                words: DulenkarhWords,
                pronunciations: DulenkarhPronunciations,
                audioPath: 'SUONI/${NomiVocali[5]}',
              ),
            ),
            const SizedBox(height: 2),
            BuildMenu(
              context,
              NomiVocali[6],
              "ੇ",
              DynamicWordsPage(
                vowel: NomiVocali[6],
                words: LavaaWords,
                pronunciations: LavaaPronunciations,
                audioPath: 'SUONI/${NomiVocali[6]}',
              ),
            ),
            const SizedBox(height: 2),
            BuildMenu(
              context,
              NomiVocali[7],
              "ੈ",
              DynamicWordsPage(
                vowel: NomiVocali[7],
                words: DulaavaWords,
                pronunciations: DulaavaPronunciations,
                audioPath: 'SUONI/${NomiVocali[7]}',
              ),
            ),
            const SizedBox(height: 2),
            BuildMenu(
              context,
              NomiVocali[8],
              "ੋ",
              DynamicWordsPage(
                vowel: NomiVocali[8],
                words: HorhaWords,
                pronunciations: HorhaPronunciations,
                audioPath: 'SUONI/${NomiVocali[8]}',
              ),
            ),
            const SizedBox(height: 2),
            BuildMenu(
              context,
              NomiVocali[9],
              "ੌ",
              DynamicWordsPage(
                vowel: NomiVocali[9],
                words: KnaurhaWords,
                pronunciations: KnaurhaPronunciations,
                audioPath: 'SUONI/${NomiVocali[9]}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

        