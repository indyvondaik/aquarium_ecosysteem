import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/application/reef_controller.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_state.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/widgets/reef_action_controls.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/widgets/reef_scene_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReefBalanceGame extends ConsumerWidget {
  const ReefBalanceGame({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reef = ref.watch(reefControllerProvider);
    final controller = ref.read(reefControllerProvider.notifier);

    return Scaffold(
      backgroundColor: ReefColors.navy,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          final edge = compact ? 10.0 : 18.0;
          final safe = MediaQuery.paddingOf(context);
          final controlsWidth = compact
              ? (constraints.maxWidth * 0.34).clamp(126.0, 158.0).toDouble()
              : (constraints.maxWidth * 0.18).clamp(218.0, 260.0).toDouble();
          final availableTitleWidth =
              constraints.maxWidth -
              controlsWidth -
              safe.left -
              safe.right -
              edge * 3;
          final titleWidth =
              (availableTitleWidth > 190
                      ? availableTitleWidth
                      : constraints.maxWidth -
                            safe.left -
                            safe.right -
                            edge * 2)
                  .clamp(180.0, compact ? 280.0 : 500.0)
                  .toDouble();

          return Stack(
            children: [
              Positioned.fill(
                child: ReefScenePanel(
                  reef: reef,
                  onTap: controller.rippleAt,
                  compact: compact,
                ),
              ),
              Positioned(
                top: safe.top + edge,
                left: safe.left + edge,
                width: titleWidth,
                child: _GameStatusOverlay(reef: reef, compact: compact),
              ),
              Positioned(
                top: safe.top + edge,
                right: safe.right + edge,
                child: SizedBox(
                  width: controlsWidth,
                  child: ReefActionControls(
                    reef: reef,
                    onApply: controller.apply,
                    onReset: controller.reset,
                    compact: compact,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GameStatusOverlay extends StatelessWidget {
  const _GameStatusOverlay({required this.reef, required this.compact});

  final ReefState reef;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final titleShadow = [
      Shadow(color: ReefColors.paper.withValues(alpha: 0.92), blurRadius: 8),
      Shadow(
        color: ReefColors.navy.withValues(alpha: 0.42),
        offset: const Offset(0, 2),
        blurRadius: 7,
      ),
    ];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      child: Column(
        key: ValueKey('${reef.phase}-${reef.headline}-${reef.prompt}'),
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'RIF IN BALANS',
              style: ReefTypography.display(
                size: compact ? 34 : 52,
                color: ReefColors.paper,
              ).copyWith(shadows: titleShadow),
            ),
          ),
          SizedBox(height: compact ? 5 : 8),
          Text(
            reef.headline,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style:
                ReefTypography.condensed(
                  size: compact ? 15 : 20,
                  color: ReefColors.paper,
                ).copyWith(
                  shadows: [
                    Shadow(
                      color: ReefColors.navy.withValues(alpha: 0.55),
                      offset: const Offset(0, 2),
                      blurRadius: 5,
                    ),
                  ],
                ),
          ),
          SizedBox(height: compact ? 4 : 6),
          Text(
            reef.prompt,
            maxLines: compact ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: ReefColors.paper,
              fontSize: compact ? 11 : 14,
              height: 1.2,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
              shadows: [
                Shadow(
                  color: ReefColors.navy.withValues(alpha: 0.78),
                  offset: const Offset(0, 1.4),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
