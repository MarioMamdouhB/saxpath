from app.services.adaptive_engine import (
    block_reason,
    build_adaptation_profile,
    focus_skill_for_block,
    latest_relevant_attempt,
    session_reason_from_attempt,
)
from app.schemas.practice_session import PracticeBlock, PracticeSessionResponse
from app.services.mastery import (
    focus_hint_for_skill,
    focus_label_for_skill,
    get_skill_mastery,
    recommended_next_drill_for_skill,
)
from app.services.mock_content import get_daily_plan
from app.services.persistence import get_learner_progress


def get_today_practice_session(track: str = "beginner") -> PracticeSessionResponse:
    progress = get_learner_progress()
    return get_practice_session_for_day(progress.current_day_number, track=track)


def get_practice_session_for_day(
    day_number: int,
    *,
    track: str = "beginner",
) -> PracticeSessionResponse:
    day_plan = get_daily_plan(day_number)
    mastery = get_skill_mastery()
    weak_skill = mastery.weak_skill
    stage = _stage_for_day(day_number)
    latest_attempt = latest_relevant_attempt()
    adaptation = _build_adaptation_profile(
        weak_skill=weak_skill,
        latest_attempt=latest_attempt,
    )

    note_tasks = [
        task
        for task in day_plan.tasks
        if task.block_type in {"warm_up", "note_fingering"}
    ]
    rhythm_tasks = [
        task for task in day_plan.tasks if task.block_type == "rhythm_call_response"
    ]
    record_tasks = [
        task for task in day_plan.tasks if task.block_type == "record_check"
    ]

    note_task_ids = [task.id for task in note_tasks]
    rhythm_task_ids = [task.id for task in rhythm_tasks]
    record_task_ids = [task.id for task in record_tasks]

    blocks = [
        PracticeBlock(
            id="warm_up",
            title="Warm-up",
            block_type="warm_up",
            duration_minutes=2 + (1 if adaptation["focus_block"] == "warm_up" else 0),
            status="focus" if adaptation["focus_block"] == "warm_up" else "ready",
            focus_hint_ar=focus_hint_for_skill(
                "tone" if weak_skill is None else adaptation["focus_skill"]
            ),
            task_ids=note_task_ids[:1],
            skill_tags=["tone", "breath"],
            loop_target=3 if adaptation["focus_block"] == "warm_up" else 2,
            supports_wait_mode=False,
            visual_focus_notes=_block_focus_notes(note_tasks[:1]),
            recommended_bpm=adaptation["warm_up_bpm"],
            adaptation_reason_ar=adaptation["warm_up_reason"],
            recommended_next_drill_ar=recommended_next_drill_for_skill("tone"),
        ),
        PracticeBlock(
            id="note_fingering",
            title="Note / Fingering",
            block_type="note_fingering",
            duration_minutes=3 + (1 if adaptation["focus_block"] == "note_fingering" else 0),
            status="focus" if adaptation["focus_block"] == "note_fingering" else "ready",
            focus_hint_ar=adaptation["note_focus_hint"],
            task_ids=note_task_ids,
            skill_tags=["fingering", "note_accuracy"],
            loop_target=adaptation["note_loop_target"],
            supports_wait_mode=bool(adaptation["note_wait_mode"]),
            visual_focus_notes=_block_focus_notes(note_tasks),
            recommended_bpm=adaptation["note_bpm"],
            adaptation_reason_ar=adaptation["note_reason"],
            recommended_next_drill_ar=recommended_next_drill_for_skill("note_accuracy"),
        ),
        PracticeBlock(
            id="rhythm_call_response",
            title="Rhythm / Call-and-Response",
            block_type="rhythm_call_response",
            duration_minutes=3 + (1 if adaptation["focus_block"] == "rhythm_call_response" else 0),
            status=(
                "focus"
                if adaptation["focus_block"] == "rhythm_call_response"
                else "ready"
            ),
            focus_hint_ar=adaptation["rhythm_focus_hint"],
            task_ids=rhythm_task_ids,
            skill_tags=["rhythm", "response_imitation"],
            loop_target=adaptation["rhythm_loop_target"],
            supports_wait_mode=bool(adaptation["rhythm_wait_mode"]),
            visual_focus_notes=_block_focus_notes(rhythm_tasks),
            recommended_bpm=adaptation["rhythm_bpm"],
            adaptation_reason_ar=adaptation["rhythm_reason"],
            recommended_next_drill_ar=recommended_next_drill_for_skill("rhythm"),
        ),
        PracticeBlock(
            id="record_check",
            title="Record Check",
            block_type="record_check",
            duration_minutes=2 + (1 if adaptation["focus_block"] == "record_check" else 0),
            status="focus" if adaptation["focus_block"] == "record_check" else "ready",
            focus_hint_ar=adaptation["record_focus_hint"],
            task_ids=record_task_ids,
            skill_tags=["tone", "breath", "response_imitation"],
            loop_target=1 if adaptation["focus_block"] != "record_check" else 2,
            supports_wait_mode=False,
            visual_focus_notes=_block_focus_notes(record_tasks),
            recommended_bpm=adaptation["record_bpm"],
            adaptation_reason_ar=adaptation["record_reason"],
            recommended_next_drill_ar=recommended_next_drill_for_skill("response_imitation"),
        ),
    ]

    # Reorder blocks: Warm-up always first, then focus block, then the rest
    warm_up_block = [b for b in blocks if b.id == "warm_up"]
    focus_block_id = adaptation["focus_block"]

    if focus_block_id == "warm_up":
        # Warm-up is already focus, keep original order
        pass
    else:
        other_blocks = [b for b in blocks if b.id != "warm_up"]
        focus_block = [b for b in other_blocks if b.id == focus_block_id]
        remaining_blocks = [b for b in other_blocks if b.id != focus_block_id]
        blocks = warm_up_block + focus_block + remaining_blocks

    return PracticeSessionResponse(
        track=track,
        day_number=day_number,
        total_minutes=sum(block.duration_minutes for block in blocks),
        stage_id=stage["id"],
        stage_title=stage["title"],
        stage_subtitle_ar=stage["subtitle_ar"],
        stage_progress_percent=stage["progress_percent"],
        guided_path_label=stage["guided_path_label"],
        weak_skill=weak_skill,
        recommended_focus_ar=f"تركيز اليوم: {focus_label_for_skill(adaptation['focus_skill'])}",
        recommended_next_drill_ar=recommended_next_drill_for_skill(
            adaptation["focus_skill"]
        ),
        adaptation_reason_ar=adaptation["session_reason"],
        source=str(adaptation["source"]),
        blocks=blocks,
    )


