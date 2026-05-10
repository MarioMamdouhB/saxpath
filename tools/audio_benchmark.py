from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


REPO_ROOT = Path(__file__).resolve().parents[1]
AUDIO_ENGINE_ROOT = REPO_ROOT / "services" / "audio-engine"
if str(AUDIO_ENGINE_ROOT) not in sys.path:
    sys.path.insert(0, str(AUDIO_ENGINE_ROOT))

from app.analysis import analyze_pitch_wav, analyze_rhythm_wav  # noqa: E402


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Benchmark local audio recordings against the current pitch/rhythm heuristics."
    )
    parser.add_argument(
        "--manifest",
        type=Path,
        required=True,
        help="Path to a JSON manifest describing recordings and expectations.",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Emit the full benchmark result as JSON.",
    )
    args = parser.parse_args()

    manifest_path = args.manifest.resolve()
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    if not isinstance(manifest, list):
        raise SystemExit("Benchmark manifest must be a JSON array.")

    results = [benchmark_entry(manifest_path.parent, entry) for entry in manifest]
    failures = [result for result in results if not result["passed"]]

    if args.json:
        print(json.dumps(results, ensure_ascii=False, indent=2))
    else:
        print_summary(results)

    if failures:
        print(f"\nBenchmark failures: {len(failures)}/{len(results)}")
        return 1

    print(f"\nAll benchmark entries passed: {len(results)}/{len(results)}")
    return 0


def benchmark_entry(base_dir: Path, entry: Any) -> dict[str, Any]:
    if not isinstance(entry, dict):
        raise ValueError("Each manifest entry must be an object.")

    relative_path = entry.get("path")
    if not isinstance(relative_path, str) or not relative_path:
        raise ValueError("Each manifest entry must include a non-empty 'path'.")

    file_path = (base_dir / relative_path).resolve()
    wav_bytes = file_path.read_bytes()

    expected_note = _string_value(entry, "expected_note", default="G")
    rhythm_target = _string_value(entry, "rhythm_target", default="quarter_note")
    bpm = _int_value(entry, "bpm", default=60)
    min_pitch_score = _int_value(entry, "min_pitch_score", default=0)
    min_rhythm_score = _int_value(entry, "min_rhythm_score", default=0)
    label = _string_value(entry, "label", default=file_path.name)

    pitch = analyze_pitch_wav(wav_bytes, expected_note=expected_note)
    rhythm = analyze_rhythm_wav(
        wav_bytes,
        bpm=bpm,
        rhythm_target=rhythm_target,
    )

    passed = (
        pitch.pitch_score >= min_pitch_score
        and rhythm.rhythm_score >= min_rhythm_score
    )

    return {
        "label": label,
        "path": str(file_path),
        "expected_note": expected_note,
        "rhythm_target": rhythm_target,
        "bpm": bpm,
        "pitch_score": pitch.pitch_score,
        "detected_note": pitch.detected_notes[0].note
        if pitch.detected_notes
        else None,
        "detected_frequency_hz": pitch.detected_notes[0].frequency_hz
        if pitch.detected_notes
        else None,
        "rhythm_score": rhythm.rhythm_score,
        "timing_errors": [
            {
                "onset_seconds": error.onset_seconds,
                "expected_seconds": error.expected_seconds,
                "error_ms": error.error_ms,
            }
            for error in rhythm.timing_errors
        ],
        "min_pitch_score": min_pitch_score,
        "min_rhythm_score": min_rhythm_score,
        "passed": passed,
    }


def print_summary(results: list[dict[str, Any]]) -> None:
    for result in results:
        status = "PASS" if result["passed"] else "FAIL"
        print(
            f"[{status}] {result['label']} | "
            f"pitch={result['pitch_score']} ({result['detected_note']}) | "
            f"rhythm={result['rhythm_score']} | "
            f"target={result['expected_note']} @ {result['bpm']} bpm / {result['rhythm_target']}"
        )


def _string_value(entry: dict[str, Any], key: str, *, default: str) -> str:
    value = entry.get(key, default)
    return value if isinstance(value, str) and value else default


def _int_value(entry: dict[str, Any], key: str, *, default: int) -> int:
    value = entry.get(key, default)
    return int(value) if isinstance(value, (int, float)) else default


if __name__ == "__main__":
    raise SystemExit(main())
