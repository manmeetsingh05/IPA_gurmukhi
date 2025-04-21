import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:impara_gurbani/Tema.dart';




class PunjabiLetterTile extends StatefulWidget {
  final String letter;
  final String pronunciation;
  final VoidCallback onPlay;

  const PunjabiLetterTile({
    super.key,
    required this.letter,
    required this.pronunciation,
    required this.onPlay,
  });

  @override
  _PunjabiLetterTileState createState() => _PunjabiLetterTileState();
}

class _PunjabiLetterTileState extends State<PunjabiLetterTile> {
  bool _isPressed = false; // Tracks if the tile is pressed
  bool _isAnimated = false; // To track if the animation was played

  // Handle the start of a press
  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
      _isAnimated = true; // Start the animation when pressed
    });
  }

  // Handle the end of a press
  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    Future.delayed(const Duration(milliseconds: 80), () {
      setState(() {
        _isAnimated = false; // Reset the animation after it's done
      });
    });
    widget.onPlay(); // Play the audio when the press is released
  }

  // Handle the cancellation of a press
  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
      _isAnimated = false; // Reset the animation when the tap is canceled
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        padding: const EdgeInsets.all(AppTheme.defaultPadding / 2),
        decoration: BoxDecoration(
          color: _isPressed
              ? isDarkMode
                  ? theme.colorScheme.shadow.withOpacity(0.6)
                  : theme.colorScheme.shadow.withOpacity(0.8)
              : isDarkMode
                  ? theme.colorScheme.background
                  : theme.colorScheme.background,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius / 2),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.6)
                        : Colors.black26,
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
        ),
        child: Row(
          children: [
            // Letter container
            AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              curve: Curves.easeInOut,
              width: _isPressed || _isAnimated ? 76 : 80,
              height: _isPressed || _isAnimated ? 76 : 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _isPressed || _isAnimated
                    ? theme.colorScheme.primary.withOpacity(0.9)
                    : theme.colorScheme.primary.withOpacity(0.8),
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              ),
              child: Text(
                widget.letter,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.defaultPadding),

            // Pronunciation text
            Expanded(
              child: Text(
                widget.pronunciation,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),

            // Play icon
            Icon(
              Icons.play_arrow,
              color: _isPressed || _isAnimated
                  ? theme.colorScheme.secondary.withOpacity(0.8)
                  : theme.colorScheme.secondary,
              size: AppTheme.iconSize * 1.25,
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationButtons extends StatelessWidget {
  final int currentIndex; // Current index of displayed letters
  final int maxIndex; // Maximum index for navigation
  final Function(int) onNavigate; // Function to handle navigation

  const NavigationButtons({
    super.key,
    required this.currentIndex,
    required this.maxIndex,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Back button
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: currentIndex == 0
                ? Colors.grey
                : Color.fromARGB(
                    255, 255, 179, 0), // Disabled when at the start
          ),
          onPressed: currentIndex == 0 ? null : () => onNavigate(-1),
        ),
        // Forward button
        IconButton(
          icon: Icon(
            Icons.arrow_forward,
            color: currentIndex >= maxIndex
                ? Colors.grey
                : Color.fromARGB(255, 255, 179, 0), // Disabled when at the end
          ),
          onPressed: currentIndex >= maxIndex ? null : () => onNavigate(1),
        ),
        SizedBox(
          height: 80,
        ),
      ],
    );
  }
}

class PunjabiWordTile extends StatefulWidget {
  final String word;
  final String pronunciation;
  final VoidCallback onPlay;

  // Se ti serve la larghezza uniforme per il box blu, tieni questo parametro:
  final double? maxWidth;

  const PunjabiWordTile({
    Key? key,
    required this.word,
    required this.pronunciation,
    required this.onPlay,
    this.maxWidth, // Rendi opzionale se vuoi
  }) : super(key: key);

  @override
  _PunjabiWordTileState createState() => _PunjabiWordTileState();
}

