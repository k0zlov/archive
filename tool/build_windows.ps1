param(
  [string]$SigningKey = "$PSScriptRoot\..\.release-keys\windows-update.key",
  [string]$NotesFile = '',
  [string]$Iscc = '',
  [int]$MinimumSupportedBuild = 1,
  [switch]$InstallerOnly
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'windows_runtime.ps1')
$root = (Resolve-Path "$PSScriptRoot\..").Path
if ($PSVersionTable.PSVersion.Major -ge 6 -and -not $IsWindows) { throw 'Build on Windows.' }
$pubspec = Get-Content "$root\archive_flutter\pubspec.yaml" -Raw
$match = [regex]::Match($pubspec, '(?m)^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$')
if (-not $match.Success) { throw 'Use a version such as 1.0.1+2 in archive_flutter/pubspec.yaml.' }
$version = $match.Groups[1].Value
$build = $match.Groups[2].Value
foreach ($part in ($version.Split('.') + @($build))) {
  if ([int]$part -lt 0 -or [int]$part -gt 65535) { throw 'Windows version components must be 0..65535.' }
}
if ([int]$build -lt 1) { throw 'Build must be positive and increase for each release.' }
if (-not $InstallerOnly) {
  if (-not (Test-Path $SigningKey)) { throw 'Signing key missing. Use -InstallerOnly to build without moving the key from Mac.' }
  $SigningKey = (Resolve-Path $SigningKey).Path
}
if ($NotesFile) { $NotesFile = (Resolve-Path $NotesFile).Path }
if (-not $Iscc) {
  $command = Get-Command ISCC.exe -ErrorAction SilentlyContinue
  if ($command) { $Iscc = $command.Source }
  else {
    $locations = @("${env:ProgramFiles(x86)}", "$env:ProgramFiles", "$env:LOCALAPPDATA\Programs")
    $found = @($locations | ForEach-Object {
      Get-ChildItem "$_\Inno Setup*\ISCC.exe" -ErrorAction SilentlyContinue
    }) | Sort-Object FullName | Select-Object -Last 1
    if ($found) { $Iscc = $found.FullName }
  }
}
if (-not $Iscc -or -not (Test-Path $Iscc)) { throw 'Install Inno Setup and specify -Iscc if needed.' }
Push-Location "$root\archive_flutter"
try {
  & flutter pub get
  if ($LASTEXITCODE -ne 0) { throw 'Dependency installation failed.' }
  & dart run tool/generate_app_icons.dart
  if ($LASTEXITCODE -ne 0) { throw 'Desktop icon generation failed.' }
  & flutter build windows --release --target lib/main.dart
  if ($LASTEXITCODE -ne 0) { throw 'Flutter Windows build failed.' }
} finally { Pop-Location }
$bundle = "$root\archive_flutter\build\windows\x64\runner\Release"
if (-not (Test-Path "$bundle\archive_flutter.exe")) { throw 'Windows x64 build output missing.' }
# Bundle the redistributable runtime app-locally, including for fresh PCs.
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$installations = @(& $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath)
if ($LASTEXITCODE -ne 0 -or $installations.Count -ne 1) { throw 'Visual Studio C++ toolchain was not found.' }
$vs = $installations[0].Trim()
$crt = Find-VisualCppRuntime -RedistRoot (Join-Path $vs 'VC\Redist\MSVC')
Write-Host "Visual C++ runtime: $crt"
Copy-Item (Join-Path $crt '*.dll') $bundle -Force
$output = "$root\dist\windows"
New-Item -ItemType Directory -Path $output -Force | Out-Null
& $Iscc "/DAppVersion=$version" "/DAppBuild=$build" "/DSourceDir=$bundle" "/DOutputDir=$output" "$root\installer\windows\archive.iss"
if ($LASTEXITCODE -ne 0) { throw 'Installer compilation failed.' }
$installer = "$output\Archive-Setup-$version-$build-x64.exe"
if ($InstallerOnly) {
  Write-Host "Installer: $installer"
  Write-Host 'Sign and publish this installer on the Mac as described in docs/windows-releases.md.'
  return
}
Push-Location "$root\archive_shared"
try {
  $releaseArgs = @('run', 'tool/windows_release.dart', 'publish', $installer, $version, $build, $SigningKey, "$output\server")
  $notesArgument = if ($NotesFile) { $NotesFile } else { '-' }
  $releaseArgs += @($notesArgument, [string]$MinimumSupportedBuild)
  & dart @releaseArgs
  if ($LASTEXITCODE -ne 0) { throw 'Release signing failed.' }
} finally { Pop-Location }
Write-Host "Installer: $installer"
Write-Host "Server package: $output\server"
