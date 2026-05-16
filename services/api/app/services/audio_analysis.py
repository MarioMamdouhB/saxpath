import json
from pathlib import Path
from tempfile import NamedTemporaryFile
import wave

import httpx
from fastapi import UploadFile

from app.core.config import get_settings
from app.schemas.attempt import AttemptAnalysis, DetectedNote, EventMatch, TimingError
from app.schemas.recording import RecordingResponse
from app.services.mock_content import get_task_targets


class AudioAnalysisError(Exception):
    """Raised when the audio engine cannot analyze an uploaded recording."""


class AudioAnalysisInputError(Exception):
    """Raised when the uploaded learner audio is invalid."""


def analyze_recording(
    *,
    recording: RecordingResponse,
    exercise_id: str,
) -> AttemptAnalysis:
    settings = get_settings()
    if settings.demo_mode:
        return build_deterministic_analysis(
            exercise_id=exercise_id,
            duration_seconds=recording.duration_seconds,
            source="demo_mode",
        )

    try:
        path = Path(recording.storage_path)
        if not path.exists():
            raise AudioAnalysisError("Recording file does not exist.")

        task_targets = get_task_targets(exercise_id) or {}
        rhythm_target = _rhythm_target_for_exercise(exercise_id)
        target_bpm = _target_bpm_for_exercise(exercise_id)
        expected_event_timeline = task_targets.get("expected_event_timeline")
        try:
            phrase_payload = _post_file(
                endpoint="/api/v1/audio-analysis/evaluate",
                path=path,
                data={
                    "expected_note": _expected_note_for_exercise(exercise_id),
                    "bpm": str(target_bpm),
                    "rhythm_target": rhythm_target,
                    "expected_event_timeline": json.dumps(
                        expected_event_timeline if isinstance(expected_event_timeline, list) else [],
                        ensure_ascii=False,
                    ),
                },
            )
            return _analysis_from_payload(
                phrase_payload,
                source="audio_engine_phrase_v2",
            )
        except (AudioAnalysisError, httpx.HTTPError, ValueError):
            pitch_payload = _post_file(
                endpoint="/api/v1/audio-analysis/pitch",
                path=path,
                data={"expected_note": _expected_note_for_exercise(exercise_id)},
            )
            rhythm_payload = _post_file(
                endpoint="/api/v1/audio-analysis/rhythm",
                path=path,
                data={
                    "bpm": str(target_bpm),
                    "rhythm_target": rhythm_target,
                },
            )

            return _combine_audio_engine_payloads(
                pitch_payload=pitch_payload,
                rhythm_payload=rhythm_payload,
                source="audio_engine",
            )
    except (AudioAnalysisError, OSError, httpx.HTTPError, ValueError):
        return build_deterministic_analysis(
            exercise_id=exercise_id,
            duration_seconds=recording.duration_seconds,
            source="deterministic_mock_fallback",
        )


async def analyze_upload(
    *,
    file: UploadFile,
    kind: str,
    expected_note: str = "G",
    bpm: int = 60,
    rhythm_target: str = "quarter_note",
) -> AttemptAnalysis:
    settings = get_settings()
    suffix = Path(file.filename or "recording.wav").suffix or ".wav"

    try:
        temp_path: Path | None = None
        with NamedTemporaryFile(delete=False, suffix=suffix) as temp_file:
            temp_path = Path(temp_file.name)
            temp_file.write(await file.read())

        _validate_uploaded_wav(temp_path)

        if settings.demo_mode:
            return build_deterministic_analysis(
                exercise_id=f"upload_{kind}",
                duration_seconds=8,
                source="demo_mode",
            )

        endpoint = (
            "/api/v1/audio-analysis/pitch"
            if kind == "pitch"
            else "/api/v1/audio-analysis/rhythm"
        )
        data = (
            {"expected_note": expected_note}
            if kind == "pitch"
            else {
                "bpm": str(bpm),
                "rhythm_target": rhythm_target,
            }
        )
        payload = _post_file(endpoint=endpoint, path=temp_path, data=data)
        return _analysis_from_payload(payload, source="audio_engine")
    except AudioAnalysisInputError:
        raise
    except httpx.HTTPStatusError as exc:
        if exc.response is not None and 400 <= exc.response.status_code < 500:
            raise AudioAnalysisInputError("Invalid WAV recording.") from exc
        return build_deterministic_analysis(
            exercise_id=f"upload_{kind}",
            duration_seconds=8,
            source="deterministic_mock_fallback",
        )
    except (OSError, httpx.HTTPError, ValueError):
        return build_deterministic_analysis(
            exercise_id=f"upload_{kind}",
            duration_seconds=8,
            source="deterministic_mock_fallback",
        )
    finally:
        try:
            temp_path.unlink(missing_ok=True)
        except (NameError, OSError):
            pass


