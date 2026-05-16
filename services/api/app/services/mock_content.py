import re

from app.schemas.daily_plan import (
    DailyPlanResponse,
    DailyTask,
    ExpectedEvent,
    WeekDaySummary,
    WeekOverviewResponse,
)
from app.schemas.lesson import LessonResponse
from app.services.adaptive_engine import build_adaptation_profile, latest_relevant_attempt
from app.services.mastery import get_skill_mastery

_CURRENT_DAY_NUMBER = 1
_TOTAL_DAYS = 30
_USER_NAME = "أحمد"

_WEEK_CURRICULUM = {
    1: {
        "progress_percent": 0,
        "stage_id": "setup",
        "tasks": [
            {
                "id": "task_f_posture",
                "type": "note_lesson",
                "title": "وضعية الجسم واليدين",
                "duration_minutes": 5,
                "status": "next",
                "source_id": "eastman-community-saxophone",
            },
            {
                "id": "task_f_breath",
                "type": "note_lesson",
                "title": "تقنية التنفس الصحيح",
                "duration_minutes": 5,
                "status": "locked",
                "source_id": "berklee-woodwinds",
            },
            {
                "id": "task_d01_g",
                "type": "note_lesson",
                "title": "نغمة G / صول",
                "duration_minutes": 5,
                "status": "locked",
                "expected_notes": ["G4"],
            },
            {
                "id": "task_d01_rec",
                "type": "recording_attempt",
                "title": "تسجيل أول نغمة",
                "duration_minutes": 3,
                "status": "locked",
            },
        ],
        "lessons": [
            {
                "id": "lesson_f_posture",
                "type": "note_lesson",
                "title": "وضعية الجسم واليدين",
                "description_ar": "الساكسفون يعتمد على استرخاء الجسم. اجعل أصابعك مقوسة وقريبة من المفاتيح.",
                "duration_minutes": 5,
                "video_url": "https://www.youtube.com/watch?v=A8f9-4hV03U",
            },
            {
                "id": "lesson_f_breath",
                "type": "note_lesson",
                "title": "التنفس العميق",
                "description_ar": "خذ نفساً عميقاً من بطنك وليس من صدرك. تخيل بالوناً داخل معدتك.",
                "duration_minutes": 5,
                "video_url": "https://www.youtube.com/watch?v=0_uFfR7A6h4",
            },
            {
                "id": "lesson_d01_g",
                "type": "note_lesson",
                "title": "نغمة G / صول",
                "note": "G4",
                "arabic_name": "صول",
                "description_ar": "نغمة صول هي نغمة التوازن. اضغط الثلاث أصابع العلوية لليد اليسرى.",
                "duration_minutes": 5,
                "video_url": "https://www.youtube.com/watch?v=7X89S_E-W8Y",
            },
        ],
    },
    2: {
        "progress_percent": 0,
        "stage_id": "first_notes",
        "tasks": [
            {
                "id": "task_d02_a",
                "type": "note_lesson",
                "title": "نغمة A / لا",
                "duration_minutes": 6,
                "status": "next",
                "expected_notes": ["A4"],
            },
            {
                "id": "task_d02_tap",
                "type": "tap_drill",
                "title": "تدريب نقر (Quarter Note)",
                "duration_minutes": 5,
                "status": "locked",
            },
            {
                "id": "task_d02_change",
                "type": "practice",
                "title": "تبديل G - A",
                "duration_minutes": 10,
                "status": "locked",
                "expected_notes": ["G4", "A4"],
            },
        ],
        "lessons": [
            {
                "id": "lesson_d02_a",
                "type": "note_lesson",
                "title": "نغمة A / لا",
                "note": "A4",
                "arabic_name": "لا",
                "description_ar": "ارفع البنصر الأيسر لعزف A. حافظ على هواء مستقر.",
                "duration_minutes": 6,
                "video_url": "https://www.youtube.com/watch?v=7X89S_E-W8Y",
            },
        ],
    },
    3: {
        "progress_percent": 0,
        "stage_id": "first_notes",
        "tasks": [
            {
                "id": "task_d03_b",
                "type": "note_lesson",
                "title": "نغمة B / سي",
                "duration_minutes": 6,
                "status": "next",
                "expected_notes": ["B4"],
            },
            {
                "id": "task_d03_bag",
                "type": "practice",
                "title": "تمرين B - A - G",
                "duration_minutes": 10,
                "status": "locked",
                "expected_notes": ["B4", "A4", "G4"],
            },
        ],
        "lessons": [
            {
                "id": "lesson_d03_b",
                "type": "note_lesson",
                "title": "نغمة B / سي",
                "note": "B4",
                "arabic_name": "سي",
                "description_ar": "السبابة اليسرى فقط. ركز على البداية النظيفة (Attack).",
                "duration_minutes": 6,
                "video_url": "https://www.youtube.com/watch?v=7X89S_E-W8Y",
            },
        ],
    },
    4: {
        "progress_percent": 0,
        "stage_id": "first_notes",
        "tasks": [
            {
                "id": "task_d04_f",
                "type": "note_lesson",
                "title": "نغمة F / فا",
                "duration_minutes": 6,
                "status": "next",
                "expected_notes": ["F4"],
            },
            {
                "id": "task_d04_clap",
                "type": "clap_drill",
                "title": "تدريب تصفيق (Half Note)",
                "duration_minutes": 5,
                "status": "locked",
            },
        ],
        "lessons": [
            {
                "id": "lesson_d04_f",
                "type": "note_lesson",
                "title": "نغمة F / فا",
                "note": "F4",
                "arabic_name": "فا",
                "description_ar": "أول نغمة لليد اليمنى (السبابة).",
                "duration_minutes": 6,
                "video_url": "https://www.youtube.com/watch?v=f2n_zLzI5u0",
            },
        ],
    },
    5: {
        "progress_percent": 0,
        "stage_id": "first_notes",
        "tasks": [
            {
                "id": "task_d05_e",
                "type": "note_lesson",
                "title": "نغمة E / مي",
                "duration_minutes": 6,
                "status": "next",
                "expected_notes": ["E4"],
            },
            {
                "id": "task_d05_fe",
                "type": "practice",
                "title": "تمرين F - E",
                "duration_minutes": 10,
                "status": "locked",
                "expected_notes": ["F4", "E4"],
            },
        ],
        "lessons": [
            {
                "id": "lesson_d05_e",
                "type": "note_lesson",
                "title": "نغمة E / مي",
                "note": "E4",
                "arabic_name": "مي",
                "description_ar": "الإصبع الأوسط لليد اليمنى.",
                "duration_minutes": 6,
                "video_url": "https://www.youtube.com/watch?v=f2n_zLzI5u0",
            },
        ],
    },
    6: {
        "progress_percent": 0,
        "stage_id": "first_notes",
        "tasks": [
            {
                "id": "task_d06_d",
                "type": "note_lesson",
                "title": "نغمة D / ري",
                "duration_minutes": 6,
                "status": "next",
                "expected_notes": ["D4"],
            },
            {
                "id": "task_d06_desc",
                "type": "practice",
                "title": "السلم الهابط ببطء",
                "duration_minutes": 10,
                "status": "locked",
                "expected_notes": ["G4", "F4", "E4", "D4"],
            },
        ],
        "lessons": [
            {
                "id": "lesson_d06_d",
                "type": "note_lesson",
                "title": "نغمة D / ري",
                "note": "D4",
                "arabic_name": "ري",
                "description_ar": "إغلاق الأصابع الستة. تحتاج دعماً هوائياً أقوى.",
                "duration_minutes": 6,
                "video_url": "https://www.youtube.com/watch?v=f2n_zLzI5u0",
            },
        ],
    },
    7: {
        "progress_percent": 0,
        "stage_id": "rhythm_intro",
        "tasks": [
            {
                "id": "task_d07_q",
                "type": "rhythm_lesson",
                "title": "النوار (Quarter Note)",
                "duration_minutes": 7,
                "status": "next",
            },
            {
                "id": "task_d07_count",
                "type": "count_drill",
                "title": "تدريب عدّ 1 2 3 4",
                "duration_minutes": 5,
                "status": "locked",
            },
        ],
        "lessons": [
            {
                "id": "lesson_d07_q",
                "type": "rhythm_lesson",
                "title": "إيقاع النوار",
                "description_ar": "تعلم النبض الثابت. كل نبضة تأخذ نغمة واحدة.",
                "duration_minutes": 7,
                "video_url": "https://www.youtube.com/watch?v=cpS2D636V_A",
            },
        ],
    },
    8: {
        "progress_percent": 0,
        "stage_id": "rhythm_intro",
        "tasks": [
            {
                "id": "task_d08_h",
                "type": "rhythm_lesson",
                "title": "البلانش (Half Note)",
                "duration_minutes": 7,
                "status": "next",
            },
            {
                "id": "task_d08_rec",
                "type": "recording_attempt",
                "title": "تسجيل إيقاعي",
                "duration_minutes": 5,
                "status": "locked",
            },
        ],
        "lessons": [
            {
                "id": "lesson_d08_h",
                "type": "rhythm_lesson",
                "title": "إيقاع البلانش",
                "description_ar": "البلانش تأخذ نبضتين. استمر في النفخ حتى نهاية العدة الثانية.",
                "duration_minutes": 7,
                "video_url": "https://www.youtube.com/watch?v=cpS2D636V_A",
            },
        ],
    },
    9: {
        "progress_percent": 0,
        "stage_id": "review",
        "tasks": [
            {
                "id": "task_d09_rev",
                "type": "practice",
                "title": "مراجعة كل النغمات",
                "duration_minutes": 15,
                "status": "next",
                "expected_notes": ["G4", "A4", "B4", "F4", "E4", "D4"],
            },
        ],
        "lessons": [
            {
                "id": "lesson_d09_rev",
                "type": "note_lesson",
                "title": "يوم التثبيت",
                "description_ar": "راجع وضعية يدك وصوتك قبل الانتقال للمرحلة التالية.",
                "duration_minutes": 5,
                "video_url": "https://www.youtube.com/watch?v=kY6V6n6L5p8",
            },
        ],
    },
    10: {
        "progress_percent": 0,
        "stage_id": "assessment",
        "tasks": [
            {
                "id": "task_d10_exam",
                "type": "recording_attempt",
                "title": "اختبار المرحلة الأولى",
                "duration_minutes": 10,
                "status": "next",
            },
        ],
        "lessons": [
            {
                "id": "lesson_d10_exam",
                "type": "note_lesson",
                "title": "بوابة العبور",
                "description_ar": "سجل معزوفة قصيرة بنجاح لتفتح سجل الأوكتاف العالي.",
                "duration_minutes": 5,
            },
        ],
    },
    11: {
        "progress_percent": 0,
        "stage_id": "octave_intro",
        "tasks": [
            {
                "id": "task_d11_oct",
                "type": "note_lesson",
                "title": "مفتاح الأوكتاف",
                "duration_minutes": 7,
                "status": "next",
            },
        ],
        "lessons": [
            {
                "id": "lesson_d11_oct",
                "type": "note_lesson",
                "title": "رفع الصوت",
                "description_ar": "استخدم الإبهام الأيسر لضغط مفتاح الأوكتاف. جرب G عالية.",
                "duration_minutes": 7,
                "video_url": "https://www.youtube.com/watch?v=I67-H0E6l-0",
            },
        ],
    },
    12: {
        "progress_percent": 0,
        "stage_id": "octave_intro",
        "tasks": [
            {
                "id": "task_d12_d_hi",
                "type": "note_lesson",
                "title": "نغمة D العالية",
                "duration_minutes": 6,
                "status": "next",
                "expected_notes": ["D5"],
            },
        ],
        "lessons": [
            {
                "id": "lesson_d12_d_hi",
                "type": "note_lesson",
                "title": "D5",
                "note": "D5",
                "arabic_name": "ري عالية",
                "description_ar": "6 أصابع + أوكتاف. اضغط هواء مركزاً.",
                "duration_minutes": 6,
                "video_url": "https://www.youtube.com/watch?v=I67-H0E6l-0",
            },
        ],
    },
    13: {
        "progress_percent": 0,
        "stage_id": "scales_intro",
        "tasks": [
            {
                "id": "task_d13_scale",
                "type": "note_lesson",
                "title": "سلم دو الكبير",
                "duration_minutes": 10,
                "status": "next",
                "expected_notes": ["C4", "D4", "E4", "F4", "G4", "A4", "B4", "C5"],
            },
        ],
        "lessons": [
            {
                "id": "lesson_d13_scale",
                "type": "note_lesson",
                "title": "السلم الكامل",
                "description_ar": "اربط كل ما تعلمته لتعزف سلم C Major كاملاً.",
                "duration_minutes": 10,
                "video_url": "https://www.youtube.com/watch?v=Zf_DqOq2Yic",
            },
        ],
    },
    14: {
        "progress_percent": 0,
        "stage_id": "scales_intro",
        "tasks": [
            {
                "id": "task_d14_melody",
                "type": "practice",
                "title": "نشيد الفرح (بيتهوفن)",
                "duration_minutes": 12,
                "status": "next",
            },
        ],
        "lessons": [
            {
                "id": "lesson_d14_melody",
                "type": "note_lesson",
                "title": "أول أغنية كاملة",
                "description_ar": "طبق مهاراتك في عزف لحن عالمي شهير.",
                "duration_minutes": 10,
                "video_url": "https://www.youtube.com/watch?v=Zf_DqOq2Yic",
            },
        ],
    },
}

