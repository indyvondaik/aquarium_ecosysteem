import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:aquarium_ecosysteem/features/info_aquarium/data/info_creature.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Toont het PNG-artwork van een organisme. Eén gedeelde sprite-sheet
/// (`aqaurium_dieren.png`) bevat alle 9 dieren — we cropen er per dier
/// het juiste stukje uit en passen een subtiele zweef-beweging toe.
class CreatureArtwork extends StatefulWidget {
  const CreatureArtwork({
    required this.creature,
    required this.time,
    super.key,
  });

  final InfoCreature creature;

  /// Looping 0..1 waarde — stuurt de bob/sway/hover/pulse.
  final double time;

  @override
  State<CreatureArtwork> createState() => _CreatureArtworkState();
}

class _CreatureArtworkState extends State<CreatureArtwork> {
  late final Future<ui.Image> _spriteFuture;

  @override
  void initState() {
    super.initState();
    _spriteFuture = _SpriteSheet.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: _spriteFuture,
      builder: (context, snapshot) {
        final image = snapshot.data;
        if (image == null) {
          // Eerste frame voor de sprite klaar is — niets tonen voorkomt flikker.
          return const SizedBox.expand();
        }
        final src = _SpriteSheet.rectFor(widget.creature.kind);

        return LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth.isFinite ? constraints.maxWidth : 0.0;
            final h = constraints.maxHeight.isFinite ? constraints.maxHeight : 0.0;
            if (w == 0 || h == 0) return const SizedBox.expand();

            final radius = math.min(w, h) / 2.0;
            final matrix = _motionMatrix(
              widget.creature.motion,
              widget.time * 2 * math.pi,
              radius,
              w,
              h,
            );

            return Transform(
              transform: matrix,
              child: CustomPaint(
                painter: _SpritePainter(image: image, src: src),
                size: Size(w, h),
              ),
            );
          },
        );
      },
    );
  }
}

class _SpritePainter extends CustomPainter {
  _SpritePainter({required this.image, required this.src});

  final ui.Image image;
  final Rect src;

  @override
  void paint(Canvas canvas, Size size) {
    final dst = _fitContain(src, Offset.zero & size);
    canvas.drawImageRect(
      image,
      src,
      dst,
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  Rect _fitContain(Rect src, Rect dst) {
    final srcRatio = src.width / src.height;
    final dstRatio = dst.width / dst.height;
    if (srcRatio > dstRatio) {
      final h = dst.width / srcRatio;
      return Rect.fromCenter(center: dst.center, width: dst.width, height: h);
    }
    final w = dst.height * srcRatio;
    return Rect.fromCenter(center: dst.center, width: w, height: dst.height);
  }

  @override
  bool shouldRepaint(_SpritePainter old) =>
      old.image != image || old.src != src;
}

Matrix4 _motionMatrix(
  CreatureMotion motion,
  double t,
  double r,
  double w,
  double h,
) {
  final cx = w / 2;
  final cy = h / 2;
  final m = Matrix4.identity();
  switch (motion) {
    case CreatureMotion.bob:
      m.translateByDouble(
        math.cos(t * 0.6) * r * 0.045,
        math.sin(t) * r * 0.08,
        0.0,
        1.0,
      );
      _rotateAround(m, cx, cy, math.sin(t * 0.7) * 0.05);
    case CreatureMotion.sway:
      _rotateAround(m, cx, cy + r * 0.85, math.sin(t) * 0.08);
      m.translateByDouble(math.sin(t * 0.8) * r * 0.02, 0.0, 0.0, 1.0);
    case CreatureMotion.hover:
      m.translateByDouble(
        math.sin(t * 0.9) * r * 0.10,
        math.cos(t * 1.3) * r * 0.06,
        0.0,
        1.0,
      );
      _rotateAround(m, cx, cy, math.cos(t * 0.9) * 0.07);
    case CreatureMotion.pulse:
      final scale = 1 + math.sin(t) * 0.05;
      _scaleAround(m, cx, cy, scale);
  }
  return m;
}

void _rotateAround(Matrix4 m, double cx, double cy, double theta) {
  m
    ..translateByDouble(cx, cy, 0.0, 1.0)
    ..rotateZ(theta)
    ..translateByDouble(-cx, -cy, 0.0, 1.0);
}

void _scaleAround(Matrix4 m, double cx, double cy, double scale) {
  m
    ..translateByDouble(cx, cy, 0.0, 1.0)
    ..scaleByDouble(scale, scale, 1.0, 1.0)
    ..translateByDouble(-cx, -cy, 0.0, 1.0);
}

class _SpriteSheet {
  _SpriteSheet._();

  static const _asset = 'lib/app/assets/animals/aqaurium_dieren.png';

  // De sprite is 1536×1024 met 5 kolommen × 2 rijen. Per dier kies ik een
  // strakkere bounding box dan de volledige cel zodat elk dier zijn tegel
  // mooi vult; de witte achtergrond wordt bij het laden naar transparant
  // gezet zodat eventuele overflow toch onzichtbaar blijft.
  static Rect rectFor(CreatureKind kind) {
    return switch (kind) {
      // Bovenste rij (y 0..512).
      CreatureKind.seahorse => const Rect.fromLTWH(40, 20, 220, 470),
      CreatureKind.fingerLeatherCoral =>
          const Rect.fromLTWH(320, 50, 295, 440),
      CreatureKind.cabbageLeatherCoral =>
          const Rect.fromLTWH(625, 60, 270, 430),
      CreatureKind.buttonPolyps =>
          const Rect.fromLTWH(945, 160, 270, 330),
      CreatureKind.coralDisc => const Rect.fromLTWH(1250, 150, 270, 350),
      // Onderste rij (y 512..1024).
      CreatureKind.foxface => const Rect.fromLTWH(15, 610, 290, 300),
      CreatureKind.copperband =>
          const Rect.fromLTWH(310, 540, 290, 380),
      CreatureKind.yellowWrasse =>
          const Rect.fromLTWH(625, 630, 270, 280),
      CreatureKind.hermitCrab =>
          const Rect.fromLTWH(920, 570, 290, 380),
    };
  }

  static Future<ui.Image>? _cached;

  static Future<ui.Image> load() {
    return _cached ??= _loadAndKey();
  }

  /// Laadt de sprite en zet (bijna-)witte pixels op alpha 0 zodat de
  /// dieren mooi op de donkere aquarium-achtergrond passen, ook als de
  /// PNG zelf een witte achtergrond heeft.
  static Future<ui.Image> _loadAndKey() async {
    final data = await rootBundle.load(_asset);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final original = frame.image;

    final bytes =
        await original.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (bytes == null) return original;

    final pixels = bytes.buffer.asUint8List();
    for (var i = 0; i < pixels.length; i += 4) {
      final r = pixels[i];
      final g = pixels[i + 1];
      final b = pixels[i + 2];
      // Drempel ruim genoeg om JPEG-achtige randjes mee te nemen, niet
      // zo ruim dat lichte body-delen verdwijnen.
      if (r >= 240 && g >= 240 && b >= 240) {
        pixels[i + 3] = 0;
      }
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      original.width,
      original.height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    final keyed = await completer.future;
    original.dispose();
    return keyed;
  }
}
