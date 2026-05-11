import 'dart:async';

import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_action.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reefControllerProvider = NotifierProvider<ReefController, ReefState>(
  ReefController.new,
);

class ReefController extends Notifier<ReefState> {
  static const Duration _animationDuration = Duration(milliseconds: 3800);

  Timer? _autoResetTimer;
  Timer? _animationTimer;

  @override
  ReefState build() {
    ref.onDispose(() {
      _autoResetTimer?.cancel();
      _animationTimer?.cancel();
    });

    return ReefState.initial.copyWith(bestScore: ReefState.initial.healthScore);
  }

  void apply(ReefAction action) {
    if (!state.actionEnabled(action)) {
      return;
    }

    _autoResetTimer?.cancel();
    _animationTimer?.cancel();

    final next = switch (state.phase) {
      ReefRoundPhase.intro => _applyFirstChoice(action),
      ReefRoundPhase.reaction => _applySecondChoice(action),
      ReefRoundPhase.result => state,
    };

    state = _withBestScore(next).copyWith(isAnimating: true);

    _animationTimer = Timer(_animationDuration, _finishAnimation);
  }

  void _finishAnimation() {
    state = state.copyWith(isAnimating: false);
    if (state.isResult) {
      _scheduleAutoReset();
    }
  }

  void rippleAt(double x, double y) {
    state = state.copyWith(
      eventId: state.eventId + 1,
      rippleX: x.clamp(0.05, 0.95).toDouble(),
      rippleY: y.clamp(0.08, 0.92).toDouble(),
      clearLastAction: true,
    );
  }

  void reset() {
    _autoResetTimer?.cancel();
    _animationTimer?.cancel();
    state = ReefState.initial.copyWith(
      bestScore: _bestScoreAfterReset(),
      eventId: state.eventId + 1,
    );
  }

  ReefState _applyFirstChoice(ReefAction action) {
    return switch (action) {
      ReefAction.algae => state.copyWith(
        algae: 84,
        fish: 46,
        crab: 6,
        actionsTaken: 1,
        eventId: state.eventId + 1,
        rippleX: 0.28,
        rippleY: 0.72,
        phase: ReefRoundPhase.reaction,
        resultVisible: false,
        firstAction: action,
        lastAction: action,
      ),
      ReefAction.fish => state.copyWith(
        algae: 22,
        fish: 80,
        crab: 6,
        actionsTaken: 1,
        eventId: state.eventId + 1,
        rippleX: 0.68,
        rippleY: 0.32,
        phase: ReefRoundPhase.reaction,
        resultVisible: false,
        firstAction: action,
        lastAction: action,
      ),
      ReefAction.crab => state.copyWith(
        algae: 20,
        fish: 50,
        crab: 34,
        actionsTaken: 1,
        eventId: state.eventId + 1,
        rippleX: 0.5,
        rippleY: 0.84,
        phase: ReefRoundPhase.reaction,
        resultVisible: false,
        firstAction: action,
        lastAction: action,
      ),
    };
  }

  ReefState _applySecondChoice(ReefAction action) {
    final firstAction = state.firstAction;
    if (firstAction == null) {
      return state;
    }

    final solved = switch (firstAction) {
      ReefAction.algae => action == ReefAction.fish,
      ReefAction.fish => action == ReefAction.algae,
      ReefAction.crab => action == ReefAction.algae,
    };

    final next = solved
        ? _successfulRound(firstAction, action)
        : _failedRound(firstAction, action);

    return next.copyWith(
      actionsTaken: 2,
      eventId: state.eventId + 1,
      phase: ReefRoundPhase.result,
      resultVisible: true,
      lastAction: action,
    );
  }

  ReefState _successfulRound(ReefAction firstAction, ReefAction action) {
    return switch (firstAction) {
      ReefAction.algae => state.copyWith(
        algae: 52,
        fish: 66,
        crab: 6,
        rippleX: 0.68,
        rippleY: 0.34,
      ),
      ReefAction.fish => state.copyWith(
        algae: 54,
        fish: 62,
        crab: 6,
        rippleX: 0.28,
        rippleY: 0.72,
      ),
      ReefAction.crab => state.copyWith(
        algae: 50,
        fish: 52,
        crab: 26,
        rippleX: 0.28,
        rippleY: 0.74,
      ),
    };
  }

  ReefState _failedRound(ReefAction firstAction, ReefAction action) {
    return switch ((firstAction, action)) {
      (ReefAction.algae, ReefAction.algae) => state.copyWith(
        algae: 96,
        fish: 46,
        crab: 6,
        rippleX: 0.26,
        rippleY: 0.7,
      ),
      (ReefAction.algae, ReefAction.crab) => state.copyWith(
        algae: 70,
        fish: 46,
        crab: 24,
        rippleX: 0.5,
        rippleY: 0.84,
      ),
      (ReefAction.fish, ReefAction.fish) => state.copyWith(
        algae: 10,
        fish: 92,
        crab: 6,
        rippleX: 0.7,
        rippleY: 0.32,
      ),
      (ReefAction.fish, ReefAction.crab) => state.copyWith(
        algae: 8,
        fish: 80,
        crab: 28,
        rippleX: 0.5,
        rippleY: 0.84,
      ),
      (ReefAction.crab, ReefAction.fish) => state.copyWith(
        algae: 12,
        fish: 74,
        crab: 34,
        rippleX: 0.68,
        rippleY: 0.34,
      ),
      (ReefAction.crab, ReefAction.crab) => state.copyWith(
        algae: 8,
        fish: 50,
        crab: 46,
        rippleX: 0.52,
        rippleY: 0.86,
      ),
      _ => state,
    };
  }

  ReefState _withBestScore(ReefState next) {
    final bestScore = next.healthScore > state.bestScore
        ? next.healthScore
        : state.bestScore;

    return next.copyWith(bestScore: bestScore);
  }

  int _bestScoreAfterReset() {
    final initialScore = ReefState.initial.healthScore;
    return state.bestScore > initialScore ? state.bestScore : initialScore;
  }

  void _scheduleAutoReset() {
    _autoResetTimer = Timer(const Duration(seconds: 9), reset);
  }
}
