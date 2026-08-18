import 'dart:math';

import 'package:flutter/material.dart';

/// The band of grass and small flowers that closes the dashboard.
///
/// Drawn, not an image. Three hundred-odd blades are generated from a *seeded*
/// random number generator — `Random(7)` — which matters: a fixed seed means the
/// grass looks identical every single time the app opens. Without the seed it
/// would rearrange itself on every rebuild, which looks like a glitch.
///
/// Three depth layers, palest and tallest at the back, darkest and densest at
/// the front. That overlap is the whole trick: a single row of blades reads as
/// spikes, three layers read as a field.
class GrassFooter extends StatelessWidget {
  final double height;

  const GrassFooter({super.key, this.height = 86});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _GrassPainter()),
    );
  }
}

class _Blade {
  final double x, height, lean, width;
  const _Blade(this.x, this.height, this.lean, this.width);
}

class _GrassPainter extends CustomPainter {
  /// Built once and reused, so we are not generating random numbers on every
  /// frame. Painters get called a lot — during scrolling, most of all.
  static List<List<_Blade>>? _layers;
  static List<_Seed>? _seeds;

  static const _flowerSpots = <List<double>>[
    [0.06, 12, 1.00],
    [0.15, 20, 0.82],
    [0.25, 9, 0.92],
    [0.36, 17, 0.78],
    [0.46, 11, 1.00],
    [0.55, 21, 0.80],
    [0.64, 10, 0.90],
    [0.74, 18, 0.84],
    [0.83, 13, 0.95],
    [0.92, 20, 0.80],
  ];

  void _build() {
    if (_layers != null) return;
    final rnd = Random(7);

    List<_Blade> layer(
      double step,
      double hMin,
      double hMax,
      double wMin,
      double wMax,
      double leanMax,
      double jitter,
    ) {
      final out = <_Blade>[];
      var x = -6.0;
      // Generated against a nominal 392-wide screen, then scaled to whatever
      // width the phone actually is.
      while (x < 398) {
        out.add(
          _Blade(
            x,
            hMin + rnd.nextDouble() * (hMax - hMin),
            (rnd.nextDouble() * 2 - 1) * leanMax,
            wMin + rnd.nextDouble() * (wMax - wMin),
          ),
        );
        x += step + (rnd.nextDouble() * 2 - 1) * jitter;
      }
      return out;
    }

    // Denser and wider than the first attempt. The first version used blades
    // 1–2 pixels wide spaced 5 apart, and on a real screen that read as a few
    // stray hairs rather than grass. Roughly three times the blades, each about
    // twice as wide, and the layers now overlap properly.
    _layers = [
      layer(3.4, 34, 62, 2.2, 3.6, 15, 1.4), // back
      layer(2.8, 24, 46, 2.6, 4.2, 11, 1.2), // middle
      layer(2.2, 14, 32, 3.0, 4.8, 8, 1.0), // front
    ];

    final srnd = Random(21);
    _seeds = List.generate(16, (_) {
      return _Seed(
        6 + srnd.nextDouble() * 380,
        58 + srnd.nextDouble() * 26,
        (srnd.nextDouble() * 2 - 1) * 10,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    _build();
    final scale = size.width / 392.0;
    final base = size.height - 4;

    // A rise of ground, so the grass grows out of something rather than floating
    // on white. Two bands — pale behind, stronger in front — which does most of
    // the work of making the strip feel solid rather than sparse.
    final backGround = Path()
      ..moveTo(0, size.height * 0.62)
      ..cubicTo(
        size.width * 0.30,
        size.height * 0.52,
        size.width * 0.68,
        size.height * 0.74,
        size.width,
        size.height * 0.58,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(backGround, Paint()..color = const Color(0xFFE7F4E9));

    final frontGround = Path()
      ..moveTo(0, size.height * 0.86)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.78,
        size.width * 0.72,
        size.height * 0.96,
        size.width,
        size.height * 0.84,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(frontGround, Paint()..color = const Color(0xFFD3E9D7));

    const colours = [
      Color(0xFFC6E3B4), // back
      Color(0xFF9BCE7B), // middle
      Color(0xFF5FA23C), // front
    ];

    void drawLayer(List<_Blade> blades, Color colour) {
      final paint = Paint()..color = colour;
      for (final b in blades) {
        final x = b.x * scale;
        final w = b.width * scale;
        final h = b.height * scale;
        final lean = b.lean * scale;
        final tipX = x + lean;
        final tipY = base - h;
        final ctrlX = x + lean * 0.35;
        final ctrlY = base - h * 0.55;

        // A tapered blade: out along one edge to the tip, back down the other.
        // Filled rather than stroked, so it narrows naturally to a point.
        final path = Path()
          ..moveTo(x - w, base)
          ..quadraticBezierTo(ctrlX - w * 0.5, ctrlY, tipX, tipY)
          ..quadraticBezierTo(ctrlX + w * 0.5, ctrlY, x + w, base)
          ..close();
        canvas.drawPath(path, paint);
      }
    }

    drawLayer(_layers![0], colours[0]);
    drawLayer(_layers![1], colours[1]);

    // Seed heads poking above the grass — the detail that stops it looking like
    // a lawn and makes it read as a field edge.
    final stalk = Paint()
      ..color = const Color(0xFF8CBE6A)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    final head = Paint()..color = const Color(0xFFA9CE84);
    for (final s in _seeds!) {
      final x = s.x * scale;
      final h = s.height * scale;
      final lean = s.lean * scale;
      canvas.drawPath(
        Path()
          ..moveTo(x, base)
          ..quadraticBezierTo(x + lean * 0.4, base - h * 0.6, x + lean, base - h),
        stalk,
      );
      canvas.save();
      canvas.translate(x + lean, base - h - 2);
      canvas.rotate(s.lean * 0.028);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 3.4, height: 6.8),
        head,
      );
      canvas.restore();
    }

    drawLayer(_layers![2], colours[2]);

    // Small white flowers with yellow centres, low in the grass. Spacing is
    // uneven on purpose — evenly spaced decoration always looks fake.
    final petal = Paint()..color = Colors.white;
    final centre = Paint()..color = const Color(0xFFF5C542);
    final stem = Paint()
      ..color = const Color(0xFF6FA84F)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (final f in _flowerSpots) {
      final x = size.width * f[0];
      final cy = base - f[1] * scale;
      final sc = f[2];
      final r = 4.3 * sc * scale;

      canvas.drawLine(Offset(x, base), Offset(x, cy + 3), stem);
      for (var a = 0; a < 360; a += 72) {
        final rad = a * pi / 180;
        final px = x + cos(rad) * r;
        final py = cy + sin(rad) * r;
        canvas.save();
        canvas.translate(px, py);
        canvas.rotate(rad);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: 6.2 * sc * scale,
            height: 4.6 * sc * scale,
          ),
          petal,
        );
        canvas.restore();
      }
      canvas.drawCircle(Offset(x, cy), 2.1 * sc * scale, centre);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Seed {
  final double x, height, lean;
  const _Seed(this.x, this.height, this.lean);
}
