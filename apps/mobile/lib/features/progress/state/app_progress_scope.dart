import 'package:flutter/material.dart';

import 'app_progress_controller.dart';

class AppProgressScope extends InheritedNotifier<AppProgressController> {
  const AppProgressScope({
    super.key,
    required AppProgressController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppProgressController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppProgressScope>();
    assert(scope != null, 'AppProgressScope is missing in the widget tree.');
    return scope!.notifier!;
  }
}