_LEVELS = ("foundation", "tone", "rhythm", "scales")
_NOTE_SEQUENCE = ("G4", "A4", "B4", "C5", "D5")
_NOTE_TOKEN_PATTERN = re.compile(r"(F#|Gb|Ab|Bb|[A-G]\d?)")

def _extend_private_beta_curriculum() -> None:
    for day_number in range(len(_WEEK_CURRICULUM) + 1, _TOTAL_DAYS + 1):
        _WEEK_CURRICULUM[day_number] = _build_generated_curriculum_day(day_number)

def _build_generated_curriculum_day(day_number: int) -> dict[str, object]:
    level = _LEVELS[min((day_number - 1) // 5, len(_LEVELS) - 1)]
    root_note = _NOTE_SEQUENCE[(day_number - 1) % len(_NOTE_SEQUENCE)]
    day_label = str(day_number).zfill(2)
    return {
        "progress_percent": 0,
        "stage_id": "extended",
        "tasks": [{"id": f"task_day_{day_label}", "type": "practice", "title": f"يوم تدريبي {day_number}", "duration_minutes": 10, "status": "locked", "expected_notes": [root_note]}],
        "lessons": [{"id": f"lesson_day_{day_label}", "type": "note_lesson", "title": f"الدرس {day_number}", "description_ar": "استمر في تثبيت مهاراتك السابقة مع زيادة التحدي.", "duration_minutes": 10}],
    }

def get_today_daily_plan() -> DailyPlanResponse:
    return get_daily_plan(_CURRENT_DAY_NUMBER)

def get_daily_plan(day_number: int, track: str = "beginner") -> DailyPlanResponse:
    day = _get_curriculum_day(day_number, track=track)
    tasks = [_build_daily_task(day_number, task) for task in day["tasks"]]
    return DailyPlanResponse(
        user_name=_USER_NAME,
        day_number=day_number,
        total_minutes=sum(task.duration_minutes for task in tasks),
        progress_percent=day["progress_percent"],
        tasks=tasks,
        stage_id=str(day.get("stage_id", "default")),
    )

def get_week_overview() -> WeekOverviewResponse:
    days = [WeekDaySummary(day_number=d, focus_title=data["tasks"][0]["title"], total_minutes=15, status="locked", progress_percent=0) for d, data in _WEEK_CURRICULUM.items()]
    return WeekOverviewResponse(current_day_number=_CURRENT_DAY_NUMBER, total_days=len(_WEEK_CURRICULUM), completed_days=0, days=days)

def get_lessons(day_number: int | None = None, track: str = "beginner") -> list[LessonResponse]:
    lessons = []
    for d_num, day in _WEEK_CURRICULUM.items():
        if day_number is None or d_num == day_number:
            for l in day["lessons"]:
                lessons.append(LessonResponse(day_number=d_num, **l))
    return lessons

def _get_curriculum_day(day_number: int, track: str = "beginner") -> dict[str, object]:
    if day_number not in _WEEK_CURRICULUM:
        raise ValueError(f"Day {day_number} not found")
    return _WEEK_CURRICULUM[day_number]

def _build_daily_task(day_number: int, task: dict[str, object]) -> DailyTask:
    payload = dict(task)
    payload.setdefault("target_bpm", 60)
    payload.setdefault("skill_tags", ["tone"])
    payload.setdefault("block_type", _block_type_for_task(payload["type"]))
    payload.setdefault("reference_audio_url", f"generated://day_{day_number}/{task['id']}")
    payload.setdefault("expected_event_timeline", _build_timeline(payload.get("expected_notes", ["G4"])))
    payload.setdefault("license_status", "original")
    payload.setdefault("publish_status", "approved_publishable")
    return DailyTask(**payload)

def _block_type_for_task(task_type: str) -> str:
    return {
        "note_lesson": "note_fingering",
        "rhythm_lesson": "rhythm_call_response",
        "practice": "rhythm_call_response",
        "recording_attempt": "record_check",
        "tap_drill": "rhythm_tap",
        "clap_drill": "rhythm_clap",
        "count_drill": "rhythm_count",
    }.get(task_type, "warm_up")

def _build_timeline(notes: list[str]) -> list[ExpectedEvent]:
    return [ExpectedEvent(note=n, onset_seconds=i * 1.5, duration_seconds=0.75) for i, n in enumerate(notes)]

def get_task_targets(exercise_id: str) -> dict[str, object] | None:
    for day_number, day in _WEEK_CURRICULUM.items():
        for task in day["tasks"]:
            if task["id"] == exercise_id:
                decorated = _build_daily_task(day_number, task)
                return {
                    "expected_notes": list(decorated.expected_notes),
                    "rhythm_target": decorated.rhythm_target or "long_tone",
                    "target_bpm": decorated.target_bpm,
                    "skill_tags": list(decorated.skill_tags),
                    "block_type": decorated.block_type,
                    "expected_event_timeline": [
                        {"note": e.note, "onset_seconds": e.onset_seconds, "duration_seconds": e.duration_seconds}
                        for e in decorated.expected_event_timeline
                    ],
                }
    return None

def _extract_note_tokens(value: str) -> list[str]:
    return _NOTE_TOKEN_PATTERN.findall(value)

_extend_private_beta_curriculum()
