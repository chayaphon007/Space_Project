import 'dart:math';
import 'package:flutter/material.dart';

class SpaceWaveBackground extends StatefulWidget {
  const SpaceWaveBackground({super.key});

  @override
  _SpaceWaveBackgroundState createState() => _SpaceWaveBackgroundState();
}

class _SpaceWaveBackgroundState extends State<SpaceWaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    )..repeat(); // ✅ ทำให้คลื่นเคลื่อนไหวแบบไม่มีที่สิ้นสุด
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ✅ พื้นหลังอวกาศแบบ Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.deepPurple.shade900, Colors.black],
            ),
          ),
        ),

        // ✅ ลบส่วนที่เป็นดวงดาวออกไป

        // ✅ คลื่นน้ำอวกาศ
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: WavePainter(_controller.value),
              child: Container(),
            );
          },
        ),
      ],
    );
  }
}

// 🎨 วาดคลื่นน้ำ
class WavePainter extends CustomPainter {
  final double waveProgress;
  WavePainter(this.waveProgress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = Colors.blueAccent.withOpacity(0.5) // ✅ สีของคลื่น
          ..style = PaintingStyle.fill;

    final Path path = Path();
    final double waveHeight = 30;
    final double speed = waveProgress * 2 * pi; // ความเร็วการเคลื่อนที่

    path.moveTo(0, size.height * 0.7);

    for (double i = 0; i <= size.width; i += 10) {
      path.lineTo(
        i,
        size.height * 0.7 + sin((i / size.width * 2 * pi) + speed) * waveHeight,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}
