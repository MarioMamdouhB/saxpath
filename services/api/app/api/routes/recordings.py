from pathlib import Path

from fastapi import APIRouter, File, HTTPException, UploadFile
from fastapi.responses import FileResponse

from app.schemas.recording import RecordingResponse
from app.services.recordings import get_recording, save_recording_upload

router = APIRouter(prefix="/recordings", tags=["recordings"])


@router.post("", response_model=RecordingResponse)
def upload_recording(file: UploadFile = File(...)) -> RecordingResponse:
    try:
        return save_recording_upload(file)
    except (OSError, ValueError, EOFError) as exc:
        raise HTTPException(status_code=400, detail="Invalid WAV recording.") from exc


@router.get("/{recording_id}/file")
def download_recording(recording_id: str) -> FileResponse:
    recording = get_recording(recording_id)
    if recording is None:
        raise HTTPException(status_code=404, detail="Recording not found.")

    path = Path(recording.storage_path)
    if not path.exists():
        raise HTTPException(status_code=404, detail="Recording file not found.")

    return FileResponse(
        path,
        media_type=recording.content_type,
        filename=recording.filename,
    )