def _validate_uploaded_wav(path: Path) -> None:
    try:
        with wave.open(str(path), "rb") as wav_file:
            if wav_file.getnchannels() <= 0 or wav_file.getframerate() <= 0:
                raise AudioAnalysisInputError("Invalid WAV recording.")
    except (wave.Error, EOFError, ValueError) as exc:
        raise AudioAnalysisInputError("Invalid WAV recording.") from exc


def build_deterministic_analysis(
    *,
    exercise_id: str,
    duration_seconds: int,
    source: str = "deterministic_mock",
) -> AttemptAnalysis:
    day_number = _extract_day_number(exercise_id)
    normalized_day = min(day_number, 7)

    if duration_seconds < 6:
        pitch_score = 60 + normalized_day
        rhythm_score = 54 + normalized_day
        confidence = 0.46
    elif duration_seconds < 12:
        pitch_score = 69 + normalized_day
        rhythm_score = 64 + normalized_day
        confidence = 0.68
    else:
        pitch_score = 77 + normalized_day
        rhythm_score = 72 + normalized_day
        confidence = 0.82

    return AttemptAnalysis(
        pitch_score=pitch_score,
        rhythm_score=rhythm_score,
        detected_notes=[
            DetectedNote(
                note=_expected_note_for_exercise(exercise_id),
                frequency_hz=196.0,
                confidence=round(confidence, 2),
            )
        ],
        timing_errors=[] if rhythm_score >= 70 else [
            TimingError(
                onset_seconds=1.0,
                expected_seconds=0.75,
                error_ms=250,
            )
        ],
        tone_score=max(55, round((pitch_score * 0.7) + (rhythm_score * 0.3))),
        event_matches=[
            EventMatch(
                expected_note=_expected_note_for_exercise(exercise_id),
                detected_note=_expected_note_for_exercise(exercise_id),
                expected_seconds=0,
                observed_seconds=0,
                timing_error_ms=0,
                pitch_ok=pitch_score >= 70,
            )
        ],
        sustain_stability=round(min(0.92, confidence + 0.08), 2),
        confidence=round(confidence, 2),
        source=source,
        analysis_version="deterministic_v2",
    )


def _post_file(
    *,
    endpoint: str,
    path: Path,
    data: dict[str, str],
) -> dict[str, object]:
    settings = get_settings()
    url = f"{settings.audio_engine_base_url.rstrip('/')}{endpoint}"

    with path.open("rb") as audio_file:
        response = httpx.post(
            url,
            data=data,
            files={"file": (path.name, audio_file, "audio/wav")},
            timeout=8,
        )

    response.raise_for_status()
    payload = response.json()
    if not isinstance(payload, dict):
        raise AudioAnalysisError("Audio engine returned an invalid payload.")
    return payload


