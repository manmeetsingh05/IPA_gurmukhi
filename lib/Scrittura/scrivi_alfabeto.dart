import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:impara_gurbani/LISTE.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:collection';
import 'package:impara_gurbani/Tema.dart';
import 'package:impara_gurbani/Metodi.dart';

class PunjabiTracingPage extends StatefulWidget {
  final int initialIndex;

  const PunjabiTracingPage({super.key, required this.initialIndex});

  @override
  _PunjabiTracingPageState createState() => _PunjabiTracingPageState();
}

class _PunjabiTracingPageState extends State<PunjabiTracingPage> {
  late int currentIndex;
  List<List<Offset>> strokes = [];
  ui.Image? letterImage;
  late Uint8List letterMask;
  late int maskWidth;
  late int maskHeight;
  Rect? letterBounds;
  Set<int> tracedPixels = HashSet();
  bool isCompleted = false;
  int totalPixels = 0;
  bool isLoading = true;
  String? errorMessage;
  final Paint _tracePaint = Paint()
    ..color = AppTheme.secondaryColor
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 20.0
    ..style = PaintingStyle.stroke;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    loadLetterImageAndMask();
  }

  Future<void> loadLetterImageAndMask() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Load PNG image
      final ByteData data = await rootBundle.load('assets/png/${punjabiAlphabet[currentIndex]}.png');
      final Uint8List list = Uint8List.view(data.buffer);

      final ui.Codec codec = await ui.instantiateImageCodec(list);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      final ByteData? pixels = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (pixels != null) {
        final Uint8List rgbaBytes = pixels.buffer.asUint8List();
        maskWidth = image.width;
        maskHeight = image.height;
        letterMask = Uint8List(maskWidth * maskHeight);

        for (int i = 0; i < maskWidth * maskHeight; i++) {
          final int alpha = rgbaBytes[i * 4 + 3];
          letterMask[i] = alpha > 0 ? 1 : 0;
        }

        setState(() {
          letterImage = image;
          isLoading = false;
          initializePixelCount();
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load letter image: ${e.toString()}';
      });
    }
  }

  void initializePixelCount() {
    tracedPixels.clear();
    totalPixels = letterMask.where((pixel) => pixel == 1).length;
    isCompleted = false;
  }

  void resetTracing() {
    setState(() {
      strokes.clear();
      initializePixelCount();
    });
    showErrorDialog();
  }

  bool isInsideLetter(Offset point, {int tolerance = 10}) {
    if (letterBounds == null) return false;

    final double scaleX = maskWidth / letterBounds!.width;
    final double scaleY = maskHeight / letterBounds!.height;

    final double localX = (point.dx - letterBounds!.left) * scaleX;
    final double localY = (point.dy - letterBounds!.top) * scaleY;

    if (localX < -tolerance || localX >= maskWidth + tolerance ||
        localY < -tolerance || localY >= maskHeight + tolerance) {
      return false;
    }

    bool found = false;
    for (int dx = -tolerance; dx <= tolerance; dx++) {
      for (int dy = -tolerance; dy <= tolerance; dy++) {
        final int checkX = localX.toInt() + dx;
        final int checkY = localY.toInt() + dy;

        if (checkX >= 0 && checkX < maskWidth && checkY >= 0 && checkY < maskHeight) {
          final int maskIndex = checkY * maskWidth + checkX;
          if (letterMask[maskIndex] == 1) {
            tracedPixels.add(maskIndex);
            found = true;
          }
        }
      }
    }
    
    // Check completion based on traced pixels
    if (!isCompleted && tracedPixels.length >= totalPixels * 0.4) {
      setState(() {
        isCompleted = true;
      });
      showSuccessDialog();
    }
    
    return found;
  }

  void showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cardRadius)),
        contentPadding: const EdgeInsets.all(AppTheme.defaultPadding),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/scrittura.png', height: 150),
            const SizedBox(height: 16),
            Text(
              'Errore',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Sei uscito dai bordi della lettera!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                ),
              ),
              child: Text(
                'OK',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showSuccessDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      contentPadding: const EdgeInsets.all(AppTheme.defaultPadding),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/giustoscrittura.png', // <-- Immagine PNG con sfondo trasparente
            height: 150,
          ),
          const SizedBox(height: 16),
          Text(
            'Complimenti!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.accentColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Hai completato la lettera correttamente!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (currentIndex < punjabiAlphabet.length - 1) {
                setState(() {
                  currentIndex++;
                  strokes.clear();
                });
                loadLetterImageAndMask();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
              ),
            ),
            child: Text(
              'Prossima Lettera',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarTitle('Ricalca la lettera'),
      body: errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: loadLetterImageAndMask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: Text(
                      'Riprova',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.secondaryColor,
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final Size canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                    final Size imageSize = Size(letterImage!.width.toDouble(), letterImage!.height.toDouble());
                    final FittedSizes fittedSizes = applyBoxFit(BoxFit.contain, imageSize, canvasSize);
                    letterBounds = Alignment.center.inscribe(fittedSizes.destination, Offset.zero & canvasSize);

                    return Stack(
                      children: [
                        GestureDetector(
                          onPanStart: (details) {
                            if (isCompleted) return;
                            final localPosition = (context.findRenderObject() as RenderBox)
                                .globalToLocal(details.globalPosition);
                            if (isInsideLetter(localPosition)) {
                              setState(() => strokes.add([localPosition]));
                            } else {
                              resetTracing();
                            }
                          },
                          onPanUpdate: (details) {
                            if (isCompleted) return;
                            final localPosition = (context.findRenderObject() as RenderBox)
                                .globalToLocal(details.globalPosition);
                            if (!isInsideLetter(localPosition)) {
                              resetTracing();
                            } else {
                              setState(() => strokes.last.add(localPosition));
                            }
                          },
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: TracingPainter(
                              strokes: strokes,
                              letterImage: letterImage!,
                              letterBounds: letterBounds!,
                              tracePaint: _tracePaint,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          left: 20,
                          child: _buildLetterAnimation(),
                        ),
                        if (isCompleted)
                          Positioned.fill(
                            child: Container(
                              color: AppTheme.accentColor.withOpacity(0.1),
                              child: Center(
                                child: Icon(
                                  Icons.check_circle_outline,
                                  color: AppTheme.accentColor,
                                  size: 150,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(2, 2),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            strokes.clear();
            initializePixelCount();
          });
        },
        backgroundColor: AppTheme.primaryColor,
        child: Icon(
          Icons.refresh,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        tooltip: 'Ricomincia',
      ),
    );
  }

  Widget _buildLetterAnimation() {
    try {
      return Image.asset(
        'assets/gif/${punjabiAlphabet[currentIndex]}.gif',
        height: 80,
        width: 80,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }
  }
}

class TracingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final ui.Image letterImage;
  final Rect letterBounds;
  final Paint tracePaint;

  TracingPainter({
    required this.strokes,
    required this.letterImage,
    required this.letterBounds,
    required this.tracePaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw letter image
    canvas.drawImageRect(
      letterImage,
      Rect.fromLTWH(0, 0, letterImage.width.toDouble(), letterImage.height.toDouble()),
      letterBounds,
      Paint(),
    );

    // Draw strokes
    for (final stroke in strokes) {
      if (stroke.length > 1) {
        final path = Path()..moveTo(stroke[0].dx, stroke[0].dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, tracePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}