def _block_focus_notes(tasks: list[object]) -> list[str]:
    notes: list[str] = []
    for task in tasks:
        expected_notes = getattr(task, "expected_notes", [])
        for note in expected_notes:
            if isinstance(note, str) and note and note not in notes:
                notes.append(note)
    return notes[:4]


def _stage_for_day(day_number: int) -> dict[str, object]:
    if day_number <= 3:
        return {
            "id": "first_sound",
            "title": "Stage 1: First Sound",
            "subtitle_ar": "تثبيت النفس والوضعية وأول انتقالات بين النغمات القريبة.",
            "progress_percent": min(100, round((day_number / 3) * 100)),
            "guided_path_label": "ابدأ بالصوت ثم ابنِ أول جملة قصيرة.",
        }
    if day_number <= 7:
        return {
            "id": "pulse_and_motion",
            "title": "Stage 2: Pulse & Motion",
            "subtitle_ar": "ربط النغمة بالإيقاع والحركة بين النغمات داخل phrase قصيرة.",
            "progress_percent": min(100, round(((day_number - 3) / 4) * 100)),
            "guided_path_label": "ثبّت النبض، ثم كرر الحركة نفسها بوضوح.",
        }
    if day_number <= 10:
        return {
            "id": "phrase_control",
            "title": "Stage 3: Phrase Control",
            "subtitle_ar": "السيطرة على الجملة القصيرة مع count-in وانتقالات أوضح.",
            "progress_percent": min(100, round(((day_number - 7) / 3) * 100)),
            "guided_path_label": "اسمع، استجب، ثم سجّل جملة أوضح.",
        }
    return {
        "id": "first_performance",
        "title": "Stage 4: First Performance",
        "subtitle_ar": "تجميع المهارات في أداء قصير متماسك وقابل للمراجعة.",
        "progress_percent": min(100, round(((day_number - 10) / 4) * 100)),
        "guided_path_label": "الهدف الآن ليس السرعة، بل جملة كاملة يمكن تقييمها.",
    }
def _build_adaptation_profile(*, weak_skill: str | None, latest_attempt):
    return build_adaptation_profile(
        weak_skill=weak_skill,
        latest_attempt=latest_attempt,
    )
