# nuitri_pilot_frontend

## Emulator-only local run

This project is configured for Android emulator-first development.

- Default API URL in app: `http://10.0.2.2:8000`
- Override API URL when needed: `--dart-define=API_BASE_URL=http://10.0.2.2:<PORT>`

### Start backend

From `nuitri_pilot_backend`:

```powershell
uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload
```

### Run frontend on emulator

From `nuitri_pilot_frontend`:

```powershell
.\scripts\run_android_emulator.ps1
```

The script will also preload image samples from:
`..\nuitri_pilot_backend\tests\ai_eval\images`
into emulator folder:
`/sdcard/Download/nuitri_seed`

Optional custom backend URL:

```powershell
.\scripts\run_android_emulator.ps1 -ApiBaseUrl "http://10.0.2.2:5007"
```

Disable image preload:

```powershell
.\scripts\run_android_emulator.ps1 -PreloadBackendImages $false
```

### Run tests on emulator (mobile-focused)

```powershell
.\scripts\test_android_emulator.ps1
```

This runs:
- `flutter test` (unit/widget tests)
- `flutter test integration_test -d emulator-5554` (integration tests on Android emulator)
