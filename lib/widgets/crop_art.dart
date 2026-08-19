import 'package:flutter/material.dart';

/// Drawn illustrations for the crop cards.
///
/// Why not images? Four reasons, and they are worth knowing because this choice
/// comes up in every app:
///   1. Photographs found online are almost always licensed. In a submitted
///      project that is a real problem, not a technicality.
///   2. A stock photo of a foreign farm looks wrong for Maharashtra.
///   3. A PNG has one fixed size — it blurs on a big screen and wastes space on
///      a small one. Drawing is sharp at every size.
///   4. Twelve photographs would add megabytes. These add almost nothing.
///
/// Each crop gets its own drawing. The point is that no two cards look alike —
/// the same leaf icon repeated four times is what made the old row read as
/// unfinished.
enum CropKind {
  sugarcane,
  grapes,
  pomegranate,
  legume, // soybean, tur, gram
  cotton,
  onion,
  citrus, // orange, sweet lime
  mango,
  grain, // wheat, jowar, bajra, rice
  banana,
  tree, // cashew, coconut, jackfruit, betel nut
  turmeric,
}

/// Maps an English crop name to a drawing. Anything unrecognised falls back to
/// the grain drawing rather than showing nothing.
CropKind cropKindFor(String englishName) {
  switch (englishName.toLowerCase()) {
    case 'sugarcane':
      return CropKind.sugarcane;
    case 'grapes':
      return CropKind.grapes;
    case 'pomegranate':
      return CropKind.pomegranate;
    case 'soybean':
    case 'tur':
    case 'gram':
      return CropKind.legume;
    case 'cotton':
      return CropKind.cotton;
    case 'onion':
      return CropKind.onion;
    case 'orange':
    case 'mosambi':
    case 'sweet lime':
      return CropKind.citrus;
    case 'mango':
      return CropKind.mango;
    case 'banana':
      return CropKind.banana;
    case 'cashew':
    case 'coconut':
    case 'jackfruit':
    case 'betel nut':
      return CropKind.tree;
    case 'turmeric':
      return CropKind.turmeric;
    default:
      return CropKind.grain;
  }
}

/// The soft background tint behind each drawing. Different per crop so the row
/// has some rhythm instead of four identical green squares.
List<Color> cropTint(CropKind kind) {
  switch (kind) {
    case CropKind.grapes:
      return const [Color(0xFFF1EBF7), Color(0xFFE7DEF1)];
    case CropKind.pomegranate:
      return const [Color(0xFFFDECEA), Color(0xFFF8DDD9)];
    case CropKind.citrus:
    case CropKind.mango:
      return const [Color(0xFFFFF6E4), Color(0xFFFDEBCB)];
    case CropKind.cotton:
      return const [Color(0xFFF6F8F9), Color(0xFFEAEFF2)];
    case CropKind.onion:
      return const [Color(0xFFFBEEF3), Color(0xFFF4DFE8)];
    case CropKind.banana:
      return const [Color(0xFFFCF8E3), Color(0xFFF6F0CC)];
    case CropKind.turmeric:
      return const [Color(0xFFFFF3E0), Color(0xFFFBE6C8)];
    default:
      return const [Color(0xFFEAF6EA), Color(0xFFDCEEDD)];
  }
}

/// A real photograph filling the whole tile, or — if there is no photograph for
/// this crop yet — the drawn illustration on its tinted background.
///
/// Photographs win when they exist. They fill the tile edge to edge with no
/// padding and no tint, which is what makes the row look like a real product
/// rather than a set of icons. The drawing is the safety net, so pictures can be
/// added one crop at a time and a missing file can never break the screen.
class CropThumb extends StatelessWidget {
  final CropKind kind;

  /// The crop's English name, lowercased, spaces to underscores — `sugarcane`,
  /// `betel_nut`. The picture is looked for at `assets/crops/<key>.jpg`.
  final String assetKey;

