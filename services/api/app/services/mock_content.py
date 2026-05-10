import re

from app.schemas.daily_plan import (
    DailyPlanResponse,
    DailyTask,
    WeekDaySummary,
    WeekOverviewResponse,
)
from app.schemas.lesson import LessonResponse

# This week-one dataset stays product-authored for legal/simplicity reasons,
# but its ordering and beginner-skill progression are informed by official
# public curricula and studio handbooks summarized in docs/CURRICULUM_SOURCES.md.

_CURRENT_DAY_NUMBER = 1
_TOTAL_DAYS = 30
_USER_NAME = "أحمد"

_WEEK_CURRICULUM = {
    1: {
        "progress_percent": 0,
        "tasks": [
            {
                "id": "task_day_01_note_g",
                "type": "note_lesson",
                "title": "نغمة G / صول",
                "duration_minutes": 5,
                "status": "next",
            },
            {
                "id": "task_day_01_rhythm_quarter",
                "type": "rhythm_lesson",
                "title": "Quarter Note / نوار",
                "duration_minutes": 7,
                "status": "locked",
            },
            {
                "id": "task_day_01_practice_ggaa",
                "type": "practice",
                "title": "تمرين G G A A",
                "duration_minutes": 10,
                "status": "locked",
            },
            {
                "id": "task_day_01_recording",
                "type": "recording_attempt",
                "title": "تسجيل المحاولة",
                "duration_minutes": 3,
                "status": "locked",
            },
        ],
        "lessons": [
            {
                "id": "lesson_day_01_note_g",
                "type": "note_lesson",
                "title": "نغمة G / صول",
                "note": "G",
                "arabic_name": "صول",
                "description_ar": "ابدأ بوضعية مستقرة للفم واليدين ثم استمع إلى نغمة G قبل العزف لتثبيت الصوت من أول يوم.",
                "duration_minutes": 5,
            },
            {
                "id": "lesson_day_01_rhythm_quarter",
                "type": "rhythm_lesson",
                "title": "Quarter Note / نوار",
                "rhythm": "quarter_note",
                "description_ar": "ابدأ العد الداخلي على نوار واحد لكل نبضة حتى يرتبط الصوت الأول بإحساس ثابت للميزان.",
                "duration_minutes": 7,
            },
        ],
    },
    2: {
        "progress_percent": 0,
        "tasks": [
            {
                "id": "task_day_02_note_a",
                "type": "note_lesson",
                "title": "نغمة A / لا",
                "duration_minutes": 6,
                "status": "next",
            },
            {
                "id": "task_day_02_rhythm_half",
                "type": "rhythm_lesson",
                "title": "Half Note / بلانش",
                "duration_minutes": 6,
                "status": "locked",
            },
            {
                "id": "task_day_02_practice_aagg",
                "type": "practice",
                "title": "تمرين A A G G",
                "duration_minutes": 10,
                "status": "locked",
            },
            {
                "id": "task_day_02_recording",
                "type": "recording_attempt",
                "title": "تسجيل محاولة اليوم الثاني",
                "duration_minutes": 3,
                "status": "locked",
            },
        ],
        "lessons": [
            {
                "id": "lesson_day_02_note_a",
                "type": "note_lesson",
                "title": "نغمة A / لا",
                "note": "A",
                "arabic_name": "لا",
                "description_ar": "أضف نغمة A مع نفس دعم الهواء وطول النفس حتى تتعلم الانتقال القريب بين G و A من غير توتر.",
                "duration_minutes": 6,
            },
            {
                "id": "lesson_day_02_rhythm_half",
                "type": "rhythm_lesson",
                "title": "Half Note / بلانش",
                "rhythm": "half_note",
                "description_ar": "البلانش يساوي عدتين متصلتين، لذلك ركز على ثبات النفس وجودة النغمة حتى آخر العدة.",
                "duration_minutes": 6,
            },
        ],
    },
    3: {
        "progress_percent": 0,
        "tasks": [
            {
                "id": "task_day_03_note_b",
                "type": "note_lesson",
                "title": "نغمة B / سي",
                "duration_minutes": 6,
                "status": "next",
            },
            {
                "id": "task_day_03_rhythm_rest",
                "type": "rhythm_lesson",
                "title": "Quarter Rest / سكتة نوار",
                "duration_minutes": 6,
                "status": "locked",
            },
            {
                "id": "task_day_03_practice_gaba",
                "type": "practice",
                "title": "تمرين G A B A",
                "duration_minutes": 10,
                "status": "locked",
            },
            {
                "id": "task_day_03_recording",
                "type": "recording_attempt",
                "title": "تسجيل مع السكتة",
                "duration_minutes": 4,
                "status": "locked",
            },
        ],
        "lessons": [
            {
                "id": "lesson_day_03_note_b",
                "type": "note_lesson",
                "title": "نغمة B / سي",
                "note": "B",
                "arabic_name": "سي",
                "description_ar": "أضف نغمة B مع بداية واضحة باللسان حتى تربط القراءة البسيطة بالهجوم الصوتي النظيف.",
                "duration_minutes": 6,
            },
            {
                "id": "lesson_day_03_rhythm_rest",
                "type": "rhythm_lesson",
                "title": "Quarter Rest / سكتة نوار",
                "rhythm": "quarter_rest",
                "description_ar": "تعلّم أن السكتة جزء من الجملة، واترك فراغ النوار كاملاً من غير استعجال قبل الدخول التالي.",
                "duration_minutes": 6,
            },
        ],
    },
    4: {
        "progress_percent": 0,
        "tasks": [
            {
                "id": "task_day_04_note_c",
                "type": "note_lesson",
                "title": "نغمة C / دو",
                "duration_minutes": 6,
                "status": "next",
            },
            {
                "id": "task_day_04_rhythm_eighth",
                "type": "rhythm_lesson",
                "title": "Eighth Notes / كروشين",
                "duration_minutes": 7,
                "status": "locked",
            },
            {
                "id": "task_day_04_practice_gabc",
                "type": "practice",
                "title": "تمرين G A B C",
                "duration_minutes": 10,
                "status": "locked",
            },
            {
                "id": "task_day_04_recording",
                "type": "recording_attempt",
                "title": "تسجيل السرعة الجديدة",
                "duration_minutes": 4,
                "status": "locked",
            },
        ],
        "lessons": [
            {
                "id": "lesson_day_04_note_c",
                "type": "note_lesson",
                "title": "نغمة C / دو",
                "note": "C",
                "arabic_name": "دو",
                "description_ar": "اربط انتقال B إلى C بسلاسة مع بقاء النغمة متزنة، لأن السرعة لا تأتي قبل ثبات الإصبع والصوت.",
                "duration_minutes": 6,
            },
            {
                "id": "lesson_day_04_rhythm_eighth",
                "type": "rhythm_lesson",
                "title": "Eighth Notes / كروشين",
                "rhythm": "eighth_notes",
                "description_ar": "الكروشين يقسم النبضة إلى نصفين، فاحرص أن يبقى كل جزء مسموعاً وواضحاً لا مجرد سرعة.",
                "duration_minutes": 7,
            },
        ],
    },
    5: {
        "progress_percent": 0,
        "tasks": [
            {
                "id": "task_day_05_note_d",
                "type": "note_lesson",
                "title": "نغمة D / ري",
                "duration_minutes": 6,
                "status": "next",
            },
            {
                "id": "task_day_05_rhythm_dotted_half",
                "type": "rhythm_lesson",
                "title": "Dotted Half / بلانش منقوطة",
                "duration_minutes": 7,
                "status": "locked",
            },
            {
                "id": "task_day_05_practice_dcba",
                "type": "practice",
                "title": "تمرين D C B A",
                "duration_minutes": 10,
                "status": "locked",
            },
            {
                "id": "task_day_05_recording",
                "type": "recording_attempt",
                "title": "تسجيل النزول السلمي",
                "duration_minutes": 4,
                "status": "locked",
            },
        ],
        "lessons": [
            {
                "id": "lesson_day_05_note_d",
                "type": "note_lesson",
                "title": "نغمة D / ري",
                "note": "D",
                "arabic_name": "ري",
                "description_ar": "ابدأ من D ثم تحرك نزولاً بجملة مترابطة حتى تبدأ تسمع اتجاه العبارة لا مجرد نغمات منفصلة.",
                "duration_minutes": 6,
            },
            {
                "id": "lesson_day_05_rhythm_dotted_half",
                "type": "rhythm_lesson",
                "title": "Dotted Half / بلانش منقوطة",
                "rhythm": "dotted_half_note",
                "description_ar": "البلانش المنقوطة تمتد ثلاث عدات، لذلك ركز على دعم الهواء والنهاية النظيفة قبل الدخول التالي.",
                "duration_minutes": 7,
            },
        ],
    },
    6: {
        "progress_percent": 0,
        "tasks": [
            {
                "id": "task_day_06_review_notes",
                "type": "note_lesson",
                "title": "مراجعة G A B C D",
                "duration_minutes": 7,
                "status": "next",
            },
            {
                "id": "task_day_06_rhythm_counting",
                "type": "rhythm_lesson",
                "title": "عدّ 1 2 3 4",
                "duration_minutes": 6,
                "status": "locked",
            },
            {
                "id": "task_day_06_practice_scale",
                "type": "practice",
                "title": "تمرين G A B C D",
                "duration_minutes": 10,
                "status": "locked",
            },
            {
                "id": "task_day_06_recording",
                "type": "recording_attempt",
                "title": "تسجيل المراجعة",
                "duration_minutes": 4,
                "status": "locked",
            },
        ],
        "lessons": [
            {
                "id": "lesson_day_06_review_notes",
                "type": "note_lesson",
                "title": "مراجعة G A B C D",
                "note": "G-A-B-C-D",
                "arabic_name": "صول - لا - سي - دو - ري",
                "description_ar": "راجع النغمات الخمس كأنها مادة أداء أساسية: نفس ثابت، انتقال واضح، وتكرار متسق من مرة إلى أخرى.",
                "duration_minutes": 7,
            },
            {
                "id": "lesson_day_06_rhythm_counting",
                "type": "rhythm_lesson",
                "title": "عدّ 1 2 3 4",
                "rhythm": "count_4_4",
                "description_ar": "ثبّت العد 1 2 3 4 بصوت داخلي واضح قبل العزف أو التسجيل حتى يصبح النبض جزءاً من الأداء نفسه.",
                "duration_minutes": 6,
            },
        ],
    },
    7: {
        "progress_percent": 0,
        "tasks": [
            {
                "id": "task_day_07_mini_melody",
                "type": "note_lesson",
                "title": "لحن صغير من 4 نغمات",
                "duration_minutes": 7,
                "status": "next",
            },
            {
                "id": "task_day_07_rhythm_review",
                "type": "rhythm_lesson",
                "title": "مراجعة الإيقاع الأسبوعي",
                "duration_minutes": 7,
                "status": "locked",
            },
            {
                "id": "task_day_07_practice_phrase",
                "type": "practice",
                "title": "تمرين G A B C | C B A G",
                "duration_minutes": 10,
                "status": "locked",
            },
            {
                "id": "task_day_07_recording",
                "type": "recording_attempt",
                "title": "التسجيل الختامي للأسبوع الأول",
                "duration_minutes": 4,
                "status": "locked",
            },
        ],
        "lessons": [
            {
                "id": "lesson_day_07_mini_melody",
                "type": "note_lesson",
                "title": "لحن صغير من 4 نغمات",
                "note": "G-A-B-C",
                "arabic_name": "صول - لا - سي - دو",
                "description_ar": "اختم الأسبوع بلحن قصير يصعد ثم يعود بهدوء، مع سماع بداية العبارة ونهايتها كأنها اختبار مصغر.",
                "duration_minutes": 7,
            },
            {
                "id": "lesson_day_07_rhythm_review",
                "type": "rhythm_lesson",
                "title": "مراجعة الإيقاع الأسبوعي",
                "rhythm": "weekly_review",
                "description_ar": "راجع النوار والبلانش والكروشين داخل جملة واحدة حتى تربط كل ما سبق قبل التسجيل الختامي.",
                "duration_minutes": 7,
            },
        ],
    },
}

