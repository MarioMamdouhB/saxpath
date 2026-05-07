# Manual Testing

## Docker Compose

```bash
docker compose up --build
```

## Backend Checks

### Health

```bash
curl http://localhost:8000/health
```

### Daily Plan

```bash
curl http://localhost:8000/api/v1/daily-plan/today
```

### Lessons

```bash
curl http://localhost:8000/api/v1/lessons
```

### Attempts

```bash
curl -X POST http://localhost:8000/api/v1/attempts ^
  -H "Content-Type: application/json" ^
  -d "{\"exercise_id\":\"practice_day_01_001\",\"duration_seconds\":120,\"audio_url\":\"mock://local-recording.wav\"}"
```

## Backend Tests

```bash
cd services/api
pytest
```

## Flutter Commands

```bash
cd apps/mobile
flutter pub get
flutter analyze
flutter run
```

## UI Checklist

- Home screen shows greeting, subtitle, progress, and 4 tasks
- `ابدأ تمرين اليوم` opens the note lesson
- `استمع للنغمة` is visible as a placeholder action
- `التالي` moves from note lesson to rhythm lesson
- `التالي` moves from rhythm lesson to practice
- Practice screen shows phrase, BPM, timer, and three buttons
- `إنهاء التمرين` opens the results screen
- `العودة إلى الخطة` returns to the home screen
- Progress screen is reachable from home
