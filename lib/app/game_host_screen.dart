import 'package:aquarium_ecosysteem/core/games/game_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedGameIdProvider = NotifierProvider<SelectedGameController, String>(
  SelectedGameController.new,
);

class SelectedGameController extends Notifier<String> {
  @override
  String build() {
    return ecosystemGameCatalog.first.id;
  }

  void select(String id) {
    if (ecosystemGameCatalog.any((game) => game.id == id)) {
      state = id;
    }
  }
}

class GameHostScreen extends ConsumerWidget {
  const GameHostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGameId = ref.watch(selectedGameIdProvider);
    final selectedGame = ecosystemGameCatalog.firstWhere(
      (game) => game.id == selectedGameId,
      orElse: () => ecosystemGameCatalog.first,
    );

    if (ecosystemGameCatalog.length == 1) {
      return selectedGame.builder(context);
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: ecosystemGameCatalog.indexOf(selectedGame),
            onDestinationSelected: (index) {
              ref
                  .read(selectedGameIdProvider.notifier)
                  .select(ecosystemGameCatalog[index].id);
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
              for (final game in ecosystemGameCatalog)
                NavigationRailDestination(
                  icon: Icon(game.icon),
                  label: Text(game.shortTitle),
                ),
            ],
          ),
          Expanded(child: selectedGame.builder(context)),
        ],
      ),
    );
  }
}
