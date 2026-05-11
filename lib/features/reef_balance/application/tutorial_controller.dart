import 'package:flutter_riverpod/flutter_riverpod.dart';

final tutorialVisibleProvider =
    NotifierProvider<TutorialVisibilityController, bool>(
      TutorialVisibilityController.new,
    );

class TutorialVisibilityController extends Notifier<bool> {
  @override
  bool build() => true;

  void dismiss() => state = false;

  void show() => state = true;
}
