import 'package:flutter/material.dart';
import 'dart:async';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _loadingAnimation;
  bool _isLoading = true;
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _logoFadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeIn),
      ),
    );

    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // Simulate loading process
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    // Simulate loading tasks
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _loadingProgress = 0.2);

    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _loadingProgress = 0.4);

    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _loadingProgress = 0.6);

    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _loadingProgress = 0.8);

    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _loadingProgress = 1.0;
      _isLoading = false;
    });

    // Navigate to main screen after loading is complete
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MyHomePage(title: 'Calmpanion'),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF98D8C8).withOpacity(_backgroundAnimation.value),
                  Color(0xFFB4E4D9).withOpacity(_backgroundAnimation.value),
                  Color(0xFFC5E1D5).withOpacity(_backgroundAnimation.value),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Background Pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: BackgroundPatternPainter(
                      opacity: _backgroundAnimation.value,
                    ),
                  ),
                ),
                // Main Content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with animations
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _logoFadeAnimation.value,
                            child: Transform.scale(
                              scale: _logoScaleAnimation.value,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CustomPaint(
                                      size: Size(120, 120),
                                      painter: BrainCircuitPainter(
                                        opacity: _logoFadeAnimation.value,
                                      ),
                                    ),
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Icon(
                                            Icons.psychology_alt,
                                            size: 30,
                                            color: Colors.white,
                                          ),
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.chat_bubble_outline,
                                                size: 12,
                                                color: Color(0xFF98D8C8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      // Text with fade animation
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _textFadeAnimation.value,
                            child: Column(
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white.withOpacity(0.95),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ).createShader(bounds),
                                  child: const Text(
                                    'CALMPANION',
                                    style: TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 4,
                                      height: 1.1,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 2),
                                          blurRadius: 8,
                                          color: Colors.black38,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.15),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 15,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'Your soul buddy and best companion\nfor your mental health',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                      height: 1.5,
                                      letterSpacing: 0.5,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 4,
                                          color: Colors.black26,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      // Loading Dots Animation
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _loadingAnimation.value,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) {
                                return TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                    begin: 0.0,
                                    end: 1.0,
                                  ),
                                  duration: Duration(milliseconds: 600),
                                  curve: Interval(
                                    index * 0.2,
                                    (index * 0.2) + 0.6,
                                    curve: Curves.easeInOut,
                                  ),
                                  builder: (context, value, child) {
                                    return Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 4),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withOpacity(0.3 + (value * 0.7)),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white
                                                .withOpacity(0.2 * value),
                                            blurRadius: 8,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      // Creator text
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _textFadeAnimation.value,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'Created by Rk Tushar',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                      color: Colors.black26,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Background Pattern Painter
class BackgroundPatternPainter extends CustomPainter {
  final double opacity;

  BackgroundPatternPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03 * opacity)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw grid pattern
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }

    // Draw diagonal lines
    for (double i = -size.height; i < size.width + size.height; i += 60) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Updated Brain Circuit Painter
class BrainCircuitPainter extends CustomPainter {
  final double opacity;

  BrainCircuitPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5 * opacity)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw circuit patterns
    final path = Path();

    // Outer circuit
    path.moveTo(size.width * 0.2, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.1,
      size.width * 0.8,
      size.height * 0.2,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.5,
      size.width * 0.8,
      size.height * 0.8,
    );
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.9,
      size.width * 0.2,
      size.height * 0.8,
    );
    path.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.5,
      size.width * 0.2,
      size.height * 0.2,
    );

    // Inner circuit
    path.moveTo(size.width * 0.35, size.height * 0.35);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.3,
      size.width * 0.65,
      size.height * 0.35,
    );
    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.5,
      size.width * 0.65,
      size.height * 0.65,
    );
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.7,
      size.width * 0.35,
      size.height * 0.65,
    );
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.5,
      size.width * 0.35,
      size.height * 0.35,
    );

    // Draw nodes
    final nodePaint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    // Draw nodes at circuit points
    final nodePositions = [
      Offset(size.width * 0.2, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 0.8),
      Offset(size.width * 0.35, size.height * 0.35),
      Offset(size.width * 0.65, size.height * 0.35),
      Offset(size.width * 0.65, size.height * 0.65),
      Offset(size.width * 0.35, size.height * 0.65),
    ];

    for (var position in nodePositions) {
      canvas.drawCircle(position, 3, nodePaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
