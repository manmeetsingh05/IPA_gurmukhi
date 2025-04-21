import 'package:flutter/material.dart';
import 'package:impara_gurbani/Metodi.dart';
import 'package:impara_gurbani/Scrittura/scrivi_alfabeto.dart';
import 'package:impara_gurbani/LISTE.dart'; // contiene punjabiAlphabet

class ScritturaPage extends StatefulWidget {
  const ScritturaPage({super.key});

  @override
  State<ScritturaPage> createState() => _ScritturaPageState();
}

class _ScritturaPageState extends State<ScritturaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarTitle("Scrittura"),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          itemCount: punjabiAlphabet.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 5,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final letter = punjabiAlphabet[index];
            return AnimatedGridButton(
              letter: letter,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PunjabiTracingPage(
                      initialIndex: index,
                  ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
