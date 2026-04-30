import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/application/reef_controller.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_state.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/widgets/reef_action_controls.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/widgets/reef_fact_badge.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/widgets/reef_info_panel.dart';
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
      backgroundColor: const Color(0xFF94D6E9),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE9FBFF), Color(0xFFC0F0FA), Color(0xFF8BD8E4)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(child: _OceanBackdrop()),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 860;
                  final padding = compact ? 12.0 : 20.0;

                  return Padding(
                    padding: EdgeInsets.all(padding),
                    child: compact
                        ? _CompactReefLayout(
                            reef: reef,
                            onApply: controller.apply,
                            onReset: controller.reset,
                            onSceneTap: controller.rippleAt,
                          )
                        : _WideReefLayout(
                            reef: reef,
                            onApply: controller.apply,
                            onReset: controller.reset,
                            onSceneTap: controller.rippleAt,
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WideReefLayout extends StatelessWidget {
  const _WideReefLayout({
    required this.reef,
    required this.onApply,
    required this.onReset,
    required this.onSceneTap,
  });

  final ReefState reef;
  final ReefActionCallback onApply;
  final VoidCallback onReset;
  final ReefSceneTapCallback onSceneTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dockWidth = (constraints.maxWidth * 0.3)
            .clamp(340, 392)
            .toDouble();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ReefHeader(reef: reef, compact: false),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ReefScenePanel(
                      reef: reef,
                      onTap: onSceneTap,
                      compact: false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: dockWidth,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ReefActionControls(
                            reef: reef,
                            onApply: onApply,
                            onReset: onReset,
                            compact: false,
                          ),
                          const SizedBox(height: 14),
                          ReefInfoPanel(reef: reef, compact: false),
                          const SizedBox(height: 14),
                          ReefFactBadge(reef: reef, compact: false),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CompactReefLayout extends StatelessWidget {
  const _CompactReefLayout({
    required this.reef,
    required this.onApply,
    required this.onReset,
    required this.onSceneTap,
  });

  final ReefState reef;
  final ReefActionCallback onApply;
  final VoidCallback onReset;
  final ReefSceneTapCallback onSceneTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ReefHeader(reef: reef, compact: true),
        const SizedBox(height: 10),
        Expanded(
          flex: 8,
          child: ReefScenePanel(reef: reef, onTap: onSceneTap, compact: true),
        ),
        const SizedBox(height: 10),
        Flexible(
          flex: 5,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReefInfoPanel(reef: reef, compact: true),
                const SizedBox(height: 10),
                ReefFactBadge(reef: reef, compact: true),
                const SizedBox(height: 10),
                ReefActionControls(
                  reef: reef,
                  onApply: onApply,
                  onReset: onReset,
                  compact: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReefHeader extends StatelessWidget {
  const _ReefHeader({required this.reef, required this.compact});

  final ReefState reef;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = switch (reef.phase) {
      ReefRoundPhase.intro => ReefColors.seaFoam,
      ReefRoundPhase.reaction => ReefColors.reefGold,
      ReefRoundPhase.result =>
        reef.solvedRound ? ReefColors.brightAlgae : ReefColors.softCoral,
    };

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ReefColors.paper.withValues(alpha: 0.97),
            ReefColors.seaFoam.withValues(alpha: 0.94),
          ],
        ),
        border: Border.all(color: ReefColors.line, width: 2),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220E3557),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        compact ? 16 : 24,
        compact ? 14 : 18,
        compact ? 16 : 24,
        compact ? 14 : 18,
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HeaderTitle(compact: true),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeaderBadge(
                      text: 'Ronde ${reef.roundNumber}',
                      color: accent,
                    ),
                    _HeaderBadge(text: reef.stepLabel, color: ReefColors.water),
                    _HeaderBadge(
                      text: reef.sceneStatus,
                      color: ReefColors.paper,
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                const Expanded(child: _HeaderTitle(compact: false)),
                const SizedBox(width: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.end,
                  children: [
                    _HeaderBadge(
                      text: 'Ronde ${reef.roundNumber}',
                      color: accent,
                    ),
                    _HeaderBadge(text: reef.stepLabel, color: ReefColors.water),
                    _HeaderBadge(
                      text: reef.sceneStatus,
                      color: ReefColors.paper,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'RIF IN BALANS',
            style: ReefTypography.display(size: compact ? 42 : 58),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Kies 2 keer. Eerst verstoren, daarna het rif redden.',
          style: TextStyle(
            color: ReefColors.navy.withValues(alpha: 0.9),
            fontSize: compact ? 13 : 16,
            height: 1.2,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        border: Border.all(color: ReefColors.line, width: 1.6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text.toUpperCase(),
        style: ReefTypography.condensed(size: 13, color: ReefColors.ink),
      ),
    );
  }
}

class _OceanBackdrop extends StatelessWidget {
  const _OceanBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: const [
          _BackdropBubble(
            alignment: Alignment(-0.95, -0.82),
            size: 180,
            color: Color(0x44FFFFFF),
          ),
          _BackdropBubble(
            alignment: Alignment(0.92, -0.74),
            size: 220,
            color: Color(0x38B7F7FF),
          ),
          _BackdropBubble(
            alignment: Alignment(-0.72, 0.18),
            size: 110,
            color: Color(0x30FFFFFF),
          ),
          _BackdropBubble(
            alignment: Alignment(0.88, 0.24),
            size: 140,
            color: Color(0x2CE8FBFF),
          ),
          _BackdropBubble(
            alignment: Alignment(-0.38, 0.88),
            size: 240,
            color: Color(0x24FFF5BD),
          ),
          _BackdropBubble(
            alignment: Alignment(0.22, 0.82),
            size: 170,
            color: Color(0x1FFFFFFF),
          ),
        ],
      ),
    );
  }
}

class _BackdropBubble extends StatelessWidget {
  const _BackdropBubble({
    required this.alignment,
    required this.size,
    required this.color,
  });

  final Alignment alignment;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
