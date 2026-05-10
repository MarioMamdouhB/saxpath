from dataclasses import dataclass


@dataclass(frozen=True)
class CurriculumSource:
    id: str
    institution: str
    focus: str
    source_url: str


QS_REFERENCE = {
    "name": "QS World University Rankings by Subject 2025: Performing Arts",
    "source_url": "https://www.topuniversities.com/university-subject-rankings/performing-arts?page=1",
    "purpose": "Reference ranking used to prioritize major performing arts and music institutions.",
}


INSTITUTIONAL_SOURCES: tuple[CurriculumSource, ...] = (
    CurriculumSource(
        id="berklee-core",
        institution="Berklee College of Music",
        focus="Core music curriculum: ear training, harmony, arranging, conducting, music technology.",
        source_url="https://college.berklee.edu/core-music-curriculum",
    ),
    CurriculumSource(
        id="berklee-woodwinds",
        institution="Berklee College of Music",
        focus="Woodwind principal study: private instruction, labs, and ensembles over multiple semesters.",
        source_url="https://college.berklee.edu/woodwinds/principal",
    ),
    CurriculumSource(
        id="boston-conservatory-woodwinds",
        institution="Boston Conservatory at Berklee",
        focus="Woodwind performance sequence including harmony, ear training, and time/rhythm study.",
        source_url="https://bostonconservatory.berklee.edu/woodwinds/bm-woodwind-performance",
    ),
    CurriculumSource(
        id="eastman-saxophone-studio",
        institution="Eastman School of Music",
        focus="Saxophone performance training built around lessons, chops building, and chamber musicianship.",
        source_url="https://www.esm.rochester.edu/wbp/saxophone-studio/",
    ),
    CurriculumSource(
        id="eastman-community-saxophone",
        institution="Eastman Community Music School",
        focus="Beginner saxophone sequence: posture, embouchure, air, tonguing, notation, and early scales.",
        source_url="https://www.esm.rochester.edu/community/faq/student-curriculum/saxophone/",
    ),
    CurriculumSource(
        id="jacobs-jazz-bm",
        institution="Indiana University Jacobs School of Music",
        focus="Jazz saxophone degree structure with performance study, jazz chamber ensemble, and major ensemble.",
        source_url="https://bulletin.iu.edu/iub/music/2024-2025/undergraduate/music-degrees/jazz-studies.shtml",
    ),
    CurriculumSource(
        id="unt-woodwinds",
        institution="University of North Texas College of Music",
        focus="Forward-looking woodwind education for performers, chamber musicians, teachers, and leaders.",
        source_url="https://music.unt.edu/woodwinds/",
    ),
    CurriculumSource(
        id="unt-saxophone-handbook",
        institution="University of North Texas College of Music",
        focus="Applied lesson structure, juries, repertoire rotation, recital attendance, and jazz/classical expectations.",
        source_url="https://music.unt.edu/files/default/files/saxophone_handbook_fall_2021.pdf",
    ),
)


DAY_SOURCE_MAP: dict[int, tuple[str, ...]] = {
    1: ("eastman-community-saxophone", "berklee-woodwinds"),
    2: ("eastman-community-saxophone", "boston-conservatory-woodwinds"),
    3: ("eastman-community-saxophone", "berklee-core"),
    4: ("eastman-saxophone-studio", "berklee-core"),
    5: ("eastman-saxophone-studio", "unt-saxophone-handbook"),
    6: ("jacobs-jazz-bm", "unt-woodwinds"),
    7: ("eastman-saxophone-studio", "unt-saxophone-handbook", "jacobs-jazz-bm"),
}


DAY_TEACHING_PRINCIPLES: dict[int, tuple[str, ...]] = {
    1: (
        "Start with posture, mouthpiece placement, relaxed hand position, and a single stable pitch.",
        "Connect first-note production to listening before playing.",
    ),
    2: (
        "Reinforce air support and long-tone steadiness while adding one nearby pitch.",
        "Keep rhythm simple so tone production remains the main challenge.",
    ),
    3: (
        "Introduce tonguing clarity and the first meaningful silence through a quarter rest.",
        "Strengthen notation reading and counting together.",
    ),
    4: (
        "Add faster subdivision only after tone and pulse feel stable.",
        "Use short pitch patterns to coordinate fingers with articulation.",
    ),
    5: (
        "Shift from isolated notes toward connected scalar motion and phrase direction.",
        "Sustain longer values with supported breath and clean endings.",
    ),
    6: (
        "Review note set and counting as a mini performance core, not isolated drills.",
        "Prepare the learner to repeat material consistently, as in studio and ensemble settings.",
    ),
    7: (
        "Close the week with a compact melody and self-review recording.",
        "Treat the final task as a small jury-style checkpoint built from the week's fundamentals.",
    ),
}