  final double height;

  const CropThumb({
    super.key,
    required this.kind,
    required this.assetKey,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/crops/$assetKey.jpg',
      height: height,
      width: double.infinity,
      // cover, not contain: the photo fills the tile and is cropped, rather than
      // sitting in the middle with bars around it.
      fit: BoxFit.cover,
      // No photograph for this crop yet. errorBuilder is what turns a missing
      // asset from a crash into a graceful substitute.
      errorBuilder: (context, error, stack) => Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: cropTint(kind),
          ),
        ),
        child: Center(child: CropArt(kind: kind, height: height - 6)),
      ),
    );
  }
}

/// The drawn illustration on its organic blob background. Used only where no
/// photograph exists.
class CropArt extends StatelessWidget {
  final CropKind kind;
  final double height;

  const CropArt({super.key, required this.kind, this.height = 66});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // An irregular soft shape behind the artwork. A plain circle reads as
          // an icon badge; an uneven blob reads as illustration.
          CustomPaint(size: Size(66, height), painter: _BlobPainter()),
          CustomPaint(size: Size(62, height - 6), painter: _CropPainter(kind)),
        ],
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint()..color = Colors.white.withValues(alpha: 0.72);

    // Four curves with deliberately unequal control points.
    final path = Path()
      ..moveTo(w * 0.5, h * 0.10)
      ..cubicTo(w * 0.92, h * 0.08, w * 1.02, h * 0.52, w * 0.82, h * 0.78)
      ..cubicTo(w * 0.66, h * 0.98, w * 0.30, h * 1.00, w * 0.14, h * 0.80)
      ..cubicTo(w * -0.02, h * 0.58, w * 0.06, h * 0.18, w * 0.5, h * 0.10)
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CropPainter extends CustomPainter {
  final CropKind kind;
  _CropPainter(this.kind);

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case CropKind.sugarcane:
        _sugarcane(canvas, size);
      case CropKind.grapes:
        _grapes(canvas, size);
      case CropKind.pomegranate:
        _pomegranate(canvas, size);
      case CropKind.legume:
        _legume(canvas, size);
      case CropKind.cotton:
        _cotton(canvas, size);
      case CropKind.onion:
        _onion(canvas, size);
      case CropKind.citrus:
        _citrus(canvas, size);
      case CropKind.mango:
        _mango(canvas, size);
      case CropKind.grain:
        _grain(canvas, size);
      case CropKind.banana:
        _banana(canvas, size);
      case CropKind.tree:
        _tree(canvas, size);
      case CropKind.turmeric:
        _turmeric(canvas, size);
    }
  }

  // ---- helpers ----

  Paint _fill(Color c) => Paint()..color = c;

  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  /// A pointed leaf growing from [from] towards [to], bulging to one side.
  void _leaf(Canvas canvas, Offset from, Offset to, Color colour, double bulge) {
    final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
    final normal = Offset(-(to.dy - from.dy), to.dx - from.dx);
    final len = normal.distance == 0 ? 1 : normal.distance;
    final off = Offset(normal.dx / len * bulge, normal.dy / len * bulge);
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(mid.dx + off.dx, mid.dy + off.dy, to.dx, to.dy)
      ..quadraticBezierTo(mid.dx - off.dx * 0.35, mid.dy - off.dy * 0.35,
          from.dx, from.dy)
      ..close();
    canvas.drawPath(path, _fill(colour));
  }

  // ---- the crops ----

  void _sugarcane(Canvas canvas, Size s) {
    final w = s.width, h = s.height;

    // Leaves first, so the canes sit in front of them — that overlap is what
    // gives the little drawing depth.
    const dark = Color(0xFF2F7A22);
    const mid = Color(0xFF4B9824);
    const light = Color(0xFF79B84A);
    _leaf(canvas, Offset(w * 0.42, h * 0.44), Offset(w * -0.04, h * 0.20), dark, 9);
    _leaf(canvas, Offset(w * 0.58, h * 0.44), Offset(w * 1.04, h * 0.20), dark, -9);
    _leaf(canvas, Offset(w * 0.42, h * 0.40), Offset(w * 0.04, h * 0.62), mid, 8);
    _leaf(canvas, Offset(w * 0.58, h * 0.40), Offset(w * 0.96, h * 0.62), mid, -8);
    _leaf(canvas, Offset(w * 0.44, h * 0.36), Offset(w * 0.16, h * -0.02), light, 6);
    _leaf(canvas, Offset(w * 0.56, h * 0.36), Offset(w * 0.84, h * -0.02), light, -6);

    // Two canes, one slightly taller — a single cane looks like a stick.
    void cane(double cx, double topY, double width) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTRB(cx - width / 2, topY, cx + width / 2, h),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, _fill(const Color(0xFFC98A3C)));

      // A lighter stripe down one side reads as a round stalk catching light.
      canvas.drawRect(
        Rect.fromLTRB(cx - width * 0.12, topY + 2, cx + width * 0.30, h),
        _fill(const Color(0xFFE8C078)),
      );

      // Node bands across the cane — the single feature that says "sugarcane".
      final node = _stroke(const Color(0xFFA96C25), 1.6);
      for (var f = 0.28; f < 1.0; f += 0.20) {
        final y = topY + (h - topY) * f;
        canvas.drawLine(
          Offset(cx - width / 2, y),
          Offset(cx + width / 2, y),
          node,
        );
      }
      // The pale cut top.
      canvas.drawRect(
        Rect.fromLTRB(cx - width / 2, topY, cx + width / 2, topY + 3),
        _fill(const Color(0xFFF0DDB4)),
      );
    }

    cane(w * 0.41, h * 0.34, w * 0.15);
    cane(w * 0.60, h * 0.22, w * 0.16);
  }

  void _grapes(Canvas canvas, Size s) {
    final w = s.width, h = s.height;

    // A curved stalk and a jagged vine leaf. The leaf shape matters — a round
    // leaf next to a grape cluster reads as cherries.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.52, h * 0.30)
        ..quadraticBezierTo(w * 0.62, h * 0.18, w * 0.72, h * 0.08),
      _stroke(const Color(0xFF5E9430), 3),
    );
    final vineLeaf = Path()
      ..moveTo(w * 0.50, h * 0.20)
      ..lineTo(w * 0.30, h * 0.14)
      ..lineTo(w * 0.38, h * 0.09)
      ..lineTo(w * 0.22, h * 0.04)
      ..lineTo(w * 0.40, h * 0.01)
      ..lineTo(w * 0.44, h * -0.06)
      ..lineTo(w * 0.52, h * 0.02)
      ..lineTo(w * 0.62, h * 0.00)
      ..close();
    canvas.drawPath(vineLeaf, _fill(const Color(0xFF67A83C)));

    // The cluster, widest in the middle and coming to a point at the bottom.
    const rows = [
      [0.32, 0.50, 0.68],
      [0.24, 0.41, 0.59, 0.76],
      [0.32, 0.50, 0.68],
      [0.41, 0.59],
      [0.50],
    ];
    final r = w * 0.105;
    for (var i = 0; i < rows.length; i++) {
      for (final x in rows[i]) {
        final c = Offset(w * x, h * (0.34 + i * 0.145));
        // Dark base, lighter body offset up-left, then a white glint. Three
        // shapes per berry is what makes it look round instead of flat.
        canvas.drawCircle(c, r, _fill(const Color(0xFF6E4491)));
        canvas.drawCircle(
          c.translate(-r * 0.12, -r * 0.14),
          r * 0.84,
          _fill(const Color(0xFF9A5FC4)),
        );
        canvas.drawCircle(
          c.translate(-r * 0.34, -r * 0.36),
          r * 0.26,
          _fill(Colors.white.withValues(alpha: 0.85)),
        );
      }
    }
  }

  void _pomegranate(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final centre = Offset(w * 0.5, h * 0.60);
    final radius = w * 0.33;

    // Deep red body, then a brighter face offset up-left. Same trick as the
    // grapes: two overlapping circles read as a sphere.
    canvas.drawCircle(centre, radius, _fill(const Color(0xFFA82A1E)));
    canvas.drawCircle(
      centre.translate(-radius * 0.10, -radius * 0.12),
      radius * 0.88,
      _fill(const Color(0xFFD1342A)),
    );

    // The crown. This is the whole identity of the fruit — without it a red
    // circle is a tomato.
    final crown = Path()
      ..moveTo(w * 0.38, h * 0.32)
      ..lineTo(w * 0.42, h * 0.16)
      ..lineTo(w * 0.48, h * 0.26)
      ..lineTo(w * 0.53, h * 0.13)
      ..lineTo(w * 0.58, h * 0.25)
      ..lineTo(w * 0.64, h * 0.18)
      ..lineTo(w * 0.62, h * 0.33)
      ..close();
    canvas.drawPath(crown, _fill(const Color(0xFF8E2318)));

    // A soft gloss, and a hint of the calyx ridge.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.38, h * 0.48),
        width: w * 0.16,
        height: h * 0.13,
      ),
      _fill(const Color(0xFFF08A7A).withValues(alpha: 0.55)),
    );
    canvas.drawCircle(
      Offset(w * 0.62, h * 0.70),
      w * 0.04,
      _fill(const Color(0xFF8E2318).withValues(alpha: 0.35)),
    );
  }

  void _legume(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    canvas.drawLine(
      Offset(w * 0.5, h),
      Offset(w * 0.5, h * 0.26),
      _stroke(const Color(0xFF6B8F3E), 3.2),
    );
    void pod(double cx, double cy, double angle, Color c) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: w * 0.34, height: h * 0.16),
        _fill(c),
      );
      canvas.restore();
    }

    pod(w * 0.30, h * 0.52, -0.52, const Color(0xFFA8C452));
    pod(w * 0.72, h * 0.40, 0.45, const Color(0xFF94B443));
    pod(w * 0.34, h * 0.76, -0.38, const Color(0xFF94B443));
    _leaf(canvas, Offset(w * 0.5, h * 0.26), Offset(w * 0.80, h * 0.08),
        const Color(0xFF79B84A), 7);
  }

  void _cotton(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    canvas.drawLine(
      Offset(w * 0.5, h),
      Offset(w * 0.5, h * 0.42),
      _stroke(const Color(0xFF7A6A4E), 3),
    );
    // The boll: four white lobes with a brown star behind them.
    final husk = _fill(const Color(0xFF8A7A5C));
    for (final a in [0.0, 1.57, 3.14, 4.71]) {
      canvas.save();
      canvas.translate(w * 0.5, h * 0.34);
      canvas.rotate(a + 0.4);
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, -11), width: 9, height: 20),
        husk,
      );
      canvas.restore();
    }
    for (final o in [
      Offset(w * 0.38, h * 0.30),
      Offset(w * 0.62, h * 0.30),
      Offset(w * 0.5, h * 0.18),
      Offset(w * 0.5, h * 0.40),
    ]) {
      canvas.drawCircle(o, w * 0.14, _fill(Colors.white));
    }
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.30),
      w * 0.13,
      _fill(const Color(0xFFF7F7F4)),
    );
  }

  void _onion(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    // Bulb: a circle squashed slightly and pointed at the bottom.
    final bulb = Path()
      ..moveTo(w * 0.5, h * 0.34)
      ..cubicTo(w * 0.92, h * 0.36, w * 0.88, h * 0.92, w * 0.5, h * 0.94)
      ..cubicTo(w * 0.12, h * 0.92, w * 0.08, h * 0.36, w * 0.5, h * 0.34)
      ..close();
    canvas.drawPath(bulb, _fill(const Color(0xFFB05A86)));
    // Skin lines.
    final line = _stroke(const Color(0xFF8E4269).withValues(alpha: 0.55), 1.6);
    canvas.drawLine(Offset(w * 0.5, h * 0.36), Offset(w * 0.5, h * 0.92), line);
    canvas.drawLine(Offset(w * 0.34, h * 0.42), Offset(w * 0.30, h * 0.80), line);
    canvas.drawLine(Offset(w * 0.66, h * 0.42), Offset(w * 0.70, h * 0.80), line);
    // Green tops.
    final top = _stroke(const Color(0xFF5E9430), 3);
    canvas.drawLine(Offset(w * 0.5, h * 0.34), Offset(w * 0.40, h * 0.04), top);
    canvas.drawLine(Offset(w * 0.5, h * 0.34), Offset(w * 0.62, h * 0.08), top);
  }

  void _citrus(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.58),
      w * 0.31,
      _fill(const Color(0xFFEE9126)),
    );
    // Dimple texture.
    final dot = _fill(const Color(0xFFD97C15).withValues(alpha: 0.5));
    for (final o in [
      Offset(w * 0.40, h * 0.48),
      Offset(w * 0.58, h * 0.52),
      Offset(w * 0.46, h * 0.66),
      Offset(w * 0.62, h * 0.68),
    ]) {
      canvas.drawCircle(o, 1.9, dot);
    }
    canvas.drawLine(
      Offset(w * 0.5, h * 0.28),
      Offset(w * 0.5, h * 0.18),
      _stroke(const Color(0xFF6B4A22), 2.6),
    );
    _leaf(canvas, Offset(w * 0.5, h * 0.22), Offset(w * 0.84, h * 0.10),
        const Color(0xFF3F7F2A), 7);
  }

  void _mango(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    // The mango shape: fat at the bottom, curving to a shoulder at the top.
    final body = Path()
      ..moveTo(w * 0.52, h * 0.26)
      ..cubicTo(w * 0.94, h * 0.34, w * 0.90, h * 0.86, w * 0.50, h * 0.90)
      ..cubicTo(w * 0.16, h * 0.86, w * 0.14, h * 0.42, w * 0.52, h * 0.26)
      ..close();
    canvas.drawPath(body, _fill(const Color(0xFFE8A32B)));
    // A blush of red on the shoulder — Alphonso.
    canvas.drawCircle(
      Offset(w * 0.66, h * 0.42),
      w * 0.13,
      _fill(const Color(0xFFD9553F).withValues(alpha: 0.45)),
    );
    canvas.drawLine(
      Offset(w * 0.52, h * 0.26),
      Offset(w * 0.50, h * 0.12),
      _stroke(const Color(0xFF6B4A22), 2.4),
    );
    _leaf(canvas, Offset(w * 0.50, h * 0.16), Offset(w * 0.18, h * 0.06),
        const Color(0xFF3F7F2A), 6);
  }

  void _grain(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    canvas.drawLine(
      Offset(w * 0.5, h),
      Offset(w * 0.5, h * 0.34),
      _stroke(const Color(0xFFC9A227), 3),
    );
    // Grains in two staggered columns up the ear.
    const gold = Color(0xFFE8BE3E);
    for (var i = 0; i < 5; i++) {
      final y = h * (0.34 + i * 0.11);
      canvas.save();
      canvas.translate(w * 0.5, y);
      canvas.rotate(-0.5);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(-w * 0.13, 0),
          width: w * 0.22,
          height: h * 0.10,
        ),
        _fill(gold),
      );
      canvas.restore();
      canvas.save();
      canvas.translate(w * 0.5, y);
      canvas.rotate(0.5);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.13, 0),
          width: w * 0.22,
          height: h * 0.10,
        ),
        _fill(const Color(0xFFD8AC46)),
      );
      canvas.restore();
    }
    // Awns at the tip.
    final awn = _stroke(const Color(0xFFD8AC46), 1.6);
    canvas.drawLine(Offset(w * 0.5, h * 0.34), Offset(w * 0.36, h * 0.06), awn);
    canvas.drawLine(Offset(w * 0.5, h * 0.34), Offset(w * 0.5, h * 0.02), awn);
    canvas.drawLine(Offset(w * 0.5, h * 0.34), Offset(w * 0.64, h * 0.06), awn);
  }

  void _banana(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    // Three curved fingers.
    void finger(double dx, double dy, Color c) {
      final p = Path()
        ..moveTo(w * (0.30 + dx), h * (0.28 + dy))
        ..quadraticBezierTo(
          w * (0.86 + dx),
          h * (0.40 + dy),
          w * (0.62 + dx),
          h * (0.84 + dy),
        )
        ..quadraticBezierTo(
          w * (0.66 + dx),
          h * (0.44 + dy),
          w * (0.30 + dx),
          h * (0.28 + dy),
        )
        ..close();
      canvas.drawPath(p, _fill(c));
    }

    finger(-0.10, 0.02, const Color(0xFFD9B531));
    finger(0.0, -0.02, const Color(0xFFEFCB3F));
    finger(0.10, 0.04, const Color(0xFFE2C038));
    canvas.drawCircle(
      Offset(w * 0.30, h * 0.26),
      3.4,
      _fill(const Color(0xFF6B5B2A)),
    );
  }

  void _tree(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    canvas.drawLine(
      Offset(w * 0.5, h),
      Offset(w * 0.5, h * 0.44),
      _stroke(const Color(0xFF8A6B3E), 3.4),
    );
    const dark = Color(0xFF3F7F2A);
    const light = Color(0xFF5FA23C);
    _leaf(canvas, Offset(w * 0.5, h * 0.44), Offset(w * 0.06, h * 0.30), dark, 8);
    _leaf(canvas, Offset(w * 0.5, h * 0.44), Offset(w * 0.94, h * 0.30), dark, -8);
    _leaf(canvas, Offset(w * 0.5, h * 0.44), Offset(w * 0.16, h * 0.06), light, 7);
    _leaf(canvas, Offset(w * 0.5, h * 0.44), Offset(w * 0.84, h * 0.06), light, -7);
    _leaf(canvas, Offset(w * 0.5, h * 0.44), Offset(w * 0.5, h * 0.00), light, 6);
  }

  /// Broad upright leaves above ground, orange rhizomes below it — which is the
  /// part the farmer actually sells.
  void _turmeric(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    const dark = Color(0xFF2F7A22);
    const light = Color(0xFF5FA23C);

    _leaf(canvas, Offset(w * 0.5, h * 0.68), Offset(w * 0.14, h * 0.06), dark, 11);
    _leaf(canvas, Offset(w * 0.5, h * 0.68), Offset(w * 0.86, h * 0.06), dark, -11);
    _leaf(canvas, Offset(w * 0.5, h * 0.68), Offset(w * 0.40, h * -0.04), light, 8);
    _leaf(canvas, Offset(w * 0.5, h * 0.68), Offset(w * 0.66, h * -0.02), light, -8);

    void rhizome(double cx, double cy, double angle) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: w * 0.30,
          height: h * 0.15,
        ),
        _fill(const Color(0xFFE08A1E)),
      );
      canvas.restore();
    }

    rhizome(w * 0.36, h * 0.84, -0.28);
    rhizome(w * 0.64, h * 0.90, 0.24);
    rhizome(w * 0.52, h * 0.76, 0.10);
  }

  @override
  bool shouldRepaint(covariant _CropPainter oldDelegate) =>
      oldDelegate.kind != kind;
}