def _combine_audio_engine_payloads(
    *,
    pitch_payload: dict[str, object],
    rhythm_payload: dict[str, object],
    source: str,
) -> AttemptAnalysis:
    pitch = _analysis_from_payload(pitch_payload, source=source)
    rhythm = _analysis_from_payload(rhythm_payload, source=source)

    return AttemptAnalysis(
        pitch_score=pitch.pitch_score,
        rhythm_score=rhythm.rhythm_score,
        detected_notes=pitch.detected_notes,
        timing_errors=rhythm.timing_errors,
        tone_score=pitch.tone_score or pitch.pitch_score,
        event_matches=pitch.event_matches,
        sustain_stability=pitch.sustain_stability,
        confidence=round((pitch.confidence + rhythm.confidence) / 2, 2),
        source=source,
        analysis_version=pitch.analysis_version,
    )


def _analysis_from_payload(payload: dict[str, object], source: str) -> AttemptAnalysis:
    return AttemptAnalysis(
        pitch_score=_coerce_score(payload.get("pitch_score")),
        rhythm_score=_coerce_score(payload.get("rhythm_score")),
        detected_notes=[
            DetectedNote(**note)
            for note in payload.get("detected_notes", [])
            if isinstance(note, dict)
        ],
        timing_errors=[
            TimingError(**error)
            for error in payload.get("timing_errors", [])
            if isinstance(error, dict)
        ],
        tone_score=_coerce_score(payload.get("tone_score")),
        event_matches=[
            EventMatch(**event)
            for event in payload.get("event_matches", [])
            if isinstance(event, dict)
        ],
        sustain_stability=float(payload.get("sustain_stability") or 0),
        confidence=float(payload.get("confidence") or 0),
        source=source,
        analysis_version=str(payload.get("analysis_version") or "v1"),
    )


def _coerce_score(value: object) -> int:
    try:
        return max(0, min(100, int(value)))
    except (TypeError, ValueError):
        return 0


def _expected_note_for_exercise(exercise_id: str) -> str:
    task_targets = get_task_targets(exercise_id)
    expected_notes = task_targets.get("expected_notes") if task_targets else None
    if isinstance(expected_notes, list) and expected_notes:
        first_note = expected_notes[0]
        if isinstance(first_note, str) and first_note:
            return first_note

    lowered = exercise_id.lower()
    note_aliases = {
        "fsharp": "F#",
        "bb": "Bb",
        "ab": "Ab",
        "gb": "Gb",
        "g": "G",
        "a": "A",
        "b": "B",
        "c": "C",
        "d": "D",
        "e": "E",
        "f": "F",
    }
    for alias, note in note_aliases.items():
        if f"_{alias}" in lowered or lowered.endswith(alias):
            return note
    return "G"


def _target_bpm_for_exercise(exercise_id: str) -> int:
    task_targets = get_task_targets(exercise_id)
    rhythm_target = task_targets.get("rhythm_target") if task_targets else None
    if isinstance(rhythm_target, str) and rhythm_target:
        mapped_bpm = _bpm_for_rhythm_target(rhythm_target)
        if mapped_bpm is not None:
            return mapped_bpm

    day_number = _extract_day_number(exercise_id)
    return 56 + min(day_number, 7) * 4


def _rhythm_target_for_exercise(exercise_id: str) -> str:
    task_targets = get_task_targets(exercise_id)
    rhythm_target = task_targets.get("rhythm_target") if task_targets else None
    if isinstance(rhythm_target, str) and rhythm_target:
        return rhythm_target
    return "quarter_note"


def _bpm_for_rhythm_target(rhythm_target: str) -> int | None:
    return {
        "long_tone": 50,
        "quarter_note": 60,
        "half_note": 52,
        "quarter_rest": 58,
        "eighth_notes": 72,
        "dotted_half_note": 48,
        "count_4_4": 64,
        "weekly_review": 66,
        "syncopation_intro": 76,
    }.get(rhythm_target)


def _extract_day_number(exercise_id: str) -> int:
    marker = "day_"
    if marker not in exercise_id:
        return 1

    suffix = exercise_id.split(marker, maxsplit=1)[1]
    digits = "".join(character for character in suffix[:2] if character.isdigit())
    if not digits:
        return 1
    return max(1, int(digits))
