import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:impara_gurbani/LISTE.dart'; // Assicurati ci sia punjabiAlphabet
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:impara_gurbani/Tema.dart';
import 'package:impara_gurbani/Metodi.dart'; // Assicurati ci sia AppBarTitle
import 'package:gif_view/gif_view.dart'; // Assicurati di importare

class PunjabiTracingPage extends StatefulWidget {
  final int initialIndex;
  const PunjabiTracingPage({super.key, required this.initialIndex});
  @override
  _PunjabiTracingPageState createState() => _PunjabiTracingPageState();
}

class _PunjabiTracingPageState extends State<PunjabiTracingPage> {
  late int _currentIndex;
  final List<List<Offset>> _strokes = [];
  ui.Image? _letterImage;
  Uint8List? _letterMask;
  int _maskWidth = 0;
  int _maskHeight = 0;
  Rect? _letterBounds;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isCompleted = false;

  List<Rect> _currentCheckpoints = [];
  List<Rect> _scaledCheckpoints = [];
  int _nextCheckpointIndex = 0;
  bool _isOutOfBounds = false;

  // --- Variabile aggiuntiva per prevenire multi-hit ---
  int _lastProcessedCheckpointIndex = -1;

  final Paint _tracePaint = Paint()
    ..color = AppTheme.secondaryColor
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 30.0
    ..style = PaintingStyle.stroke;

