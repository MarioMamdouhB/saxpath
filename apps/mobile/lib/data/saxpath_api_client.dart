import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import 'models/analytics_event.dart';
import 'models/attempt_evaluation.dart';
import 'models/attempt_history_entry.dart';
import 'models/daily_plan.dart';
import 'models/learner_progress.dart';
import 'models/lesson.dart';
import 'models/recording_upload.dart';

class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
  });

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class SaxPathApiClient {
  SaxPathApiClient({
    http.Client? client,
    Duration timeout = const Duration(seconds: 8),
  })  : _client = client ?? http.Client(),
        _timeout = timeout;

  final http.Client _client;
  final Duration _timeout;

  Future<DailyPlan> getTodayDailyPlan() async {
    final response = await _get('/api/v1/daily-plan/today');
    final payload = _decodeResponse(response);
    return DailyPlan.fromJson(payload as Map<String, dynamic>);
  }

  Future<DailyPlan> getDailyPlan(int dayNumber) async {
    final response = await _get('/api/v1/daily-plan/day/$dayNumber');
    final payload = _decodeResponse(response);
    return DailyPlan.fromJson(payload as Map<String, dynamic>);
  }

  Future<WeekOverview> getWeekOverview() async {
    final response = await _get('/api/v1/daily-plan/week');
    final payload = _decodeResponse(response);
    return WeekOverview.fromJson(payload as Map<String, dynamic>);
  }

  Future<List<Lesson>> getLessons({int? dayNumber}) async {
    final path = dayNumber == null
        ? '/api/v1/lessons'
        : '/api/v1/lessons?day_number=$dayNumber';
    final response = await _get(path);
    final payload = _decodeResponse(response) as List<dynamic>;

    return payload
        .map((lessonJson) => Lesson.fromJson(
              lessonJson as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<AttemptEvaluation> submitPracticeAttempt({
    required String exerciseId,
    required int durationSeconds,
    required String audioUrl,
    String? recordingId,
  }) async {
    final requestPayload = <String, dynamic>{
      'exercise_id': exerciseId,
      'duration_seconds': durationSeconds,
      'audio_url': audioUrl,
    };
    if (recordingId != null) {
      requestPayload['recording_id'] = recordingId;
    }

    final response = await _postJson(
      '/api/v1/attempts',
      requestPayload,
    );

    final responsePayload = _decodeResponse(response);
    return AttemptEvaluation.fromJson(responsePayload as Map<String, dynamic>);
  }

  Future<AttemptEvaluation> submitMockAttempt({
    required String exerciseId,
    required int durationSeconds,
    required String audioUrl,
  }) {
    return submitPracticeAttempt(
      exerciseId: exerciseId,
      durationSeconds: durationSeconds,
      audioUrl: audioUrl,
    );
  }

  Future<RecordingUpload> uploadRecording({
    required String filePath,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        _buildUri('/api/v1/recordings'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      final streamedResponse = await request.send().timeout(_timeout);
      final response =
          await http.Response.fromStream(streamedResponse).timeout(_timeout);
      final payload = _decodeResponse(response);
      return RecordingUpload.fromJson(payload as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        'تعذر رفع التسجيل الآن. تحقق من الاتصال ثم حاول مرة أخرى.',
      );
    }
  }

  Future<List<AttemptHistoryEntry>> getAttemptHistory({int limit = 5}) async {
    final response = await _get('/api/v1/attempts/history?limit=$limit');
    final payload = _decodeResponse(response) as List<dynamic>;

    return payload
        .map((entryJson) => AttemptHistoryEntry.fromJson(
              entryJson as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<LearnerProgress> getLearnerProgress() async {
    final response = await _get('/api/v1/progress');
    final payload = _decodeResponse(response);
    return LearnerProgress.fromJson(payload as Map<String, dynamic>);
  }

  Future<LearnerProgress> completeDay(int dayNumber) async {
    final response = await _post('/api/v1/progress/day/$dayNumber/complete');
    final payload = _decodeResponse(response);
    return LearnerProgress.fromJson(payload as Map<String, dynamic>);
  }

  Future<LearnerProgress> resetProgress() async {
    final response = await _post('/api/v1/progress/reset');
    final payload = _decodeResponse(response);
    return LearnerProgress.fromJson(payload as Map<String, dynamic>);
  }

  Future<void> trackEvent({
    required String eventName,
    int? dayNumber,
    String? taskId,
    String? attemptId,
    Map<String, dynamic> metadata = const {},
  }) async {
    final response = await _postJson(
      '/api/v1/analytics/events',
      {
        'event_name': eventName,
        'day_number': dayNumber,
        'task_id': taskId,
        'attempt_id': attemptId,
        'metadata': _compactMetadata(metadata),
      },
    );
    _decodeResponse(response);
  }

  Future<List<AnalyticsEvent>> getAnalyticsEvents({int limit = 10}) async {
    final response = await _get('/api/v1/analytics/events?limit=$limit');
    final payload = _decodeResponse(response) as List<dynamic>;

    return payload
        .map((eventJson) => AnalyticsEvent.fromJson(
              eventJson as Map<String, dynamic>,
            ))
        .toList();
  }

  Uri _buildUri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<http.Response> _get(String path) {
    return _withTimeout(() => _client.get(_buildUri(path)));
  }

  Future<http.Response> _post(String path) {
    return _withTimeout(() => _client.post(_buildUri(path)));
  }

  Future<http.Response> _postJson(String path, Map<String, dynamic> payload) {
    return _withTimeout(
      () => _client.post(
        _buildUri(path),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ),
    );
  }

  Future<http.Response> _withTimeout(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request().timeout(_timeout);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        'تعذر الوصول إلى الخادم الآن. تحقق من الاتصال ثم حاول مرة أخرى.',
      );
    }
  }

  dynamic _decodeResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'تعذر الوصول إلى الخادم الآن. حاول مرة أخرى.',
        statusCode: response.statusCode,
      );
    }

    if (response.body.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(response.body);
    } catch (_) {
      throw const ApiException('استجابة الخادم غير مفهومة حالياً.');
    }
  }

  Map<String, dynamic> _compactMetadata(Map<String, dynamic> metadata) {
    final compacted = <String, dynamic>{};
    for (final entry in metadata.entries) {
      if (entry.value != null) {
        compacted[entry.key] = entry.value;
      }
    }
    return compacted;
  }
}
