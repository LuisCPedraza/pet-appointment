param(
  [switch]$SkipTests
)

$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Push-Location $repoRoot

try {
  if (-not $SkipTests) {
    Write-Host '>> Running flutter test --coverage'
    flutter test --coverage
    if ($LASTEXITCODE -ne 0) {
      throw "flutter test --coverage failed with exit code $LASTEXITCODE"
    }
  }

  $lcovPath = Join-Path (Get-Location) 'coverage/lcov.info'
  if (-not (Test-Path $lcovPath)) {
    throw "Coverage file not found at $lcovPath"
  }

  $outputDir = Join-Path (Get-Location) 'coverage/html'

  $genhtmlCmd = Get-Command genhtml -ErrorAction SilentlyContinue
  if ($null -ne $genhtmlCmd) {
    Write-Host '>> Generating HTML with genhtml'
    & $genhtmlCmd.Source $lcovPath -o $outputDir
    if ($LASTEXITCODE -ne 0) {
      throw "genhtml failed with exit code $LASTEXITCODE"
    }

    Write-Host ">> Coverage HTML generated: $outputDir/index.html"
    exit 0
  }

  $reportGeneratorCmd = Get-Command reportgenerator -ErrorAction SilentlyContinue
  if ($null -ne $reportGeneratorCmd) {
    Write-Host '>> Generating HTML with reportgenerator (PATH)'
    & $reportGeneratorCmd.Source "-reports:$lcovPath" "-targetdir:$outputDir" '-reporttypes:Html'
    if ($LASTEXITCODE -ne 0) {
      throw "reportgenerator failed with exit code $LASTEXITCODE"
    }

    Write-Host ">> Coverage HTML generated: $outputDir/index.html"
    exit 0
  }

  $wingetPackagesRoot = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages'
  $wingetReportGenerator = $null

  if (Test-Path $wingetPackagesRoot) {
    $wingetPkg = Get-ChildItem -Path $wingetPackagesRoot -Directory -Filter 'DanielPalme.ReportGenerator*' |
      Sort-Object LastWriteTime -Descending |
      Select-Object -First 1

    if ($null -ne $wingetPkg) {
      $candidate = Join-Path $wingetPkg.FullName 'net47\ReportGenerator.exe'
      if (Test-Path $candidate) {
        $wingetReportGenerator = $candidate
      }
    }
  }

  if ($null -ne $wingetReportGenerator) {
    Write-Host '>> Generating HTML with reportgenerator (winget path)'
    & $wingetReportGenerator "-reports:$lcovPath" "-targetdir:$outputDir" '-reporttypes:Html'
    if ($LASTEXITCODE -ne 0) {
      throw "reportgenerator (winget path) failed with exit code $LASTEXITCODE"
    }

    Write-Host ">> Coverage HTML generated: $outputDir/index.html"
    exit 0
  }

  throw 'No se encontro genhtml ni reportgenerator. Instala lcov/genhtml o ReportGenerator antes de ejecutar este script.'
}
finally {
  Pop-Location
}
