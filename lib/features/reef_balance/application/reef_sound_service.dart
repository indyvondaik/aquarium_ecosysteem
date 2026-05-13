import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ReefSoundEffect { bubblePop, sparkle, sandPuff }

final reefMutedProvider = NotifierProvider<ReefMutedController, bool>(
  ReefMutedController.new,
);

class ReefMutedController extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final reefSoundServiceProvider = Provider<ReefSoundService>((ref) {
  final service = ReefSoundService(ref);
  ref.onDispose(service.dispose);
  return service;
});

class ReefSoundService {
  ReefSoundService(this._ref) {
    AudioCache.instance.prefix = 'lib/app/assets/';
    _pools = {
      ReefSoundEffect.bubblePop: _createPool(
        'sound_effects/bubble-pop.mp3',
        maxPlayers: 4,
      ),
      ReefSoundEffect.sparkle: _createPool(
        'sound_effects/sparkle.mp3',
        maxPlayers: 2,
      ),
      ReefSoundEffect.sandPuff: _createPool(
        'sound_effects/sand-puff.mp3',
        maxPlayers: 2,
      ),
    };
  }

  final Ref _ref;
  late final Map<ReefSoundEffect, Future<AudioPool>> _pools;

  Future<AudioPool> _createPool(String path, {required int maxPlayers}) {
    return AudioPool.createFromAsset(path: path, maxPlayers: maxPlayers);
  }

  void play(ReefSoundEffect effect, {double volume = 0.7}) {
    if (_ref.read(reefMutedProvider)) {
      return;
    }
    switch (effect) {
      case ReefSoundEffect.bubblePop:
        HapticFeedback.lightImpact();
      case ReefSoundEffect.sparkle:
        HapticFeedback.selectionClick();
      case ReefSoundEffect.sandPuff:
        HapticFeedback.mediumImpact();
    }
    final pool = _pools[effect];
    if (pool == null) {
      return;
    }
    pool.then((p) => p.start(volume: volume)).onError(
      (Object error, StackTrace _) {
        debugPrint('ReefSoundService: failed to play $effect ($error)');
        return () async {};
      },
    );
  }

  Future<void> dispose() async {
    for (final pool in _pools.values) {
      try {
        final p = await pool;
        await p.dispose();
      } catch (_) {
        // Pool faalde te laden — niets om weg te gooien
      }
    }
  }
}
