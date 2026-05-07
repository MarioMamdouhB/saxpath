from app.schemas.daily_plan import DailyPlanResponse, DailyTask
from app.schemas.lesson import LessonResponse


def get_today_daily_plan() -> DailyPlanResponse:
    return DailyPlanResponse(
        user_name="أحمد",
        day_number=1,
        total_minutes=25,
        progress_percent=0,
        tasks=[
            DailyTask(
                id="task_day_01_note_g",
                type="note_lesson",
                title="نغمة G / صول",
                duration_minutes=5,
                status="next",
            ),
            DailyTask(
                id="task_day_01_rhythm_quarter",
                type="rhythm_lesson",
                title="Quarter Note / نوار",
                duration_minutes=7,
                status="locked",
            ),
            DailyTask(
                id="task_day_01_practice_ggaa",
                type="practice",
                title="تمرين G G A A",
                duration_minutes=10,
                status="locked",
            ),
            DailyTask(
                id="task_day_01_recording",
                type="recording_attempt",
                title="تسجيل المحاولة",
                duration_minutes=3,
                status="locked",
            ),
        ],
    )


def get_lessons() -> list[LessonResponse]:
    return [
        LessonResponse(
            id="lesson_note_g",
            type="note_lesson",
            title="نغمة G / صول",
            note="G",
            arabic_name="صول",
            description_ar="تعلم مكان نغمة G على المدرج واسمع صوتها قبل العزف.",
            duration_minutes=5,
        ),
        LessonResponse(
            id="lesson_note_a",
            type="note_lesson",
            title="نغمة A / لا",
            note="A",
            arabic_name="لا",
            description_ar="تعلم الفرق بين G و A من حيث الشكل والصوت.",
            duration_minutes=5,
        ),
        LessonResponse(
            id="lesson_rhythm_quarter",
            type="rhythm_lesson",
            title="Quarter Note / نوار",
            rhythm="quarter_note",
            description_ar="النوار يساوي عدة واحدة في ميزان 4/4.",
            duration_minutes=7,
        ),
    ]
