import 'package:flutter/material.dart';

import '../data/districts.dart';
import '../data/farm_tips.dart';
import '../data/weather.dart';
import '../theme/app_colors.dart';

/// "This week on your farm" — one piece of local advice, chosen by region and
/// season.
///
/// Wheat and cream rather than green, and that is a deliberate design decision:
/// every other card on the dashboard is green, so this one needs a different
/// colour to be seen at all. It is the only warm block on the screen, which is
/// what makes the eye stop on it.
class WeekTipCard extends StatelessWidget {
  final District district;
  final String lang;
  final DateTime now;

  const WeekTipCard({
    super.key,
    required this.district,
    required this.lang,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final region = findRegionForDistrict(district.id) ?? 'Western Maharashtra';
    final season = currentSeason(now);
    final tip = tipFor(region: region, season: season, lang: lang);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFF2E2BC)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFBF0), Color(0xFFFFF4DC)],
        ),
      ),
      // NOT CrossAxisAlignment.stretch. Inside a ListView the height of this
      // card is not known while it is being laid out, and "stretch" asks the
      // children to fill a height that does not exist yet — which throws
      // "RenderBox was not laid out" and blanks the whole screen. Worth
      // remembering: inside a scrolling list, always give a fixed size or let
      // the children decide it.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 11, 6, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBEDCB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _kicker(region, season),
                      style: const TextStyle(
                        fontFamily: 'NotoSansDevanagari',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: Color(0xFF9A6E12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tip.title,
                    style: const TextStyle(
                      fontFamily: 'NotoSansDevanagari',
                      fontSize: 13.5,
                      height: 1.3,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4A3708),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Capped at two lines so the card cannot grow and push the
                  // page past one screen. The full text will live in the Guide.
                  Text(
                    tip.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'NotoSansDevanagari',
                      fontSize: 11.5,
                      height: 1.4,
                      color: Color(0xFF7A6532),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // The illustration: a pod being inspected through a lens. Drawn rather
          // than downloaded, so it costs a few hundred bytes and stays sharp.
          //
          // The size is given explicitly. A CustomPaint with no size and no
          // child asks its parent how big it should be — and in a scrolling
          // list the answer is "unbounded", which is an error, not a number.
          SizedBox(
            width: 78,
            height: 84,
            child: CustomPaint(
              size: const Size(78, 84),
              painter: _PodAndLensPainter(),
            ),
          ),
        ],
      ),
    );
  }

  String _kicker(String region, FarmingSeason season) {
    final s = switch (season) {
      FarmingSeason.kharif => 'KHARIF',
      FarmingSeason.rabi => 'RABI',
      FarmingSeason.summer => 'SUMMER',
    };
    return '$s · ${region.toUpperCase()}';
  }
}

class _PodAndLensPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // A stem up the right side, with three pods hanging off it.
    final stem = Paint()
      ..color = const Color(0xFFCBA13C)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.62, h), Offset(w * 0.62, h * 0.34), stem);

    void pod(double cx, double cy, double angle, Color colour) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 20, height: 10),
        Paint()..color = colour,
      );
      canvas.restore();
    }

    pod(w * 0.44, h * 0.56, -0.5, const Color(0xFFE3B95A));
    pod(w * 0.78, h * 0.46, 0.42, const Color(0xFFD8AC46));
    pod(w * 0.48, h * 0.76, -0.35, const Color(0xFFD8AC46));

    // Two leaves at the top of the stem.
    final leaf = Paint()..color = const Color(0xFF7FB03F);
    final leafPath = Path()
      ..moveTo(w * 0.62, h * 0.34)
      ..quadraticBezierTo(w * 0.74, h * 0.30, w * 0.80, h * 0.16)
      ..quadraticBezierTo(w * 0.66, h * 0.18, w * 0.62, h * 0.34)
      ..close();
    canvas.drawPath(leafPath, leaf);
    final leafPath2 = Path()
      ..moveTo(w * 0.62, h * 0.34)
      ..quadraticBezierTo(w * 0.50, h * 0.31, w * 0.44, h * 0.18)
      ..quadraticBezierTo(w * 0.57, h * 0.20, w * 0.62, h * 0.34)
      ..close();
    canvas.drawPath(leafPath2, Paint()..color = const Color(0xFF5E9430));

    // The magnifying lens — the "check it" idea in one shape.
    final lensCentre = Offset(w * 0.30, h * 0.38);
    canvas.drawCircle(
      lensCentre,
      15,
      Paint()..color = const Color(0xFFFFFDF6).withValues(alpha: 0.75),
    );
    canvas.drawCircle(
      lensCentre,
      15,
      Paint()
        ..color = const Color(0xFFB98F2E)
        ..strokeWidth = 3.4
        ..style = PaintingStyle.stroke,
    );
    canvas.drawLine(
      Offset(lensCentre.dx + 11, lensCentre.dy + 11),
      Offset(lensCentre.dx + 20, lensCentre.dy + 20),
      Paint()
        ..color = const Color(0xFFB98F2E)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
