param(
  [Parameter(Mandatory = $true)][string]$IconPath,
  [Parameter(Mandatory = $true)][string]$ExecutablePath
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if ($env:OS -ne 'Windows_NT') { throw 'Native icon validation requires Windows.' }
$IconPath = (Resolve-Path -LiteralPath $IconPath).Path
$ExecutablePath = (Resolve-Path -LiteralPath $ExecutablePath).Path

Add-Type -AssemblyName System.Drawing
if (-not ('Archive.IconValidation' -as [type])) {
  Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
namespace Archive {
  public static class IconValidation {
    [DllImport("shell32.dll", CharSet = CharSet.Unicode, ExactSpelling = true, SetLastError = true)]
    public static extern uint ExtractIconExW(string path, int index,
      out IntPtr large, out IntPtr small, uint count);
    [DllImport("user32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool DestroyIcon(IntPtr icon);
  }
}
'@
}

function Get-IconPixels {
  param([IntPtr]$Handle)
  if ($Handle -eq [IntPtr]::Zero) { throw 'Windows returned an empty icon handle.' }
  $icon = [System.Drawing.Icon]::FromHandle($Handle)
  try {
    $bitmap = $icon.ToBitmap()
    try {
      $bytes = [byte[]]::new($bitmap.Width * $bitmap.Height * 4)
      $visible = 0
      for ($y = 0; $y -lt $bitmap.Height; $y++) {
        for ($x = 0; $x -lt $bitmap.Width; $x++) {
          $color = $bitmap.GetPixel($x, $y)
          $offset = ($y * $bitmap.Width + $x) * 4
          $bytes[$offset] = $color.R
          $bytes[$offset + 1] = $color.G
          $bytes[$offset + 2] = $color.B
          $bytes[$offset + 3] = $color.A
          if ($color.A -gt 0) { $visible++ }
        }
      }
      if ($visible -lt ($bitmap.Width * $bitmap.Height / 4)) {
        throw 'The extracted icon is empty or mostly transparent.'
      }
      return "$($bitmap.Width)x$($bitmap.Height):$([Convert]::ToBase64String($bytes))"
    } finally { $bitmap.Dispose() }
  } finally { $icon.Dispose() }
}

function Get-ShellIcons {
  param([string]$Path)
  $large = [IntPtr]::Zero
  $small = [IntPtr]::Zero
  try {
    $count = [Archive.IconValidation]::ExtractIconExW($Path, 0, [ref]$large, [ref]$small, 1)
    if ($count -ne 1) {
      throw "Windows could not extract the default icon from $Path (error $([Runtime.InteropServices.Marshal]::GetLastWin32Error()))."
    }
    return @((Get-IconPixels $large), (Get-IconPixels $small))
  } finally {
    if ($large -ne [IntPtr]::Zero) { [void][Archive.IconValidation]::DestroyIcon($large) }
    if ($small -ne [IntPtr]::Zero) { [void][Archive.IconValidation]::DestroyIcon($small) }
  }
}

# Use the Shell API, not an ICO parser: Explorer must extract the actual
# branded pixels from the EXE at both sizes, rather than a default Flutter icon.
$expected = Get-ShellIcons $IconPath
$actual = Get-ShellIcons $ExecutablePath
if ($expected.Count -ne 2 -or $actual.Count -ne 2 -or
    $expected[0] -cne $actual[0] -or $expected[1] -cne $actual[1]) {
  throw 'The executable default large/small icons do not match the Archive ICO.'
}
Write-Host 'Windows Shell extracted matching, visible Archive icons from the built executable (large and small).'
