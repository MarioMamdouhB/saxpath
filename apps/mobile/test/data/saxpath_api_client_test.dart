import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:saxpath_mobile/data/saxpath_api_client.dart';

void main() {
  test('trackEvent drops null metadata values before posting', () async {
    late Map<String, dynamic> requestBody;
    late Uri requestUri;

    final client = SaxPathApiClient(
      client: MockClient((request) async {
        requestUri = request.url;
        requestBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'event_id': 'evt_123',
            'event_name': 'practice_finish',
            'day_number': 2,
            'task_id': 'task_day_02_practice_aagg',
            'attempt_id': 'attempt_day_02_001',
            'metadata': requestBody['metadata'],
            'created_at': '2026-05-10T01:00:00Z',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    await client.trackEvent(
      eventName: 'practice_finish',
      dayNumber: 2,
      taskId: 'task_day_02_practice_aagg',
      attemptId: 'attempt_day_02_001',
      metadata: {
        'duration_seconds': 8,
        'completion': 72,
        'recording_id': null,
        'analysis_source': 'deterministic_mock',
        'retry_reason': null,
      },
    );

    expect(
      requestBody,
      {
        'event_name': 'practice_finish',
        'day_number': 2,
        'task_id': 'task_day_02_practice_aagg',
        'attempt_id': 'attempt_day_02_001',
        'metadata': {
          'duration_seconds': 8,
          'completion': 72,
          'analysis_source': 'deterministic_mock',
        },
      },
    );
    expect(requestUri.path, '/api/v1/analytics/events');
  });
}
