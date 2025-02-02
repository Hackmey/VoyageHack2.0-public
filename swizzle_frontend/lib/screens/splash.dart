import 'package:flutter/material.dart';
import 'package:swizzle_frontend/screens/wrapper.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
    // Navigate to the next screen after animation finishes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WrapperPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: AirplanePainter(_animation.value),
            child: Center(
              child: Image.asset(
                'lib/assets/logo.png', // Add an optional logo
                height: 100,
                width: 100,
              ),
            ),
          );
        },
      ),
    );
  }
}

class AirplanePainter extends CustomPainter {
  final double progress;

  AirplanePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;


    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 32,
      fontFamily: 'NovaCut', // Ensure the font is added in pubspec.yaml
    );

    final textSpan = TextSpan(
      text: 'swizzle',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Define the path the airplane will follow
    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.5); // Start point
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.3, // Control point
      size.width * 0.9, size.height * 0.5, // End point
    );

    // Draw the writing path
    canvas.drawPath(path, paint);

    // Calculate the airplane position along the path
    final pathMetrics = path.computeMetrics().first;
    final offset = pathMetrics.getTangentForOffset(progress * pathMetrics.length)?.position;

    // Draw the airplane
    if (offset != null) {
      final airplanePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(offset, 6.0, airplanePaint); // Simple circle as airplane
    }

    // Draw the text when the airplane completes the path
    if (progress == 1.0) {
      textPainter.paint(
        canvas,
        Offset(size.width * 0.4, size.height * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
