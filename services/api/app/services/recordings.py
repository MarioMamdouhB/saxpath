import shutil
import wave
from datetime import datetime, timezone
from pathlib import Path
from uuid import uuid4

from fastapi import UploadFile

from app.core.config import get_settings
from app.schemas.recording import RecordingResponse
from app.services import persistence


def get_recording_storage_dir() -> Path:
    settings = get_settings()
    root = Path(settings.recording_storage_dir)
    if not root.is_absolute():
        root = Path(__file__).resolve().parents[2] / root
    return root


def save_recording_upload(file: UploadFile) -> RecordingResponse:
    recording_id = f"rec_{uuid4().hex[:16]}"
    filename = _safe_filename(file.filename or f"{recording_id}.wav")
    if not filename.lower().endswith(".wav"):
        filename = f"{filename}.wav"

    storage_dir = get_recording_storage_dir()
    storage_dir.mkdir(parents=True, exist_ok=True)
    path = storage_dir / f"{recording_id}_{filename}"

    with path.open("wb") as output:
        shutil.copyfileobj(file.file, output)

    try:
        duration_seconds = _wav_duration_seconds(path)
    except (OSError, ValueError, EOFError, wave.Error):
        path.unlink(missing_ok=True)
        raise

    response = RecordingResponse(
        recording_id=recording_id,
        filename=filename,
        duration_seconds=duration_seconds,
        storage_path=str(path),
        playback_url=f"/api/v1/recordings/{recording_id}/file",
        content_type=file.content_type or "audio/wav",
        created_at=datetime.now(timezone.utc).isoformat(),
    )
    persistence.record_recording(response)
    return response


def get_recording(recording_id: str) -> RecordingResponse | None:
    return persistence.get_recording(recording_id)


def _wav_duration_seconds(path: Path) -> int:
    with wave.open(str(path), "rb") as wav_file:
        frames = wav_file.getnframes()
        frame_rate = wav_file.getframerate()
        duration = frames / frame_rate if frame_rate else 0
    return max(1, round(duration))


def _safe_filename(filename: str) -> str:
    safe = "".join(
        character
        for character in filename
        if character.isalnum() or character in {".", "_", "-"}
    )
    return safe or "recording.wav"
