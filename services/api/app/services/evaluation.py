import re
from uuid import uuid4

from app.schemas.attempt import (
    AttemptAnalysis,
    AttemptCreateRequest,
    AttemptEvaluationResponse,
)
from app.schemas.recording import RecordingResponse
from app.services.audio_analysis import analyze_recording, build_deterministic_analysis

_DAY_PATTERN = re.compile(r"day_(\d+)")

_DAY_FOCUS = {
    1: "ثبّت نغمة G مع نبضة واضحة.",
    2: "حافظ على الفرق بين A و G من غير استعجال.",
    3: "انتبه إلى السكتة قبل الرجوع للنغمة التالية.",
    4: "قسّم الكروشين بالتساوي قبل زيادة السرعة.",
    5: "احرص على طول البلانش المنقوطة حتى نهاية العدة الثالثة.",
    6: "راجع انتقالات السلم كاملة من غير توتر في الأصابع.",
    7: "العِب الجملة كاملة كنَفَس واحد مع ختام هادئ.",
}


def submit_attempt(
    payload: AttemptCreateRequest,
    *,
    recording: RecordingResponse | None = None,
) -> AttemptEvaluationResponse:
    day_number = _extract_day_number(payload.exercise_id)
    duration_seconds = (
        recording.duration_seconds
        if recording is not None
        else payload.duration_seconds or 0
    )

    if recording is None:
        return submit_mock_attempt(payload)

    analysis = analyze_recording(recording=recording, exercise_id=payload.exercise_id)
    completion = _build_completion_score(
        duration_seconds=duration_seconds,
        analysis=analysis,
    )
    retry_reason = _build_retry_reason(
        duration_seconds=duration_seconds,
        completion=completion,
        analysis=analysis,
    )

    return AttemptEvaluationResponse(
        attempt_id=_build_attempt_id(
            day_number=day_number,
            duration_seconds=duration_seconds,
        ),
        pitch_accuracy=analysis.pitch_score,
        rhythm_accuracy=analysis.rhythm_score,
        completion=completion,
        feedback_ar=_build_feedback(
            day_number=day_number,
            duration_seconds=duration_seconds,
            pitch_accuracy=analysis.pitch_score,
            rhythm_accuracy=analysis.rhythm_score,
        ),
        next_recommendation=_build_recommendation(
            day_number=day_number,
            duration_seconds=duration_seconds,
            rhythm_accuracy=analysis.rhythm_score,
            pitch_accuracy=analysis.pitch_score,
        ),
        recording_id=recording.recording_id,
        retry_reason=retry_reason,
        analysis=analysis,
        metadata={
            "analysis_source": analysis.source,
            "confidence": analysis.confidence,
        },
    )


def submit_mock_attempt(payload: AttemptCreateRequest) -> AttemptEvaluationResponse:
    day_number = _extract_day_number(payload.exercise_id)
    duration_seconds = payload.duration_seconds or 0
    pitch_accuracy, rhythm_accuracy, completion = _build_scores(
        day_number=day_number,
        duration_seconds=duration_seconds,
    )
    analysis = build_deterministic_analysis(
        exercise_id=payload.exercise_id,
        duration_seconds=duration_seconds,
    )

    return AttemptEvaluationResponse(
        attempt_id=_build_attempt_id(
            day_number=day_number,
            duration_seconds=duration_seconds,
        ),
        pitch_accuracy=pitch_accuracy,
        rhythm_accuracy=rhythm_accuracy,
        completion=completion,
        feedback_ar=_build_feedback(
            day_number=day_number,
            duration_seconds=duration_seconds,
            pitch_accuracy=pitch_accuracy,
            rhythm_accuracy=rhythm_accuracy,
        ),
        next_recommendation=_build_recommendation(
            day_number=day_number,
            duration_seconds=duration_seconds,
            rhythm_accuracy=rhythm_accuracy,
            pitch_accuracy=pitch_accuracy,
        ),
        recording_id=payload.recording_id,
        retry_reason=_build_retry_reason(
            duration_seconds=duration_seconds,
            completion=completion,
            analysis=analysis,
        ),
        analysis=analysis,
        metadata={"analysis_source": analysis.source},
    )


def _extract_day_number(exercise_id: str) -> int:
    match = _DAY_PATTERN.search(exercise_id)
    if not match:
        return 1

    return max(1, int(match.group(1)))


def _build_scores(day_number: int, duration_seconds: int) -> tuple[int, int, int]:
    normalized_day = min(day_number, 7)

    if duration_seconds < 6:
        return (
            60 + normalized_day,
            54 + normalized_day,
            42 + normalized_day * 2,
        )

    if duration_seconds < 12:
        return (
            69 + normalized_day,
            64 + normalized_day,
            70 + normalized_day,
        )

    return (
        77 + normalized_day,
        72 + normalized_day,
        min(96, 86 + normalized_day),
    )


def _build_feedback(
    day_number: int,
    duration_seconds: int,
    pitch_accuracy: int,
    rhythm_accuracy: int,
) -> str:
    focus = _DAY_FOCUS.get(day_number, _DAY_FOCUS[1])

    if duration_seconds < 6:
        return (
            f"المحاولة كانت قصيرة، لكن البداية مبشرة. {focus} "
            "أعطِ نفسك وقتاً أطول في التسجيل القادم."
        )

    if pitch_accuracy >= 80 and rhythm_accuracy >= 75:
        return (
            f"أداء قوي لليوم {day_number}. النغمة والإيقاع متماسكين بشكل جيد. "
            f"{focus}"
        )

    return (
        f"المحاولة مستقرة إجمالاً، لكن ما زال هناك هامش لتحسين الدقة. {focus}"
    )


def _build_recommendation(
    day_number: int,
    duration_seconds: int,
    rhythm_accuracy: int,
    pitch_accuracy: int,
) -> str:
    if duration_seconds < 6:
        return "أعد التسجيل لمدة أطول مع عدّ واضح قبل أول نغمة."

    if pitch_accuracy < 70:
        return "افتح تمرين النغمة الطويلة مع Drone على النغمة الأساسية قبل إعادة المحاولة."

    if rhythm_accuracy < 70:
        return "خفّض السرعة إلى BPM 50 وركّز على العدّ الداخلي قبل العزف."

    if day_number >= 6:
        return "أعد الجملة كاملة مرتين متتاليتين قبل الانتقال لليوم التالي."

    return "ارفع السرعة تدريجياً بمقدار 5 BPM إذا حافظت على نفس الثبات."


def _build_completion_score(
    *,
    duration_seconds: int,
    analysis: AttemptAnalysis,
) -> int:
    duration_score = 100 if duration_seconds >= 6 else 45 + duration_seconds * 4
    weighted = (
        analysis.pitch_score * 0.42
        + analysis.rhythm_score * 0.42
        + duration_score * 0.16
    )
    return max(0, min(100, round(weighted)))


def _build_retry_reason(
    *,
    duration_seconds: int,
    completion: int,
    analysis: AttemptAnalysis,
) -> str | None:
    if duration_seconds < 6:
        return "recording_too_short"

    if analysis.confidence < 0.35:
        return "low_confidence_analysis"

    if analysis.pitch_score < 70:
        return "pitch_needs_work"

    if analysis.rhythm_score < 70:
        return "rhythm_needs_work"

    if completion < 70:
        return "completion_below_threshold"

    return None


def _build_attempt_id(*, day_number: int, duration_seconds: int) -> str:
    suffix = uuid4().hex[:8]
    return f"attempt_day_{day_number:02d}_{duration_seconds:03d}_{suffix}"
