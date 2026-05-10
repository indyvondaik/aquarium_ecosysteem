import 'dart:math' as math;

import 'package:flutter/material.dart';

enum ReefLifeIconType { algae, fish, crab }

class ReefLifeIcon extends StatelessWidget {
  const ReefLifeIcon({
    required this.type,
    required this.color,
    this.accentColor,
    this.size = 28,
    this.semanticLabel,
    super.key,
  });

  final ReefLifeIconType type;
  final Color color;
  final Color? accentColor;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final icon = CustomPaint(
      size: Size.square(size),
      painter: _ReefLifeIconPainter(
        type: type,
        color: color,
        accentColor: accentColor ?? color.withValues(alpha: 0.58),
      ),
    );

    if (semanticLabel == null) {
      return icon;
    }

    return Semantics(label: semanticLabel, image: true, child: icon);
  }
}

class _ReefLifeIconPainter extends CustomPainter {
  const _ReefLifeIconPainter({
    required this.type,
    required this.color,
    required this.accentColor,
  });

  final ReefLifeIconType type;
  final Color color;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 32, size.height / 32);

    switch (type) {
      case ReefLifeIconType.algae:
        _paintAlgae(canvas);
        break;
      case ReefLifeIconType.fish:
        _paintFish(canvas);
        break;
      case ReefLifeIconType.crab:
        _paintCrab(canvas);
        break;
    }

    canvas.restore();
  }

  void _paintAlgae(Canvas canvas) {
    final line = Paint()
      ..color = color
      ..strokeWidth = 2.7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final fill = Paint()..color = accentColor;

    for (final spec in [
      (base: const Offset(9, 27), tip: const Offset(8, 7), lean: -6.0),
      (base: const Offset(16, 28), tip: const Offset(17, 4), lean: 2.5),
      (base: const Offset(23, 27), tip: const Offset(25, 9), lean: 6.0),
    ]) {
      final path = Path()
        ..moveTo(spec.base.dx, spec.base.dy)
        ..cubicTo(
          spec.base.dx + spec.lean,
          21,
          spec.tip.dx - spec.lean * 0.45,
          13,
          spec.tip.dx,
          spec.tip.dy,
        );
      canvas.drawPath(path, line);
    }

    for (final leaf in [
      (center: const Offset(10.5, 15.5), angle: -0.7),
      (center: const Offset(18.2, 12.5), angle: 0.52),
      (center: const Offset(22.5, 18), angle: 0.72),
    ]) {
      canvas.save();
      canvas.translate(leaf.center.dx, leaf.center.dy);
      canvas.rotate(leaf.angle);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 4.2, height: 8.8),
        fill,
      );
      canvas.restore();
    }
  }

  void _paintFish(Canvas canvas) {
    final fill = Paint()..color = color;
    final accent = Paint()..color = accentColor;
    final eye = Paint()..color = Colors.white;

    final tail = Path()
      ..moveTo(8, 16)
      ..lineTo(2.5, 10)
      ..lineTo(2.5, 22)
      ..close();
    canvas.drawPath(tail, accent);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(17, 16), width: 20, height: 12),
      fill,
    );

    final fin = Path()
      ..moveTo(14, 17)
      ..lineTo(10, 23)
      ..lineTo(20, 19.4)
      ..close();
    canvas.drawPath(fin, accent);
    canvas.drawCircle(const Offset(23.5, 13.7), 1.55, eye);
    canvas.drawCircle(const Offset(24, 14), 0.72, Paint()..color = color);
  }

  void _paintCrab(Canvas canvas) {
    final fill = Paint()..color = color;
    final accent = Paint()
      ..color = accentColor
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final line = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final eye = Paint()..color = Colors.white;

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(16, 18.5), width: 14.5, height: 10),
      fill,
    );
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(16, 17), width: 9.5, height: 5.8),
      math.pi,
      math.pi,
      false,
      accent,
    );

    for (final direction in [-1.0, 1.0]) {
      canvas.drawLine(
        Offset(16 + direction * 5.5, 16.2),
        Offset(16 + direction * 9.7, 10.2),
        line,
      );
      _paintCrabClaw(canvas, direction, fill);

      for (var index = 0; index < 4; index++) {
        final start = Offset(16 + direction * 5.3, 17.2 + index * 1.8);
        final end = Offset(
          16 + direction * (9.5 + index * 0.95),
          20.3 + index * 1.35,
        );
        final foot = Offset(end.dx + direction * 2.5, end.dy - 0.7);
        canvas.drawLine(start, end, line);
        canvas.drawLine(end, foot, line);
      }
    }

    canvas.drawLine(const Offset(13.2, 14.2), const Offset(12.2, 11.2), line);
    canvas.drawLine(const Offset(18.8, 14.2), const Offset(19.8, 11.2), line);
    canvas.drawCircle(const Offset(12.2, 10.8), 1.55, eye);
    canvas.drawCircle(const Offset(19.8, 10.8), 1.55, eye);
    canvas.drawCircle(const Offset(12.6, 11), 0.55, fill);
    canvas.drawCircle(const Offset(20.2, 11), 0.55, fill);
  }

  void _paintCrabClaw(Canvas canvas, double direction, Paint fill) {
    canvas.save();
    canvas.translate(16 + direction * 10.2, 9.4);
    canvas.scale(direction, 1);

    final top = Path()
      ..moveTo(0, 1.2)
      ..quadraticBezierTo(2.1, -3.2, 5.4, -2.8)
      ..quadraticBezierTo(4.6, 0.1, 1.4, 1.8)
      ..close();
    final bottom = Path()
      ..moveTo(0.5, 2.2)
      ..quadraticBezierTo(3.4, 2.6, 4.8, 5.1)
      ..quadraticBezierTo(1.8, 5.6, -0.4, 3.2)
      ..close();

    canvas.drawPath(top, fill);
    canvas.drawPath(bottom, fill);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ReefLifeIconPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.color != color ||
        oldDelegate.accentColor != accentColor;
  }
}