  final Paint _checkpointPaint = Paint()
    ..color = Colors.blue.withOpacity(0)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;
  final Paint _nextCheckpointPaint = Paint()
    ..color = Colors.orange.withOpacity(0)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0;
  final Paint _hitCheckpointPaint = Paint()
    ..color = Colors.green.withOpacity(0)
    ..style = PaintingStyle.fill;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadLetterData();
  }

  String get _currentLetter {
    if (_currentIndex >= 0 && _currentIndex < punjabiAlphabet.length) {
      return punjabiAlphabet[_currentIndex];
    }
    return "";
  }

  Future<void> _loadLetterData() async {
    if (_currentLetter.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Indice lettera non valido.";
      });
      return;
    }
    final String assetPath = 'assets/png/$_currentLetter.png';
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _letterImage = null;
      _letterMask = null;
      _letterBounds = null;
      _resetTracingState(fullReset: true);
    });

    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List list = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(list);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      _letterImage = frameInfo.image;
      _maskWidth = _letterImage!.width;
      _maskHeight = _letterImage!.height;

      if (_maskWidth <= 0 || _maskHeight <= 0)
        throw Exception("Dimensioni immagine non valide.");

      final ByteData? pixels =
          await _letterImage!.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (pixels != null) {
        final Uint8List rgbaBytes = pixels.buffer.asUint8List();
        _letterMask = Uint8List(_maskWidth * _maskHeight);
        for (int i = 0; i < _letterMask!.length; i++) {
          _letterMask![i] = rgbaBytes[i * 4 + 3] > 20 ? 1 : 0;
        }
      } else {
        throw Exception("Impossibile leggere i pixel.");
      }

      _currentCheckpoints = letterCheckpoints[_currentLetter] ?? [];
      if (!letterCheckpoints.containsKey(_currentLetter)) {
        _errorMessage =
            "Definizione checkpoint mancante per '$_currentLetter'.";
        print(_errorMessage);
      } else if (_currentCheckpoints.isEmpty) {
        print("Attenzione: Nessun checkpoint definito per '$_currentLetter'.");
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e, stacktrace) {
      print("Errore caricamento '$_currentLetter': $e\n$stacktrace");
      setState(() {
        _isLoading = false;
        _errorMessage = "Errore caricamento: ${e.toString()}";
      });
    }
  }

  void _resetTracingState({bool fullReset = false}) {
    if (_strokes.isNotEmpty) _strokes.clear();
    _nextCheckpointIndex = 0;
    _isOutOfBounds = false;
    _lastProcessedCheckpointIndex = -1; // Resetta anche questo
    if (_scaledCheckpoints.isNotEmpty) _scaledCheckpoints = [];
    if (fullReset) _isCompleted = false;
  }

  void _scaleCheckpoints() {
    if (!mounted ||
        _letterBounds == null ||
        _letterImage == null ||
        _currentCheckpoints.isEmpty) {
      if (_scaledCheckpoints.isNotEmpty)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _scaledCheckpoints = []);
        });
      return;
    }
    final double actualImageWidth = _letterImage!.width.toDouble();
    final double actualImageHeight = _letterImage!.height.toDouble();
    if (actualImageWidth <= 0 || actualImageHeight <= 0) return;

    final double scaleX = _letterBounds!.width / actualImageWidth;
    final double scaleY = _letterBounds!.height / actualImageHeight;

    final List<Rect> newScaledCheckpoints = _currentCheckpoints
        .map((r) => Rect.fromLTWH(
            _letterBounds!.left + (r.left * scaleX),
            _letterBounds!.top + (r.top * scaleY),
            r.width * scaleX,
            r.height * scaleY))
        .toList();

    if (!listEquals(_scaledCheckpoints, newScaledCheckpoints)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _scaledCheckpoints = newScaledCheckpoints);
      });
    }
  }

  bool _isInsideLetterBounds(Offset point, {int tolerance = 15}) {
    if (_letterBounds == null || _letterMask == null || _maskWidth == 0)
      return false;
    final double scaleX = _maskWidth / _letterBounds!.width;
    final double scaleY = _maskHeight / _letterBounds!.height;
    final double localX = (point.dx - _letterBounds!.left) * scaleX;
    final double localY = (point.dy - _letterBounds!.top) * scaleY;
    final int checkX = localX.round();
    final int checkY = localY.round();
    if (checkX >= 0 &&
        checkX < _maskWidth &&
        checkY >= 0 &&
        checkY < _maskHeight) {
      if (_letterMask![checkY * _maskWidth + checkX] == 1) return true;
    }
    for (int dx = -tolerance; dx <= tolerance; dx++) {
      for (int dy = -tolerance; dy <= tolerance; dy++) {
        if (dx == 0 && dy == 0) continue;
        final int tCheckX = (localX + dx).round();
        final int tCheckY = (localY + dy).round();
        if (tCheckX >= 0 &&
            tCheckX < _maskWidth &&
            tCheckY >= 0 &&
            tCheckY < _maskHeight) {
          if (_letterMask![tCheckY * _maskWidth + tCheckX] == 1) return true;
        }
      }
    }
    return false;
  }

  void _onPanStart(DragStartDetails details) {
    if (_isCompleted ||
        _isLoading ||
        _letterImage == null ||
        _letterBounds == null) return;

    final Offset localPosition = details.localPosition;
    if (!_letterBounds!.contains(localPosition)) return;
    if (!_isInsideLetterBounds(localPosition)) {
      _showErrorDialog('Tocca DENTRO la lettera per iniziare!');
      return;
    }

    setState(() {
      if (_isOutOfBounds) _isOutOfBounds = false;
      _strokes.add([]);
      _strokes.last.add(localPosition);
      // Non resettare _nextCheckpointIndex qui
      // Resetta _lastProcessedCheckpointIndex se stiamo iniziando un nuovo tentativo dopo un errore
      // o se è la prima volta che tocchiamo dopo il caricamento/reset
      if (_strokes.length == 1 && _nextCheckpointIndex == 0) {
        _lastProcessedCheckpointIndex = -1;
      }

      _checkCheckpointHit(localPosition);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isCompleted || _isLoading || _isOutOfBounds || _strokes.isEmpty)
      return;

    final Offset localPosition = details.localPosition;

    if (!_isInsideLetterBounds(localPosition)) {
      _isOutOfBounds = true;
      _handleTracingError('Sei uscito dai bordi della lettera!');
      return;
    }

    setState(() {
      _strokes.last.add(localPosition);
    });
    _checkCheckpointHit(localPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    // Non fa nulla di specifico al rilascio del dito
  }

  // --- Logica Checkpoint e Completamento MODIFICATA ---
  void _checkCheckpointHit(Offset position) {
    // Procedi solo se ci sono checkpoint validi e non abbiamo finito
    if (_scaledCheckpoints.isNotEmpty &&
        _nextCheckpointIndex < _scaledCheckpoints.length) {
      final Rect nextCp = _scaledCheckpoints[_nextCheckpointIndex];

      // Controlla se la posizione CORRENTE è dentro il PROSSIMO checkpoint atteso
      if (nextCp.contains(position)) {
        // *** Controllo Anti-Multi-Hit ***
        // Verifica se questo specifico checkpoint (_nextCheckpointIndex)
        // non è già stato appena processato nell'ultimo update.
        if (_lastProcessedCheckpointIndex != _nextCheckpointIndex) {
          // Segna questo indice come "appena processato"
          final int justHitIndex = _nextCheckpointIndex;
          _lastProcessedCheckpointIndex = justHitIndex;
          // print("Checkpoint $justHitIndex HIT!"); // Debug

          // Incrementa l'indice del *prossimo* checkpoint da cercare
          // Lo facciamo DENTRO setState per assicurare consistenza
          setState(() {
            _nextCheckpointIndex++;
          });

          // Controlla il completamento DOPO che lo stato è stato aggiornato
          if (_nextCheckpointIndex == _scaledCheckpoints.length) {
            // Usa un postFrameCallback per assicurarti che lo stato sia
            // completamente aggiornato prima di dichiarare vittoria
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted &&
                  !_isCompleted &&
                  _nextCheckpointIndex == _scaledCheckpoints.length) {
                _completeTrace();
              }
            });
          }
        } else {
          // Questo checkpoint era già stato processato nell'ultimo check, ignora hit ripetute.
          // print("Checkpoint $justHitIndex already processed, ignoring repeat hit."); // Debug
        }
      }
    }
  }

  void _completeTrace() {
    if (!mounted) return;
    if (!_isCompleted) {
      // print("Trace completed successfully!"); // Debug
      setState(() => _isCompleted = true);
      _showSuccessDialog();
    }
  }

  void _handleTracingError(String message) {
    if (!mounted || _isLoading || _errorMessage != null) return;
    _showErrorDialog(message);
    setState(() {
      // Resetta stato tentativo: cancella tratti, resetta indice checkpoint
      _resetTracingState(fullReset: false);
    });
  }

  // --- Dialoghi (Invariati) ---
  void _showErrorDialog(String message) {
    /* ... codice invariato ... */
    if (!mounted || !ModalRoute.of(context)!.isCurrent) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.cardRadius)),
        contentPadding: const EdgeInsets.all(AppTheme.defaultPadding),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.asset('assets/images/scrittura.png', height: 120),
          const SizedBox(height: 16),
          Text('Attenzione!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.orange.shade800, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.buttonRadius))),
            child: Text('Riprova',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Colors.white)),
          ),
        ]),
      ),
    );
  }

  void _showSuccessDialog() {
    /* ... codice invariato ... */
    if (!mounted || !ModalRoute.of(context)!.isCurrent) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.cardRadius)),
        contentPadding: const EdgeInsets.all(AppTheme.defaultPadding),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.asset('assets/images/giustoscrittura.png', height: 150),
          const SizedBox(height: 16),
          Text('Complimenti!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.accentColor, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text('Lettera completata correttamente!',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (!mounted) return;
              Navigator.of(context).pop();
              if (_currentIndex < punjabiAlphabet.length - 1) {
                _currentIndex++;
                _loadLetterData();
              } else {
                if (Navigator.canPop(context)) Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.buttonRadius))),
            child: Text(
                _currentIndex < punjabiAlphabet.length - 1
                    ? 'Prossima Lettera'
                    : 'Fine',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Colors.white)),
          ),
        ]),
      ),
    );
  }

  // --- Widget Build Methods ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarTitle(
          'Ricalca: ${_currentLetter.isNotEmpty ? _currentLetter : "..."}'),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _resetCurrentAttempt,
        backgroundColor: _isLoading ? Colors.grey : AppTheme.primaryColor,
        child:
            Icon(Icons.refresh, color: Theme.of(context).colorScheme.onPrimary),
        tooltip: 'Ricomincia questa lettera',
      ),
    );
  }

  void _resetCurrentAttempt() {
    if (!mounted || _isLoading) return;
    setState(() {
      _resetTracingState(fullReset: _isCompleted);
    });
  }

  Widget _buildBody() {
    if (_errorMessage != null) return _buildErrorView();
    if (_isLoading || _letterImage == null)
      return Center(
          child: CircularProgressIndicator(color: AppTheme.secondaryColor));

    return LayoutBuilder(
      builder: (context, constraints) {
        final Size canvasSize = constraints.biggest;
        final Size imageSize = Size(
            _letterImage!.width.toDouble(), _letterImage!.height.toDouble());
        final FittedSizes fittedSizes =
            applyBoxFit(BoxFit.contain, imageSize, canvasSize);
        final Rect newLetterBounds = Alignment.center
            .inscribe(fittedSizes.destination, Offset.zero & canvasSize);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          bool needsScaleUpdate = false;
          if (_letterBounds != newLetterBounds) {
            setState(() => _letterBounds = newLetterBounds);
            needsScaleUpdate = true;
          }
          if (needsScaleUpdate ||
              (_scaledCheckpoints.isEmpty && _currentCheckpoints.isNotEmpty)) {
            _scaleCheckpoints();
          }
        });

        if (_letterBounds == null)
          return Center(
              child: CircularProgressIndicator(color: AppTheme.secondaryColor));

        return Stack(
          children: [
            GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              behavior: HitTestBehavior.opaque,
              child: CustomPaint(
                size: Size.infinite,
                painter: TracingPainter(
                  strokes: _strokes, letterImage: _letterImage!,
                  letterBounds: _letterBounds!,
                  tracePaint: _tracePaint,
                  scaledCheckpoints: _scaledCheckpoints,
                  nextCheckpointIndex: _nextCheckpointIndex,
                  checkpointPaint: _checkpointPaint,
                  nextCheckpointPaint: _nextCheckpointPaint,
                  hitCheckpointPaint: _hitCheckpointPaint,
                  showCheckpoints:
                      true, // !!! IMPOSTA A 'false' PER LA RELEASE !!!
                ),
              ),
            ),
            Positioned(top: 10, left: 10, child: _buildLetterAnimation()),
            if (_isCompleted)
              Positioned.fill(
                  child: IgnorePointer(
                      child: Container(
                color: AppTheme.accentColor.withOpacity(0.1),
                child: Center(
                  child: Icon(Icons.check_circle,
                      color: AppTheme.accentColor.withOpacity(0.6),
                      size: 150,
                      shadows: [
                        Shadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(2, 2))
                      ]),
                ),
              ))),
          ],
        );
      },
    );
  }

  Widget _buildErrorView() {
    /* ... codice invariato ... */
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.defaultPadding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                color: Theme.of(context).colorScheme.error, size: 60),
            const SizedBox(height: 20),
            Text('Oops! Si è verificato un errore.',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(_errorMessage ?? "Errore sconosciuto.",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh, color: Colors.white),
              label: Text('Riprova Caricamento',
                  style: TextStyle(color: Colors.white)),
              onPressed: _loadLetterData,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
            ),
            const SizedBox(height: 10),
            TextButton(
              child: Text('Torna Indietro'),
              onPressed: () {
                if (Navigator.canPop(context)) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterAnimation() {
    String gifAssetPath =
        'assets/gif/${_currentLetter.isNotEmpty ? _currentLetter : 'placeholder'}.gif';
    // Assicurati di avere un 'placeholder.gif' o gestisci il caso _currentLetter vuoto

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(1, 1),
          )
        ],
      ),
      child: ClipRRect(
        // Usiamo ClipRRect per i bordi arrotondati
        borderRadius: BorderRadius.circular(4),
        child: GifView.asset(
          // Passa solo i parametri essenziali supportati dalla v1.0.2
          gifAssetPath,
          key: ValueKey(gifAssetPath), // Utile per aggiornamenti efficienti
          height: 60,
          width: 60,
          fit: BoxFit.contain,
          // controller: controller, // Controller potrebbe essere supportato, verifica se necessario

          // --- NESSUN frameBuilder ---
          // --- NESSUN errorBuilder ---
          // --- NESSUN progress ---
          // --- NESSUN onError ---
        ),
      ),
    );
  }

  bool listEquals<T>(List<T>? a, List<T>? b) {
    /* ... codice invariato ... */
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
} // Fine _PunjabiTracingPageState

