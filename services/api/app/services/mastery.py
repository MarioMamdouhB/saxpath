from datetime import datetime, timezone

from app.schemas.attempt import AttemptEvaluationResponse, MasteryDelta
from app.schemas.mastery import SkillMasteryEntry, SkillMasteryResponse
from app.services import persistence

_SKILL_ORDER = (
    "tone",
    "breath",
    "fingering",
    "note_accuracy",
    "rhythm",
    "response_imitation",
)

_DEFAULT_SCORES = {
    "tone": 38,
    "breath": 36,
    "fingering": 34,
    "note_accuracy": 35,
    "rhythm": 35,
    "response_imitation": 32,
}

_FOCUS_LABELS = {
    "tone": "ثبات الصوت",
    "breath": "النفَس والدعم",
    "fingering": "راحة الأصابع",
    "note_accuracy": "دقة النغمة",
    "rhythm": "ثبات الإيقاع",
    "response_imitation": "الاستجابة والتقليد",
}

_FOCUS_HINTS = {
    "tone": "ابدأ بـ long tone هادئ مع مدّ الهواء قبل أي جملة جديدة.",
    "breath": "خذ نفساً أهدأ وثبّت نهاية النغمة قبل التفكير في السرعة.",
    "fingering": "ارجع إلى انتقالات أصابع بطيئة قبل الجملة الكاملة.",
    "note_accuracy": "اسمع المرجع أولاً ثم طابق أول نغمة قبل المتابعة.",
    "rhythm": "عدّ داخلياً مع BPM أبطأ ثم كرر نفس الجملة مرة ثانية.",
    "response_imitation": "قسّم الجملة إلى ردود قصيرة ثم أعد توصيلها في النهاية.",
}


def get_skill_mastery() -> SkillMasteryResponse:
    state = _normalized_state(persistence.load_skill_mastery_state())
    recent_changes = _recent_mastery_changes()
    weak_skill = _weak_skill_for_state(state)
    updated_at = max(
        (
            entry["last_updated_at"]
            for entry in state.values()
            if isinstance(entry.get("last_updated_at"), str)
        ),
        default=None,
    )
    return SkillMasteryResponse(
        weak_skill=weak_skill,
        updated_at=updated_at,
        skills=[
            SkillMasteryEntry(
                skill=skill,
                score=int(state[skill]["score"]),
                status=str(state[skill]["status"]),
                focus_label=_FOCUS_LABELS[skill],
                last_updated_at=(
                    state[skill]["last_updated_at"]
                    if isinstance(state[skill]["last_updated_at"], str)
                    else None
                ),
                trend_label=_trend_label(recent_changes.get(skill, [])),
                recommended_next_drill_ar=_recommended_next_drill(
                    skill=skill,
                    score=int(state[skill]["score"]),
                    deltas=recent_changes.get(skill, []),
                ),
                recent_deltas=recent_changes.get(skill, []),
            )
            for skill in _SKILL_ORDER
        ],
    )


def apply_attempt_mastery(
    *,
    exercise_id: str,
    evaluation: AttemptEvaluationResponse,
) -> list[MasteryDelta]:
    state = _normalized_state(persistence.load_skill_mastery_state())
    targets = _target_scores(evaluation)
    emphasis_skill = _emphasis_skill(evaluation)
    updated_at = _now_iso()
    deltas: list[MasteryDelta] = []

    for skill in _SKILL_ORDER:
        previous_score = int(state[skill]["score"])
        target_score = targets[skill]
        weight = 0.42 if skill == emphasis_skill else 0.24
        change = round((target_score - previous_score) * weight)
        if change == 0 and target_score != previous_score:
            change = 1 if target_score > previous_score else -1
        change = max(-6, min(8, change))
        next_score = max(0, min(100, previous_score + change))

        state[skill] = {
            "score": next_score,
            "last_updated_at": updated_at,
            "focus_label": _FOCUS_LABELS[skill],
            "status": _status_for_score(next_score),
        }
        if next_score != previous_score:
            deltas.append(
                MasteryDelta(
                    skill=skill,
                    previous_score=previous_score,
                    new_score=next_score,
                    delta=next_score - previous_score,
                )
            )

    persistence.save_skill_mastery_state(state)
    return deltas


def focus_hint_for_skill(skill: str | None) -> str:
    if skill is None:
        return _FOCUS_HINTS["tone"]
    return _FOCUS_HINTS.get(skill, _FOCUS_HINTS["tone"])


def focus_label_for_skill(skill: str | None) -> str:
    if skill is None:
        return _FOCUS_LABELS["tone"]
    return _FOCUS_LABELS.get(skill, _FOCUS_LABELS["tone"])


def weak_skill_from_mastery(response: SkillMasteryResponse) -> str | None:
    return response.weak_skill


def recommended_next_drill_for_skill(skill: str | None) -> str:
    mastery = get_skill_mastery()
    for entry in mastery.skills:
        if entry.skill == skill:
            return entry.recommended_next_drill_ar
    return _recommended_next_drill(skill=skill or "tone", score=40, deltas=[])


