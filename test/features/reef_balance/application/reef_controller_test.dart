import 'package:aquarium_ecosysteem/features/reef_balance/application/reef_controller.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_action.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts with a fixed balanced round', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final reef = container.read(reefControllerProvider);

    expect(reef.algae, 52);
    expect(reef.fish, 50);
    expect(reef.crab, 6);
    expect(reef.phase, ReefRoundPhase.intro);
    expect(reef.choicesLeft, 2);
    expect(reef.bestScore, ReefState.initial.healthScore);
  });

  test('first choice moves the round into reaction mode', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(reefControllerProvider.notifier).apply(ReefAction.algae);
    final reef = container.read(reefControllerProvider);

    expect(reef.phase, ReefRoundPhase.reaction);
    expect(reef.firstAction, ReefAction.algae);
    expect(reef.lastAction, ReefAction.algae);
    expect(reef.actionsTaken, 1);
    expect(reef.algae, 84);
    expect(reef.highlightedAction, ReefAction.fish);
    expect(reef.observationTitle, 'Te veel algen');
  });

  test('correct second choice restores balance', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(reefControllerProvider.notifier);

    controller.apply(ReefAction.algae);
    controller.apply(ReefAction.fish);
    final reef = container.read(reefControllerProvider);

    expect(reef.phase, ReefRoundPhase.result);
    expect(reef.solvedRound, isTrue);
    expect(reef.actionsTaken, 2);
    expect(reef.lastAction, ReefAction.fish);
    expect(reef.resultVisible, isTrue);
    expect(reef.isBalanced, isTrue);
    expect(reef.headline, 'Balans hersteld');
  });

  test('wrong second choice stays out of balance and keeps the rule visible', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(reefControllerProvider.notifier);

    controller.apply(ReefAction.crab);
    controller.apply(ReefAction.fish);
    final reef = container.read(reefControllerProvider);

    expect(reef.phase, ReefRoundPhase.result);
    expect(reef.solvedRound, isFalse);
    expect(reef.idealCorrection, ReefAction.algae);
    expect(reef.isBalanced, isFalse);
    expect(
      reef.incorrectReason,
      'Hier moest je algen terugbrengen, want de krabben maakten het rif te schoon.',
    );
  });

  test('tapping the scene creates a ripple without changing the round', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(reefControllerProvider.notifier);

    controller.rippleAt(0.2, 0.9);
    final reef = container.read(reefControllerProvider);

    expect(reef.algae, ReefState.initial.algae);
    expect(reef.fish, ReefState.initial.fish);
    expect(reef.crab, ReefState.initial.crab);
    expect(reef.rippleX, 0.2);
    expect(reef.rippleY, 0.9);
    expect(reef.eventId, 1);
    expect(reef.phase, ReefRoundPhase.intro);
  });

  test('manual reset starts a fresh game', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(reefControllerProvider.notifier);

    controller.apply(ReefAction.fish);
    controller.reset();

    final reef = container.read(reefControllerProvider);
    expect(reef.algae, ReefState.initial.algae);
    expect(reef.fish, ReefState.initial.fish);
    expect(reef.crab, ReefState.initial.crab);
    expect(reef.phase, ReefRoundPhase.intro);
    expect(reef.actionsTaken, 0);
    expect(reef.firstAction, isNull);
    expect(reef.lastAction, isNull);
  });
}