// --- Custom Painter (Invariato rispetto alla versione precedente) ---
class TracingPainter extends CustomPainter {
  final List<List<Offset>> strokes; // Lista di liste
  final ui.Image letterImage;
  final Rect letterBounds;
  final Paint tracePaint;
  final List<Rect> scaledCheckpoints;
  final int nextCheckpointIndex;
  final Paint checkpointPaint;
  final Paint nextCheckpointPaint;
  final Paint hitCheckpointPaint;
  final bool showCheckpoints;

  TracingPainter({
    required this.strokes, // Riceve lista di liste
    required this.letterImage,
    required this.letterBounds,
    required this.tracePaint,
    required this.scaledCheckpoints,
    required this.nextCheckpointIndex,
    required this.checkpointPaint,
    required this.nextCheckpointPaint,
    required this.hitCheckpointPaint,
    this.showCheckpoints = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Disegna immagine
    canvas.drawImageRect(
        letterImage,
        Rect.fromLTWH(
            0, 0, letterImage.width.toDouble(), letterImage.height.toDouble()),
        letterBounds,
        Paint()..filterQuality = FilterQuality.medium);

    // 2. Disegna checkpoint
    if (showCheckpoints) {
      /* ... codice invariato ... */
      for (int i = 0; i < scaledCheckpoints.length; i++) {
        final rect = scaledCheckpoints[i];
        Paint paintToUse;
        if (i < nextCheckpointIndex)
          paintToUse = hitCheckpointPaint;
        else if (i == nextCheckpointIndex)
          paintToUse = nextCheckpointPaint;
        else
          paintToUse = checkpointPaint;
        canvas.drawRect(rect, paintToUse);
      }
    }

    // 3. Disegna tratti (logica invariata, itera sulla lista di liste)
    tracePaint.style = PaintingStyle.stroke;
    final circlePaint = Paint()
      ..color = tracePaint.color
      ..style = PaintingStyle.fill;
    for (final singleStroke in strokes) {
      if (singleStroke.isNotEmpty) {
        if (singleStroke.length > 1) {
          final path = Path()..moveTo(singleStroke[0].dx, singleStroke[0].dy);
          for (int i = 1; i < singleStroke.length; i++) {
            path.lineTo(singleStroke[i].dx, singleStroke[i].dy);
          }
          canvas.drawPath(path, tracePaint);
        } else {
          canvas.drawCircle(
              singleStroke[0], tracePaint.strokeWidth / 4, circlePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant TracingPainter oldDelegate) {
    /* ... codice invariato ... */
    return !identical(oldDelegate.strokes, strokes) ||
        oldDelegate.letterBounds != letterBounds ||
        oldDelegate.nextCheckpointIndex != nextCheckpointIndex ||
        oldDelegate.showCheckpoints != showCheckpoints ||
        !listEquals(oldDelegate.scaledCheckpoints, scaledCheckpoints);
  }

  bool listEquals<T>(List<T>? a, List<T>? b) {
    /* ... codice invariato ... */
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
} // Fine TracingPainter
