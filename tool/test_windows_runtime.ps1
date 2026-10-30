$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'windows_runtime.ps1')

$root = Join-Path ([System.IO.Path]::GetTempPath()) ('archive-crt-test-' + [guid]::NewGuid())
$versions = @{}
function Add-RuntimeFixture {
  param([string]$Toolset, [string]$Architecture, [string]$Crt, [string]$Version, [switch]$Incomplete)
  $folder = Join-Path (Join-Path (Join-Path $root $Toolset) $Architecture) $Crt
  New-Item -ItemType Directory -Path $folder -Force | Out-Null
  foreach ($name in @('msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll')) {
    if ($Incomplete -and $name -eq 'vcruntime140_1.dll') { continue }
    [System.IO.File]::WriteAllBytes((Join-Path $folder $name), [byte[]]@(0))
  }
  $versions[(Join-Path $folder 'msvcp140.dll')] = [version]$Version
  return $folder
}
$readVersion = { param($path) return $versions[$path] }
try {
  $old = Add-RuntimeFixture -Toolset '14.44.35211' -Architecture x64 -Crt 'Microsoft.VC143.CRT' -Version '14.44.35211.0'
  $current = Add-RuntimeFixture -Toolset 'v145' -Architecture x64 -Crt 'Microsoft.VC145.CRT' -Version '14.50.35717.0'
  Add-RuntimeFixture -Toolset 'v146' -Architecture x86 -Crt 'Microsoft.VC146.CRT' -Version '14.60.1.0' | Out-Null
  Add-RuntimeFixture -Toolset 'v147' -Architecture x64 -Crt 'Microsoft.VC147.CRT' -Version '14.70.1.0' -Incomplete | Out-Null
  if ((Find-VisualCppRuntime -RedistRoot $root -ReadVersion $readVersion) -ne $current) { throw 'The current complete x64 v145 runtime must be selected.' }
  Remove-Item (Join-Path $root '14.44.35211') -Recurse -Force
  if ((Find-VisualCppRuntime -RedistRoot $root -ReadVersion $readVersion) -ne $current) { throw 'An alias-only Visual Studio layout must work.' }
  # File versions, not a numeric-looking directory name, determine the winner.
  $newer = Add-RuntimeFixture -Toolset 'not-a-version' -Architecture x64 -Crt 'Microsoft.VC145.CRT' -Version '14.51.1.0'
  if ((Find-VisualCppRuntime -RedistRoot $root -ReadVersion $readVersion) -ne $newer) { throw 'The newest DLL version must win.' }
  Remove-Item (Join-Path $root 'v145') -Recurse -Force
  Remove-Item (Join-Path $root 'not-a-version') -Recurse -Force
  $failed = $false
  try { Find-VisualCppRuntime -RedistRoot $root -ReadVersion $readVersion | Out-Null } catch { $failed = $true }
  if (-not $failed) { throw 'Missing or incomplete x64 runtime must be rejected.' }
  if ($env:OS -eq 'Windows_NT') {
    $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    $installations = @(& $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath)
    if ($LASTEXITCODE -ne 0 -or $installations.Count -ne 1) { throw 'Visual Studio C++ toolchain was not found.' }
    $actual = Find-VisualCppRuntime -RedistRoot (Join-Path $installations[0].Trim() 'VC\Redist\MSVC')
    Write-Host "Actual Windows x64 runtime: $actual"
  }
  Write-Host 'Visual C++ runtime selection tests passed (numeric, v145 alias, x86 and incomplete layouts).'
} finally {
  if (Test-Path -LiteralPath $root) { Remove-Item -LiteralPath $root -Recurse -Force }
}
