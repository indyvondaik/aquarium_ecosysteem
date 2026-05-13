import 'dart:math' as math;

import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_state.dart';
import 'package:flutter/widgets.dart';

/// Berekent waar vissen / krabben / algen zich op een gegeven tijdstip bevinden
/// en biedt hit-testing voor taps. De formules spiegelen exact wat
/// [_ReefScenePainter] in `reef_scene.dart` tekent — wijzig die twee samen.
class ReefSceneLayout {
  ReefSceneLayout({
    required this.fish,
    required this.crabs,
    required this.algae,
  });

  factory ReefSceneLayout.compute({
    required ReefState reef,
    required Size size,
    required double time,
  }) {
    final fish = <FishLayout>[];
    for (var index = 0; index < reef.fishCount; index++) {
      fish.add(FishLayout.compute(index: index, size: size, time: time));
    }

    final crabs = <CrabLayout>[];
    for (var index = 0; index < reef.crabCount; index++) {
      crabs.add(CrabLayout.compute(index: index, size: size, time: time));
    }

    final algae = <AlgaeLayout>[];
    final count = reef.algaePatchCount;
    for (var index = 0; index < count; index++) {
      algae.add(
        AlgaeLayout.compute(
          index: index,
          totalCount: count,
          algaeLevel: reef.algae,
          size: size,
          time: time,
        ),
      );
    }

    return ReefSceneLayout(fish: fish, crabs: crabs, algae: algae);
  }

  final List<FishLayout> fish;
  final List<CrabLayout> crabs;
  final List<AlgaeLayout> algae;

  /// Hit-test van topmost naar onderste. Volgorde komt overeen met visuele
  /// stapeling in de painter: krabben > algen-voor > vissen > algen-achter.
  ReefHit? hitTest(Offset position) {
    for (var i = crabs.length - 1; i >= 0; i--) {
      if (crabs[i].contains(position)) {
        return ReefHit.crab(crabs[i].index);
      }
    }
    for (var i = algae.length - 1; i >= 0; i--) {
      if (!algae[i].backLayer && algae[i].contains(position)) {
        return ReefHit.algae(algae[i].index);
      }
    }
    for (var i = fish.length - 1; i >= 0; i--) {
      if (fish[i].contains(position)) {
        return ReefHit.fish(fish[i].index);
      }
    }
    for (var i = algae.length - 1; i >= 0; i--) {
      if (algae[i].backLayer && algae[i].contains(position)) {
        return ReefHit.algae(algae[i].index);
      }
    }
    return null;
  }
}

class FishLayout {
  const FishLayout({
    required this.index,
    required this.center,
    required this.size,
    required this.facingRight,
    required this.seed,
    required this.speed,
  });

  factory FishLayout.compute({
    required int index,
    required Size size,
    required double time,
  }) {
    final seed = (index * 0.137) % 1;
    final speed = 0.18 + (index % 5) * 0.018;
    final facingRight = index.isOdd;
    final swim = (time * speed + seed) % 1.18;
    final x = facingRight
        ? size.width * (swim - 0.09)
        : size.width * (1.09 - swim);
    final y =
        size.height * (0.24 + (index % 6) * 0.068) +
        math.sin(time * math.pi * 2 + index) * size.height * 0.018;
    final fishSize = size.shortestSide * (0.026 + (index % 4) * 0.004);
    return FishLayout(
      index: index,
      center: Offset(x, y),
      size: fishSize,
      facingRight: facingRight,
      seed: seed,
      speed: speed,
    );
  }

  final int index;
  final Offset center;
  final double size;
  final bool facingRight;
  final double seed;
  final double speed;

  /// Vis-ovaal is ~2.35 wide × 1.18 high; iets royaler hit-radius voor kinderen.
  double get hitRadius => size * 1.8;

  bool contains(Offset point) {
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    return dx * dx + dy * dy <= hitRadius * hitRadius;
  }
}

class CrabLayout {
  const CrabLayout({
    required this.index,
    required this.center,
    required this.size,
  });

  factory CrabLayout.compute({
    required int index,
    required Size size,
    required double time,
  }) {
    final lane = index % 4;
    final walk = math.sin(time * math.pi * 2 + index) * size.width * 0.018;
    final x = size.width * (0.13 + index * 0.105) + walk;
    final y = size.height * (0.74 + lane * 0.024);
    return CrabLayout(
      index: index,
      center: Offset(x, y),
      size: size.shortestSide * 0.032,
    );
  }

  final int index;
  final Offset center;
  final double size;

  /// Krab-ovaal is ~2.05 wide × 1.2 high incl. claws. Royale hit-radius.
  double get hitRadius => size * 2.4;

  bool contains(Offset point) {
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    return dx * dx + dy * dy <= hitRadius * hitRadius;
  }
}

