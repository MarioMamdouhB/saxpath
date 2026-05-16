from app.schemas.attempt import AttemptEvaluationResponse, AttemptHistoryEntry, TeacherReview


def build_teacher_review(
    *,
    exercise_id: str,
    day_number: int,
    evaluation: AttemptEvaluationResponse,
) -> TeacherReview:
    focus_points: list[str] = []

    if evaluation.recommended_retry_block == "warm_up":
        focus_points.append("ابدأ بـ long tone قصير قبل أي إعادة حتى يثبت النفس والهجوم.")
    if evaluation.recommended_retry_block == "note_fingering":
        focus_points.append("أعد انتقالات الأصابع ببطء ثم ارجع لنفس الجملة من غير زيادة سرعة.")
    if evaluation.recommended_retry_block == "rhythm_call_response":
        focus_points.append("استمع للمرجع مرة واحدة ثم رد بنفس العد الداخلي قبل التسجيل التالي.")
    if evaluation.recommended_retry_block == "record_check":
        focus_points.append("سجّل محاولة أوضح وأطول قليلاً بدل جمع محاولات قصيرة ومربكة.")

    if evaluation.pitch_accuracy >= 78:
        focus_points.append("ثبات النغمة الأساسي جيد ويمكن البناء عليه في الجملة التالية.")
    if evaluation.rhythm_accuracy < 70:
        focus_points.append("النبض الداخلي يحتاج وضوح أكثر من مجرد زيادة وقت التدريب.")

    if not focus_points:
        focus_points.append("استمر على نفس الـ BPM الحالي ثم ارفع السرعة فقط إذا حافظت على نفس الجودة.")

    if evaluation.completion >= 80:
        summary = (
            f"الـ AI coach يرى أن محاولة اليوم {day_number} متماسكة إجمالاً، "
            "وأن النقلة القادمة يجب أن تكون تثبيت نفس الجودة مع جملة أطول قليلاً."
        )
    else:
        summary = (
            f"الـ AI coach يرى أن محاولة اليوم {day_number} ما زالت في مرحلة التثبيت، "
            "والأولوية الآن هي إزالة نقطة الضعف الأساسية قبل الانتقال."
        )

    prompt = (
        f"لو أرسلت هذه المحاولة لمدرس، اطلب منه مراجعة {exercise_id} مع التركيز على "
        f"{_teacher_focus_label(evaluation)} وإعطاء drill واحد فقط لليوم التالي."
    )

    return TeacherReview(
        status="available",
        ai_summary_ar=summary,
        teacher_prompt_ar=prompt,
        queue_eta_ar="يمكن طلب مراجعة مدرس لاحقاً، والـ AI جهّز ملخصاً مختصراً للحالة الحالية.",
        focus_points_ar=focus_points[:3],
    )


def request_teacher_review(entry: AttemptHistoryEntry) -> TeacherReview:
    existing = entry.teacher_review
    if existing is None:
        return TeacherReview(
            status="requested",
            ai_summary_ar="تم تجهيز ملخص آلي أساسي لهذه المحاولة.",
            teacher_prompt_ar="راجع المحاولة وحدد drill واحد واضح لليوم التالي.",
            queue_eta_ar="تم إرسال الطلب، وسيظهر رد المدرس عندما يصبح متاحاً.",
            focus_points_ar=[
                "راجع ثبات النغمة والإيقاع قبل اقتراح أي زيادة سرعة.",
            ],
        )

    return existing.model_copy(
        update={
            "status": "requested",
            "queue_eta_ar": "تم إرسال الطلب، وسيظهر رد المدرس عندما يصبح متاحاً.",
        }
    )


def _teacher_focus_label(evaluation: AttemptEvaluationResponse) -> str:
    if evaluation.recommended_retry_block == "note_fingering":
        return "دقة النغمة وانتقالات الأصابع"
    if evaluation.recommended_retry_block == "rhythm_call_response":
        return "الإيقاع والاستجابة بعد السماع"
    if evaluation.recommended_retry_block == "warm_up":
        return "الثبات والتنفس وبداية النغمة"
    if evaluation.recommended_retry_block == "record_check":
        return "وضوح التسجيل وبناء المحاولة"
    return "التوازن العام بين النغمة والإيقاع"