_LEVELS = (
    "foundation",
    "tone",
    "rhythm",
    "scales",
    "jazz vocabulary",
    "ear training",
)
_NOTE_SEQUENCE = ("G", "A", "B", "C", "D", "E", "F#", "Bb")
_RHYTHM_SEQUENCE = (
    "quarter_note",
    "half_note",
    "quarter_rest",
    "eighth_notes",
    "dotted_half_note",
    "syncopation_intro",
)
_NOTE_TOKEN_PATTERN = re.compile(r"(F#|Gb|Ab|Bb|[A-G])")


def _extend_private_beta_curriculum() -> None:
    if len(_WEEK_CURRICULUM) >= _TOTAL_DAYS:
        _normalize_curriculum_targets()
        return

    for day_number in range(8, _TOTAL_DAYS + 1):
        _WEEK_CURRICULUM[day_number] = _build_generated_curriculum_day(day_number)

    _normalize_curriculum_targets()


def _build_generated_curriculum_day(day_number: int) -> dict[str, object]:
    level = _LEVELS[(day_number - 1) // 5]
    root_note = _NOTE_SEQUENCE[(day_number - 1) % len(_NOTE_SEQUENCE)]
    neighbor_note = _NOTE_SEQUENCE[day_number % len(_NOTE_SEQUENCE)]
    rhythm = _RHYTHM_SEQUENCE[(day_number - 1) % len(_RHYTHM_SEQUENCE)]
    pattern = f"{root_note} {root_note} {neighbor_note} {root_note}"
    day_label = str(day_number).zfill(2)

    return {
        "progress_percent": 0,
        "tasks": [
            {
                "id": f"task_day_{day_label}_tone_{root_note.lower().replace('#', 'sharp')}",
                "type": "note_lesson",
                "title": f"{level.title()} tone: {root_note}",
                "duration_minutes": 7,
                "status": "locked",
                "level": level,
                "expected_notes": [root_note],
                "rhythm_target": "long_tone",
                "locked_reason": "أكمل الأيام السابقة بتسجيل حقيقي صالح للتحليل أولاً.",
            },
            {
                "id": f"task_day_{day_label}_rhythm_{rhythm}",
                "type": "rhythm_lesson",
                "title": f"Rhythm target: {rhythm.replace('_', ' ')}",
                "duration_minutes": 7,
                "status": "locked",
                "level": level,
                "expected_notes": [root_note],
                "rhythm_target": rhythm,
                "locked_reason": "هذا الدرس يفتح بعد إكمال اليوم الحالي.",
            },
            {
                "id": f"task_day_{day_label}_practice_{root_note.lower().replace('#', 'sharp')}",
                "type": "practice",
                "title": f"تمرين {pattern}",
                "duration_minutes": 11,
                "status": "locked",
                "level": level,
                "expected_notes": [root_note, neighbor_note],
                "rhythm_target": rhythm,
                "retry_reason": "أعد المحاولة إذا كان pitch أو rhythm أقل من 70%.",
            },
            {
                "id": f"task_day_{day_label}_recording",
                "type": "recording_attempt",
                "title": "تسجيل محاولة اليوم",
                "duration_minutes": 4,
                "status": "locked",
                "level": level,
                "expected_notes": [root_note, neighbor_note],
                "rhythm_target": rhythm,
            },
        ],
        "lessons": [
            {
                "id": f"lesson_day_{day_label}_tone_{root_note.lower().replace('#', 'sharp')}",
                "type": "note_lesson",
                "title": f"{level.title()} tone: {root_note}",
                "note": root_note,
                "arabic_name": root_note,
                "description_ar": f"اليوم {day_number} يركز على {level}: ثبّت {root_note} ثم اربطها بجملة قصيرة قابلة للتحليل.",
                "duration_minutes": 7,
            },
            {
                "id": f"lesson_day_{day_label}_rhythm_{rhythm}",
                "type": "rhythm_lesson",
                "title": f"Rhythm target: {rhythm.replace('_', ' ')}",
                "rhythm": rhythm,
                "description_ar": "استمع للمرجع، عدّ بصوت داخلي، ثم سجّل محاولة قصيرة حتى تظهر أخطاء التوقيت بوضوح.",
                "duration_minutes": 7,
            },
        ],
    }

def get_today_daily_plan() -> DailyPlanResponse:
    return get_daily_plan(_CURRENT_DAY_NUMBER)


def get_daily_plan(day_number: int) -> DailyPlanResponse:
    day = _get_curriculum_day(day_number)

    return DailyPlanResponse(
        user_name=_USER_NAME,
        day_number=day_number,
        total_minutes=sum(task["duration_minutes"] for task in day["tasks"]),
        progress_percent=day["progress_percent"],
        tasks=[DailyTask(**task) for task in day["tasks"]],
    )


def get_week_overview() -> WeekOverviewResponse:
    days = []

    for day_number, day in _WEEK_CURRICULUM.items():
        days.append(
            WeekDaySummary(
                day_number=day_number,
                focus_title=day["tasks"][0]["title"],
                total_minutes=sum(task["duration_minutes"] for task in day["tasks"]),
                status=_get_day_status(day_number),
                progress_percent=day["progress_percent"],
            )
        )

    return WeekOverviewResponse(
        current_day_number=_CURRENT_DAY_NUMBER,
        total_days=len(_WEEK_CURRICULUM),
        completed_days=sum(
            1 for day in _WEEK_CURRICULUM.values() if day["progress_percent"] == 100
        ),
        days=days,
    )


def get_lessons(day_number: int | None = None) -> list[LessonResponse]:
    if day_number is not None:
        day = _get_curriculum_day(day_number)
        return _build_lessons(day_number, day["lessons"])

    lessons = []
    for current_day_number, day in _WEEK_CURRICULUM.items():
        lessons.extend(_build_lessons(current_day_number, day["lessons"]))
    return lessons


def _build_lessons(day_number: int, lessons: list[dict[str, object]]) -> list[LessonResponse]:
    return [
        LessonResponse(
            day_number=day_number,
            **lesson,
        )
        for lesson in lessons
    ]


def _get_curriculum_day(day_number: int) -> dict[str, object]:
    if day_number not in _WEEK_CURRICULUM:
        raise ValueError(f"Unsupported day number: {day_number}")

    return _WEEK_CURRICULUM[day_number]


def _get_day_status(day_number: int) -> str:
    if day_number < _CURRENT_DAY_NUMBER:
        return "completed"
    if day_number == _CURRENT_DAY_NUMBER:
        return "current"
    return "locked"


def get_task_targets(exercise_id: str) -> dict[str, object] | None:
    for day in _WEEK_CURRICULUM.values():
        for task in day["tasks"]:
            if task["id"] == exercise_id:
                return {
                    "expected_notes": list(task.get("expected_notes", [])),
                    "rhythm_target": task.get("rhythm_target"),
                }
    return None


def _normalize_curriculum_targets() -> None:
    for day in _WEEK_CURRICULUM.values():
        note_targets = _note_targets_for_day(day)
        rhythm_target = _rhythm_target_for_day(day)

        for task in day["tasks"]:
            task.setdefault(
                "expected_notes",
                _expected_notes_for_task(
                    task=task,
                    note_targets=note_targets,
                ),
            )
            task.setdefault(
                "rhythm_target",
                "long_tone" if task["type"] == "note_lesson" else rhythm_target,
            )


def _note_targets_for_day(day: dict[str, object]) -> list[str]:
    lessons = day["lessons"]
    for lesson in lessons:
        if lesson["type"] != "note_lesson":
            continue

        note_value = lesson.get("note")
        if isinstance(note_value, str) and note_value:
            notes = _extract_note_tokens(note_value.replace("-", " "))
            if notes:
                return notes

    return []


def _rhythm_target_for_day(day: dict[str, object]) -> str | None:
    lessons = day["lessons"]
    for lesson in lessons:
        if lesson["type"] == "rhythm_lesson":
            rhythm = lesson.get("rhythm")
            if isinstance(rhythm, str) and rhythm:
                return rhythm
    return None


def _expected_notes_for_task(
    *,
    task: dict[str, object],
    note_targets: list[str],
) -> list[str]:
    title = task.get("title")
    title_notes = _extract_note_tokens(title) if isinstance(title, str) else []
    if title_notes:
        return title_notes

    if task["type"] == "note_lesson":
        return note_targets

    if task["type"] == "rhythm_lesson" and note_targets:
        return [note_targets[0]]

    return note_targets[:2] if len(note_targets) > 1 else note_targets


def _extract_note_tokens(value: str) -> list[str]:
    matches = _NOTE_TOKEN_PATTERN.findall(value)
    notes = []
    for note in matches:
        if note not in notes:
            notes.append(note)
    return notes


_extend_private_beta_curriculum()
