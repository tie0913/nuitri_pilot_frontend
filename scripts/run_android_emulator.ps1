param(
  [string]$ApiBaseUrl = "http://10.0.2.2:8000",
  [string]$EmulatorId = "Medium_Phone_API_36.0",
  [string]$DeviceId = "emulator-5554",
  [string]$PreloadBackendImages = "1",
  [string]$BackendImagesDir = "..\\nuitri_pilot_backend\\tests\\ai_eval\\images",
  [string]$DeviceImagesDir = "/sdcard/Download/nuitri_seed"
)

$ErrorActionPreference = "Stop"

function To-Bool {
  param(
    [object]$Value,
    [bool]$DefaultValue = $true
  )

  if ($null -eq $Value) {
    return $DefaultValue
  }

  if ($Value -is [bool]) {
    return [bool]$Value
  }

  $text = $Value.ToString().Trim().ToLowerInvariant()
  if ($text -in @("1", "true", "yes", "on", "`$true")) {
    return $true
  }
  if ($text -in @("0", "false", "no", "off", "`$false")) {
    return $false
  }

  return $DefaultValue
}

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$localPropsPath = Join-Path $projectRoot "android\local.properties"

if (-not (Test-Path $localPropsPath)) {
  throw "Missing android/local.properties at $localPropsPath"
}

$sdkLine = Select-String -Path $localPropsPath -Pattern '^sdk\.dir=' | Select-Object -First 1
if (-not $sdkLine) {
  throw "sdk.dir is missing in android/local.properties"
}

$sdkDir = $sdkLine.Line.Substring("sdk.dir=".Length) -replace "\\\\", "\"
$adb = Join-Path $sdkDir "platform-tools\adb.exe"

if (-not (Test-Path $adb)) {
  throw "adb not found at $adb"
}

function Wait-ForAndroidDevice {
  param(
    [string]$AdbPath,
    [string]$TargetDeviceId,
    [int]$TimeoutSeconds = 300
  )

  & $AdbPath start-server | Out-Null
  for ($elapsed = 0; $elapsed -lt $TimeoutSeconds; $elapsed += 2) {
    $state = ""
    try {
      $state = (& $AdbPath -s $TargetDeviceId get-state 2>$null).Trim()
    } catch {
      $state = ""
    }
    if ($state -eq "device") {
      $boot = ""
      try {
        $boot = (& $AdbPath -s $TargetDeviceId shell getprop sys.boot_completed 2>$null).Trim()
      } catch {
        $boot = ""
      }
      if ($boot -eq "1") {
        return
      }
    }
    if (($elapsed % 20) -eq 0) {
      try {
        & $AdbPath reconnect offline | Out-Null
      } catch {
        # keep retrying; emulator can be transiently unavailable
      }
    }
    Start-Sleep -Seconds 2
  }

  throw "Device $TargetDeviceId did not become ready within $TimeoutSeconds seconds."
}

function Ensure-AndroidDeviceInteractive {
  param(
    [string]$AdbPath,
    [string]$TargetDeviceId
  )

  # Wake + dismiss keyguard + open home so Flutter can attach to a visible UI.
  try { & $AdbPath -s $TargetDeviceId shell input keyevent KEYCODE_WAKEUP | Out-Null } catch {}
  Start-Sleep -Milliseconds 200
  try { & $AdbPath -s $TargetDeviceId shell wm dismiss-keyguard | Out-Null } catch {}
  Start-Sleep -Milliseconds 200
  try { & $AdbPath -s $TargetDeviceId shell input swipe 500 1700 500 400 250 | Out-Null } catch {}
  Start-Sleep -Milliseconds 200
  try { & $AdbPath -s $TargetDeviceId shell input keyevent 82 | Out-Null } catch {}
  Start-Sleep -Milliseconds 200
  try { & $AdbPath -s $TargetDeviceId shell input keyevent KEYCODE_HOME | Out-Null } catch {}
}

Push-Location $projectRoot
try {
  $doPreloadBackendImages = To-Bool -Value $PreloadBackendImages -DefaultValue $true

  $currentState = ""
  try {
    $currentState = (& $adb -s $DeviceId get-state 2>$null).Trim()
  } catch {
    $currentState = ""
  }
  if ($currentState -ne "device") {
    flutter emulators --launch $EmulatorId | Out-Null
  }

  Wait-ForAndroidDevice -AdbPath $adb -TargetDeviceId $DeviceId
  Ensure-AndroidDeviceInteractive -AdbPath $adb -TargetDeviceId $DeviceId

  if ($doPreloadBackendImages) {
    $backendDirPath = Join-Path $projectRoot $BackendImagesDir
    $resolvedBackendDir = Resolve-Path $backendDirPath -ErrorAction SilentlyContinue
    if ($null -ne $resolvedBackendDir) {
      & $adb -s $DeviceId shell "mkdir -p $DeviceImagesDir" | Out-Null
      $files = Get-ChildItem -Path $resolvedBackendDir -File | Where-Object {
        $_.Name -match '\.(jpg|jpeg|png|webp)$'
      }
      foreach ($f in $files) {
        & $adb -s $DeviceId push "$($f.FullName)" "$DeviceImagesDir/" | Out-Null
      }
      Write-Host "Preloaded $($files.Count) images to $DeviceImagesDir"
      try {
        $deviceCount = (& $adb -s $DeviceId shell "ls -1 $DeviceImagesDir | wc -l" 2>$null).Trim()
        if ($deviceCount) {
          Write-Host "Device folder count at ${DeviceImagesDir}: $deviceCount"
        }
      } catch {
        # best-effort verification only
      }
    } else {
      Write-Host "Skipping preload: backend image directory not found at $backendDirPath"
    }
  }

  flutter run -d $DeviceId --dart-define="API_BASE_URL=$ApiBaseUrl"
}
finally {
  Pop-Location
}
