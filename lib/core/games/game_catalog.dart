import 'package:aquarium_ecosysteem/core/games/game_definition.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/reef_balance_game.dart';
import 'package:flutter/material.dart';

final ecosystemGameCatalog = <GameDefinition>[
  GameDefinition(
    id: 'reef_balance',
    title: 'Koraalrif Rangers',
    shortTitle: 'Rif',
    subtitle: 'Levend ecosysteem',
    icon: Icons.waves_rounded,
    builder: (_) => const ReefBalanceGame(),
  ),
];
