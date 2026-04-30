import 'package:flutter/material.dart';

typedef GameWidgetBuilder = Widget Function(BuildContext context);

class GameDefinition {
  const GameDefinition({
    required this.id,
    required this.title,
    required this.shortTitle,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });

  final String id;
  final String title;
  final String shortTitle;
  final String subtitle;
  final IconData icon;
  final GameWidgetBuilder builder;
}
