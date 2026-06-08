# Run all script test files in headless Godot.
# Usage: Set $env:GODOT_EXE to an explicit Godot binary path if not in PATH.

param(
    [string]$godot = $env:GODOT_EXE
)

if (-not $godot) {
    $godot = "godot"
}

$scriptDir = Split-Path -Parent $PSCommandPath
$repoRoot = Split-Path -Parent (Split-Path -Parent $scriptDir)
$testDir = Join-Path $repoRoot "Mecha/tests"
$resultsPath = Join-Path $scriptDir "results.log"

if (-not (Test-Path $testDir)) {
    New-Item -ItemType Directory -Force -Path $testDir | Out-Null
}

if (-not (Test-Path $scriptDir)) {
    New-Item -ItemType Directory -Force -Path $scriptDir | Out-Null
}

$tests = Get-ChildItem -Path $testDir -Filter "test_*.gd" | Sort-Object Name

if ($tests.Count -eq 0) {
    Write-Error "No test scripts found in $testDir"
    exit 1
}

"Test suite started: $(Get-Date -Format 'u')" | Out-File -FilePath $resultsPath -Encoding utf8 -Force
$total = 0
$passed = 0
$failed = 0

foreach ($test in $tests) {
    $total++
    # Compatible with PowerShell 5.1 (which lacks [IO.Path]::GetRelativePath)
    $fullPath = $test.FullName
    if ($fullPath.StartsWith($repoRoot)) {
        $relativePath = $fullPath.Substring($repoRoot.Length).TrimStart('\\') -replace '\\','/'
    } else {
        $relativePath = $fullPath -replace '\\','/'
    } 
    $scriptPath = "res://$relativePath"

    Add-Content -Path $resultsPath -Value "=== Running $scriptPath ===" -Encoding utf8
    $executionOutput = & "$godot" --headless --quit -s "$scriptPath" 2>&1
    Add-Content -Path $resultsPath -Value $executionOutput -Encoding utf8
    $exitCode = $LASTEXITCODE

    Add-Content -Path $resultsPath -Value "Exit code: $exitCode" -Encoding utf8

    if ($exitCode -eq 0) {
        $passed++
    } else {
        $failed++
    }

    Add-Content -Path $resultsPath -Value "" -Encoding utf8
}

"Test suite finished: $(Get-Date -Format 'u')" | Tee-Object -FilePath $resultsPath -Append
"Total: $total, Passed: $passed, Failed: $failed" | Tee-Object -FilePath $resultsPath -Append

if ($failed -ne 0) {
    exit 1
}