class _PunjabiWordTileState extends State<PunjabiWordTile> {
  bool _isPressed = false;
  bool _isAnimated = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
      _isAnimated = true;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    Future.delayed(const Duration(milliseconds: 30), () {
      setState(() {
        _isAnimated = false;
      });
    });
    widget.onPlay();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
      _isAnimated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 9, horizontal: 7),
        padding: const EdgeInsets.all(AppTheme.defaultPadding / 2),
        decoration: BoxDecoration(
          color: _isPressed
              ? isDarkMode
                  ? theme.colorScheme.shadow.withOpacity(0.5)
                  : theme.colorScheme.shadow.withOpacity(0.7)
              : isDarkMode
                  ? theme.colorScheme.background
                  : theme.colorScheme.background,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.4)
                        : Colors.black26,
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
        ),
        child: Row(
          children: [
            // Word container
            AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              curve: Curves.easeInOut,
              width: widget.maxWidth,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _isPressed || _isAnimated
                    ? theme.colorScheme.primary.withOpacity(0.9)
                    : theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
              ),
              child: Text(
                widget.word,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: AppTheme.defaultPadding / 2),

            // Pronunciation text
            Expanded(
              child: Text(
                widget.pronunciation,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),

            // Play icon
            Icon(
              Icons.play_arrow,
              color: _isPressed || _isAnimated
                  ? theme.colorScheme.secondary.withOpacity(0.8)
                  : theme.colorScheme.secondary,
              size: AppTheme.iconSize,
            ),
          ],
        ),
      ),
    );
  }
}

  Widget BuildMenu(
    BuildContext context,
    String text,
    dynamic leading,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00274D), Color(0xFF00509D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.white.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  if (leading is IconData) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: Icon(
                        leading,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ] else ...[
                    Text(
                      leading.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

AppBar AppBarTitle(String title) {
  return AppBar(
    toolbarHeight: 75,
    backgroundColor: const Color.fromARGB(255, 0, 51, 102),
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto', // Specifica il font Roboto
        color: Color.fromARGB(255, 255, 255, 255),
      ),
    ),
    centerTitle: true,
    iconTheme: const IconThemeData(
      color: Colors.white, // Colore dell'icona del menu
    ),
  );
}

Widget SpecialButton({
  required BuildContext context,
  required String title,
  required Widget page,
}) {
  final theme = Theme.of(context);
  final isDarkMode = theme.brightness == Brightness.dark;
  
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    },
    child: Container(
      margin: const EdgeInsets.symmetric(
        vertical: 8, 
        horizontal: AppTheme.defaultPadding * 3
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [
                  theme.colorScheme.secondary.withOpacity(0.8),
                  theme.colorScheme.secondary.withOpacity(0.6),
                ]
              : [
                  theme.colorScheme.secondary,
                  theme.colorScheme.secondary.withOpacity(0.8),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.4)
                : theme.colorScheme.shadow.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
          splashColor: theme.colorScheme.onSecondary.withOpacity(0.2),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppTheme.defaultPadding * 1.25,
              horizontal: AppTheme.defaultPadding * 2.5
            ),
            child: Center(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}



// Aggiungi questa classe custom per il timer circolare

class CircularTimer extends StatelessWidget {
  final double timeLeft;
  final double maxTime;
  final double size;

  const CircularTimer({
    required this.timeLeft,
    required this.maxTime,
    this.size = 100,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = 1 - (timeLeft / maxTime);
    final angle = 2 * pi * progress;

    final borderColor = theme.colorScheme.primary; // decidi qui il colore

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TimerPainter(
          angle: angle,
          color: theme.colorScheme.surface.withOpacity(0.3),
          backgroundColor: theme.colorScheme.secondary,
          borderColor: borderColor,
        ),
      ),
    );
  }
}

class _TimerPainter extends CustomPainter {
  final double angle;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;

  _TimerPainter({
    required this.angle,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paintFull = Paint()..color = backgroundColor;
    final paintProgress = Paint()..color = color;
    final paintBorder = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    // Cerchio pieno (parte rimanente)
    canvas.drawCircle(center, radius, paintFull);

    // Settore "trascorso"
    if (angle > 0) {
      final path = Path();
      path.moveTo(center.dx, center.dy);
      path.arcTo(Rect.fromCircle(center: center, radius: radius), -pi / 2, angle, false);
      path.lineTo(center.dx, center.dy);
      path.close();
      canvas.drawPath(path, paintProgress);
    }

    // Cornice
    canvas.drawCircle(center, radius - 2.5, paintBorder);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}



class AnimatedGridButton extends StatefulWidget {
  final String letter;
  final VoidCallback onPressed;

  const AnimatedGridButton({
    required this.letter,
    required this.onPressed,
    super.key,
  });

  @override
  _AnimatedGridButtonState createState() => _AnimatedGridButtonState();
}

class _AnimatedGridButtonState extends State<AnimatedGridButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _isPressed
              ? Color.fromARGB(255, 0, 40, 80) // Darker when pressed
              : Color.fromARGB(255, 0, 51, 102), // Default color
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
        ),
        child: Center(
          child: Text(
            widget.letter,
            style: TextStyle(
              fontSize: 40,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

