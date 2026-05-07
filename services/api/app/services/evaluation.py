from app.schemas.attempt import AttemptCreateRequest, AttemptEvaluationResponse


def submit_mock_attempt(_: AttemptCreateRequest) -> AttemptEvaluationResponse:
    return AttemptEvaluationResponse(
        attempt_id="attempt_mock_001",
        pitch_accuracy=78,
        rhythm_accuracy=64,
        completion=100,
        feedback_ar="أداء جيد. النغمات قريبة، لكن حاول تثبيت التوقيت مع الميترونوم.",
        next_recommendation="أعد التمرين على سرعة أبطأ BPM 50.",
    )
