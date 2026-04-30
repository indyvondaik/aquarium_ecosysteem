import 'package:aquarium_ecosysteem/features/reef_balance/presentation/reef_balance_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the wide scene-first reef game', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ReefBalanceGame())),
    );

    expect(find.text('RIF IN BALANS'), findsOneWidget);
    expect(find.textContaining('Kies 2 keer'), findsOneWidget);
    expect(find.text('SUPERREGEL'), findsOneWidget);
    expect(find.text('WAT VALT JE OP?'), findsOneWidget);
    expect(find.text('MEER ALGEN'), findsOneWidget);
    expect(find.text('NOG 2 KEUZES'), findsOneWidget);
  });

  testWidgets('renders the compact reef layout', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ReefBalanceGame())),
    );

    expect(find.text('RIF IN BALANS'), findsOneWidget);
    expect(find.text('SUPERREGEL'), findsOneWidget);
    expect(find.text('Meer vissen'), findsOneWidget);
    expect(find.text('WAT VALT JE OP?'), findsOneWidget);
  });

  testWidgets('playing the correct route shows a restored reef', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ReefBalanceGame())),
    );

    await tester.tap(find.text('MEER ALGEN'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Je hebt het ecosysteem veranderd...'), findsOneWidget);
    expect(find.text('GOEDE HINT'), findsOneWidget);

    await tester.tap(find.text('MEER VISSEN'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Balans hersteld'), findsOneWidget);
    expect(
      find.text('Goed gezien. Groei en eten zijn weer in evenwicht.'),
      findsOneWidget,
    );
  });
}
