import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saxpath_mobile/features/home/practice_setup_screen.dart';
import 'package:saxpath_mobile/features/progress/state/app_progress_controller.dart';
import 'package:saxpath_mobile/features/progress/state/app_progress_scope.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('practice setup loads saved preferences', (tester) async {
    SharedPreferences.setMockInitialValues({
      'profile.display_name': 'محمود',
      'profile.language': 'en',
      'profile.sax_type': 'tenorBb',
      'profile.experience': 'intermediate',
      'profile.subscription': 'beta',
    });

    await tester.pumpWidget(
      AppProgressScope(
        controller: AppProgressController(),
        child: const MaterialApp(home: PracticeSetupScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('الإعدادات والملف'), findsOneWidget);
    expect(find.text('محمود'), findsOneWidget);
    expect(find.text('Tenor Bb'), findsWidgets);

    await tester.dragUntilVisible(
      find.byKey(const ValueKey('subscription_beta')),
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('subscription_beta')), findsOneWidget);

    final betaChip = tester.widget<ChoiceChip>(
      find.descendant(
        of: find.byKey(const ValueKey('subscription_beta')),
        matching: find.byType(ChoiceChip),
      ),
    );
    expect(betaChip.selected, isTrue);
  });
}