class AlgaeLayout {
  const AlgaeLayout({
    required this.index,
    required this.base,
    required this.tip,
    required this.seed,
    required this.height,
    required this.backLayer,
    required this.hitHalfWidth,
  });

  factory AlgaeLayout.compute({
    required int index,
    required int totalCount,
    required int algaeLevel,
    required Size size,
    required double time,
  }) {
    final seed = index * 1.618;
    final x = size.width * ((0.035 + index * 0.047) % 0.95);
    final baseY = size.height * (0.67 + (index % 7) * 0.027);
    final height = size.height * (0.075 + (algaeLevel / 100) * 0.1);
    final wiggle = math.sin(time * math.pi * 2.4 + seed) * size.width * 0.014;
    final tip = Offset(x + wiggle * 0.8, baseY - height);
    final isBack = index < totalCount ~/ 2;
    return AlgaeLayout(
      index: index,
      base: Offset(x, baseY),
      tip: tip,
      seed: seed,
      height: height,
      backLayer: isBack,
      hitHalfWidth: size.shortestSide * 0.024,
    );
  }

  final int index;
  final Offset base;
  final Offset tip;
  final double seed;
  final double height;
  final bool backLayer;
  final double hitHalfWidth;

  /// Hit-test op een (verticale) capsule rond de stengel: punt-naar-lijnsegment
  /// afstand kleiner dan [hitHalfWidth].
  bool contains(Offset point) {
    final ax = base.dx;
    final ay = base.dy;
    final bx = tip.dx;
    final by = tip.dy;
    final dx = bx - ax;
    final dy = by - ay;
    final lengthSquared = dx * dx + dy * dy;
    if (lengthSquared <= 0.0001) {
      final px = point.dx - ax;
      final py = point.dy - ay;
      return px * px + py * py <= hitHalfWidth * hitHalfWidth;
    }
    var t = ((point.dx - ax) * dx + (point.dy - ay) * dy) / lengthSquared;
    t = t.clamp(0.0, 1.0);
    final closestX = ax + t * dx;
    final closestY = ay + t * dy;
    final ex = point.dx - closestX;
    final ey = point.dy - closestY;
    return ex * ex + ey * ey <= hitHalfWidth * hitHalfWidth;
  }
}

sealed class ReefHit {
  const ReefHit();
  const factory ReefHit.fish(int index) = FishHit;
  const factory ReefHit.crab(int index) = CrabHit;
  const factory ReefHit.algae(int index) = AlgaeHit;
}

class FishHit extends ReefHit {
  const FishHit(this.index);
  final int index;
}

class CrabHit extends ReefHit {
  const CrabHit(this.index);
  final int index;
}

class AlgaeHit extends ReefHit {
  const AlgaeHit(this.index);
  final int index;
}

/// Levensloop van een aangetikte vis: dartt naar buiten beeld, blijft kort weg,
/// en zwemt dan terug in z'n normale baan.
class FishDartState {
  const FishDartState({
    required this.index,
    required this.startedAt,
    required this.startPosition,
    required this.startFacingRight,
    required this.exitTarget,
    required this.entryFrom,
  });

  final int index;
  final Duration startedAt;
  final Offset startPosition;
  final bool startFacingRight;
  final Offset exitTarget;
  final Offset entryFrom;

  static const Duration dartDuration = Duration(milliseconds: 700);
  static const Duration gapDuration = Duration(milliseconds: 500);
  static const Duration entryDuration = Duration(milliseconds: 800);
  static const Duration total = Duration(milliseconds: 2000);
}

/// Krab die met z'n scharen knipt. Korte pulse-animatie.
class CrabSnipState {
  const CrabSnipState({required this.index, required this.startedAt});

  final int index;
  final Duration startedAt;

  static const Duration duration = Duration(milliseconds: 900);
}

/// Algen-pol die kort uitbundig danst (extra wiggle-amplitude).
class AlgaeDanceState {
  const AlgaeDanceState({required this.index, required this.startedAt});

  final int index;
  final Duration startedAt;

  static const Duration duration = Duration(milliseconds: 1600);
}

/// Bundel van alle actieve entiteit-interacties die de painter moet honoreren.
class ReefSceneInteractions {
  const ReefSceneInteractions({
    this.fishDarts = const {},
    this.crabSnips = const {},
    this.algaeDances = const {},
  });

  static const ReefSceneInteractions empty = ReefSceneInteractions();

  final Map<int, FishDartState> fishDarts;
  final Map<int, CrabSnipState> crabSnips;
  final Map<int, AlgaeDanceState> algaeDances;

  bool get isEmpty =>
      fishDarts.isEmpty && crabSnips.isEmpty && algaeDances.isEmpty;
}
