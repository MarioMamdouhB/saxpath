from app.services.persistence import list_attempt_history


def latest_relevant_attempt():
    attempts = list_attempt_history(limit=1)
    if not attempts:
        return None
    return attempts[0]


def build_adaptation_profile(*, weak_skill: str | None, latest_attempt):
    focus_skill = weak_skill or "tone"
    focus_block = "warm_up"
    source = "rule_based_v2"
    session_reason = "هذه الجلسة تعتمد على baseline المهارات الحالية."
    bpm_delta = 0
    note_wait_mode = False
    rhythm_wait_mode = True
    note_loop_target = 3
    rhythm_loop_target = 3
    record_loop_target = 1

    if latest_attempt is not None:
        source = "adaptive_rule_engine_v1"
        focus_block = str(latest_attempt.recommended_retry_block or "record_check")
        focus_skill = focus_skill_for_block(
            focus_block=focus_block,
            fallback_skill=weak_skill,
        )
        session_reason = session_reason_from_attempt(latest_attempt)

        if latest_attempt.retry_reason == "rhythm_needs_work":
            bpm_delta = -10
            rhythm_wait_mode = True
            rhythm_loop_target = 4
        elif latest_attempt.retry_reason == "pitch_needs_work":
            bpm_delta = -8
            note_wait_mode = True
            note_loop_target = 4
        elif latest_attempt.retry_reason == "recording_too_short":
            bpm_delta = -6
            record_loop_target = 2
        elif latest_attempt.retry_reason == "low_confidence_analysis":
            bpm_delta = -8
        elif (
            latest_attempt.pitch_accuracy >= 82
            and latest_attempt.rhythm_accuracy >= 78
            and latest_attempt.confidence_label == "high"
        ):
            bpm_delta = 6
            note_wait_mode = False
            rhythm_wait_mode = False
            note_loop_target = 2
            rhythm_loop_target = 2

    note_focus_hint = (
        "ابدأ بالنغمة المرجعية ثم كرر انتقالات الأصابع ببطء قبل الجملة."
        if focus_block != "note_fingering"
        else "هذه الجلسة تعيد بناء دقة النغمة: اسمع أولاً ثم طابق أول انتقال قبل أي سرعة."
    )
    rhythm_focus_hint = (
        "اسمع المرجع، عدّ داخلياً، ثم أعد نفس الجملة مرة واحدة فقط."
        if focus_block != "rhythm_call_response"
        else "هذه الجلسة تعطي أولوية للإيقاع: reference واحدة، ثم response واضحة على BPM أهدأ."
    )
    record_focus_hint = (
        "سجّل محاولة واحدة واضحة ثم راجع الحكم السريع قبل إعادة التمرين."
        if focus_block != "record_check"
        else "الأولوية الآن لمحاولة أنظف وأطول قليلاً حتى يظهر الأداء الحقيقي بدقة."
    )

    note_bpm = 58 + bpm_delta
    rhythm_bpm = 60 + bpm_delta
    record_bpm = 60 + bpm_delta
    warm_up_bpm = 52 if bpm_delta <= 0 else 56

    return {
        "focus_skill": focus_skill,
        "focus_block": focus_block,
        "source": source,
        "session_reason": session_reason,
        "warm_up_bpm": max(42, warm_up_bpm),
        "warm_up_reason": "تهيئة النفس قبل block التركيز الرئيسية.",
        "note_bpm": max(44, min(92, note_bpm)),
        "note_wait_mode": note_wait_mode,
        "note_loop_target": note_loop_target,
        "note_focus_hint": note_focus_hint,
        "note_reason": block_reason("note_fingering", focus_block, bpm_delta),
        "rhythm_bpm": max(44, min(96, rhythm_bpm)),
        "rhythm_wait_mode": rhythm_wait_mode,
        "rhythm_loop_target": rhythm_loop_target,
        "rhythm_focus_hint": rhythm_focus_hint,
        "rhythm_reason": block_reason("rhythm_call_response", focus_block, bpm_delta),
        "record_bpm": max(44, min(96, record_bpm)),
        "record_loop_target": record_loop_target,
        "record_focus_hint": record_focus_hint,
        "record_reason": block_reason("record_check", focus_block, bpm_delta),
    }


def focus_skill_for_block(*, focus_block: str, fallback_skill: str | None) -> str:
    mapping = {
        "warm_up": "tone",
        "note_fingering": "note_accuracy",
        "rhythm_call_response": "rhythm",
        "record_check": "breath",
    }
    return mapping.get(focus_block, fallback_skill or "tone")


def session_reason_from_attempt(latest_attempt) -> str:
    if latest_attempt.retry_reason == "rhythm_needs_work":
        return "آخر محاولة أظهرت أن الإيقاع أضعف من النغمة، لذلك خفضنا الـ BPM ورفعنا تكرار response loops."
    if latest_attempt.retry_reason == "pitch_needs_work":
        return "آخر محاولة أظهرت أن دقة النغمة تحتاج تثبيتاً أكبر، لذلك الجلسة تركز على matching قبل السرعة."
    if latest_attempt.retry_reason == "recording_too_short":
        return "آخر محاولة كانت قصيرة، لذلك سنثبت الجملة أولاً ثم نطلب تسجيل أوضح وأطول."
    if latest_attempt.retry_reason == "low_confidence_analysis":
        return "ثقة التحليل السابقة كانت منخفضة، لذلك الجلسة الحالية أهدأ وتركّز على الوضوح قبل التقييم."
    if (
        latest_attempt.pitch_accuracy >= 82
        and latest_attempt.rhythm_accuracy >= 78
        and latest_attempt.confidence_label == "high"
    ):
        return "آخر محاولة كانت مستقرة، لذلك رفعت الجلسة التحدي قليلاً وقللت الاعتماد على wait mode."
    return "تم ضبط الجلسة حسب أضعف block ظهرت في آخر محاولة."


def block_reason(block_id: str, focus_block: str, bpm_delta: int) -> str:
    if block_id == focus_block:
        return "هذه هي block التركيز الأساسية اليوم، لذلك زادت الـ loops ووضحت التعليمات."
    if bpm_delta < 0:
        return "تم تهدئة هذا الجزء ليدعم block الضعف الأساسية بدون استعجال."
    if bpm_delta > 0:
        return "تم رفع هذا الجزء قليلاً لأن آخر محاولة كانت أكثر ثباتاً."
    return "هذا الجزء يحتفظ بإعداد baseline الحالية."
