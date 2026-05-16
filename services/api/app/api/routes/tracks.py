from fastapi import APIRouter
from app.schemas.track import TrackResponse, StageSummary

router = APIRouter(tags=["tracks"])

@router.get("/tracks", response_model=list[TrackResponse])
async def get_tracks():
    return [
        TrackResponse(
            id="beginner",
            title="1. المستوى المبتدئ (The Foundation)",
            description="إصدار صوت نظيف، قراءة الرموز الأساسية، وعزف أول أوكتاف.",
            stages=[
                StageSummary(id="setup", title="الوضعية والتنفس", description="الأساسيات لضمان صوت نقي بدون إجهاد.", day_count=1),
                StageSummary(id="first_notes", title="الأوكتاف الأول", description="تعلم G, A, B, F, E, D وكيفية قراءتها.", day_count=5),
                StageSummary(id="rhythm_basics", title="النبض والوقت", description="قواعد الإيقاع: النوار والبلانش.", day_count=4),
                StageSummary(id="beginner_exam", title="🎓 امتحان المستوى المبتدئ", description="عزف مقطوعة كاملة بجميع نغمات الأوكتاف الأول.", is_exam=True, day_count=1),
            ]
        ),
        TrackResponse(
            id="intermediate",
            title="2. المستوى المتوسط (The Performer)",
            description="التمكن من كامل مدى الآلة، إحساس الجاز، والسرعة.",
            stages=[
                StageSummary(id="octave_mastery", title="مفتاح الأوكتاف", description="الانتقال السلس بين السجلات.", is_unlocked=False, day_count=7),
                StageSummary(id="jazz_articulation", title="لغة الجاز الأولى", description="إحساس الـ Swing والـ Tonguing.", is_unlocked=False, day_count=7),
                StageSummary(id="scales_all", title="السلالم الـ 12", description="السيطرة التقنية الكاملة.", is_unlocked=False, day_count=14),
                StageSummary(id="intermediate_exam", title="🎓 امتحان المستوى المتوسط", description="عزف مقطوعة جاز (Standard) مع السوينغ.", is_exam=True, day_count=1),
            ]
        ),
        TrackResponse(
            id="advanced",
            title="3. المستوى المتقدم (The Pro)",
            description="الارتجال الحر، نغمات الـ Altissimo، والتكنيك السريع.",
            stages=[
                StageSummary(id="altissimo", title="الطبقات العالية جداً", description="ما فوق الـ F# العالية.", is_unlocked=False, day_count=10),
                StageSummary(id="improv_complex", title="الارتجال المتقدم", description="عزف Solo احترافي على ii-V-I.", is_unlocked=False, day_count=15),
                StageSummary(id="maqam_pro", title="الربع تون والشرقي", description="إتقان المقامات العربية الصعبة.", is_unlocked=False, day_count=10),
            ]
        )
    ]