def _target_scores(evaluation: AttemptEvaluationResponse) -> dict[str, int]:
    analysis = evaluation.analysis
    pitch = evaluation.pitch_accuracy
    rhythm = evaluation.rhythm_accuracy
    completion = evaluation.completion
    tone_score = analysis.tone_score if analysis is not None else pitch
    sustain_stability = (
        round(analysis.sustain_stability * 100) if analysis is not None else completion
    )

    return {
        "tone": _clamp_score(round((tone_score * 0.75) + (completion * 0.25))),
        "breath": _clamp_score(round((sustain_stability * 0.55) + (completion * 0.45))),
        "fingering": _clamp_score(round((pitch * 0.55) + (rhythm * 0.45))),
        "note_accuracy": _clamp_score(pitch),
        "rhythm": _clamp_score(rhythm),
        "response_imitation": _clamp_score(min(pitch, rhythm)),
    }


def _emphasis_skill(evaluation: AttemptEvaluationResponse) -> str:
    retry_reason = evaluation.retry_reason
    analysis = evaluation.analysis
    if retry_reason == "pitch_needs_work":
        return "note_accuracy"
    if retry_reason == "rhythm_needs_work":
        return "rhythm"
    if retry_reason == "recording_too_short":
        return "breath"
    if retry_reason == "low_confidence_analysis":
        return "tone"
    if analysis is not None and analysis.tone_score < 70:
        return "tone"
    return "response_imitation"


def _normalized_state(raw_state: dict[str, object]) -> dict[str, dict[str, object]]:
    normalized: dict[str, dict[str, object]] = {}
    for skill in _SKILL_ORDER:
        raw_entry = raw_state.get(skill)
        score = _DEFAULT_SCORES[skill]
        last_updated_at = None
        status = _status_for_score(score)
        if isinstance(raw_entry, dict):
            try:
                score = _clamp_score(int(raw_entry.get("score", score)))
            except (TypeError, ValueError):
                score = _DEFAULT_SCORES[skill]
            raw_updated_at = raw_entry.get("last_updated_at")
            if isinstance(raw_updated_at, str) and raw_updated_at:
                last_updated_at = raw_updated_at
            raw_status = raw_entry.get("status")
            if isinstance(raw_status, str) and raw_status:
                status = raw_status
            else:
                status = _status_for_score(score)

        normalized[skill] = {
            "score": score,
            "last_updated_at": last_updated_at,
            "status": status,
        }
    return normalized


def _weak_skill_for_state(state: dict[str, dict[str, object]]) -> str:
    return min(_SKILL_ORDER, key=lambda skill: int(state[skill]["score"]))


def _recent_mastery_changes() -> dict[str, list[int]]:
    attempts = persistence.list_attempt_history(limit=8)
    changes: dict[str, list[int]] = {}

    for attempt in attempts:
        for delta in attempt.mastery_delta:
            changes.setdefault(delta.skill, []).append(delta.delta)

    return {
        skill: values[:4]
        for skill, values in changes.items()
    }


def _trend_label(deltas: list[int]) -> str:
    if not deltas:
        return "waiting_for_signal"

    total = sum(deltas)
    if total >= 4:
        return "rising"
    if total <= -4:
        return "slipping"
    return "stable"


def _recommended_next_drill(*, skill: str, score: int, deltas: list[int]) -> str:
    trend = _trend_label(deltas)

    if skill == "rhythm":
        if score < 55 or trend == "slipping":
            return "Call-and-response بطيء على 50-56 BPM مع 3 loops نظيفة قبل التسجيل."
        return "ارفع الـ BPM تدريجياً 4 درجات بعد كل loop نظيفة مع الحفاظ على العد الداخلي."
    if skill == "tone":
        if score < 55 or trend == "slipping":
            return "Long tones قصيرة مع attack هادئ ونفس ثابت على نغمة واحدة."
        return "Phrase واحدة مع نفس أطول وثبات volume من البداية للنهاية."
    if skill == "breath":
        return "تمرين نفس 4 عدات دخول و4 عدات خروج قبل أول عزف ثم long tone واحدة."
    if skill == "fingering":
        return "انتقالات بطيئة بين نغمتين مع مراقبة الفينجرينج قبل زيادة السرعة."
    if skill == "note_accuracy":
        return "اسمع النغمة، غنّها، ثم طابقها على الساكس 3 مرات متتالية."
    if skill == "response_imitation":
        return "اسمع مرجعًا قصيرًا مرة، ثم رد عليه مباشرة بدون تشغيل مستمر."
    return "أعد أبطأ drill ناجحة أخيرًا ثم سجّل محاولة نظيفة واحدة."


def _status_for_score(score: int) -> str:
    if score < 45:
        return "starting"
    if score < 65:
        return "developing"
    if score < 82:
        return "steady"
    return "ready"


def _clamp_score(value: int) -> int:
    return max(0, min(100, value))


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()
