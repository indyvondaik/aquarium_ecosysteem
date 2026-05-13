import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppScreen { start, ecosystem, info, quiz }

final appScreenProvider = NotifierProvider<AppScreenController, AppScreen>(
  AppScreenController.new,
);

class AppScreenController extends Notifier<AppScreen> {
  @override
  AppScreen build() => AppScreen.start;

  void goTo(AppScreen screen) {
    state = screen;
  }
}
