import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saxpath_mobile/app.dart';
import 'package:saxpath_mobile/data/models/learner_progress.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SaxPathApp starts with a real app shell', (tester) async {
    await tester.pumpWidget(
      SaxPathApp(apiClient: _StartupOnlyApiClient()),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('جارٍ فتح جلسة اليوم...'), findsOneWidget);
    expect(
      find.text('سنبدأ ببياناتك المحلية أولاً ثم نكمل المزامنة في الخلفية.'),
      findsOneWidget,
    );
  });
}

class _StartupOnlyApiClient extends SaxPathApiClient {
  @override
  Future<LearnerProgress> getLearnerProgress() async {
    return const LearnerProgress(
      completedDays: [],
      completedDaysCount: 0,
      currentDayNumber: 1,
      totalDays: 7,
    );
  }
}
