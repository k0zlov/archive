function Find-VisualCppRuntime {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$RedistRoot,
    [scriptblock]$ReadVersion = {
      param([string]$DllPath)
      $info = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($DllPath)
      return [version]::new($info.FileMajorPart, $info.FileMinorPart, $info.FileBuildPart, $info.FilePrivatePart)
    }
  )
  if (-not (Test-Path -LiteralPath $RedistRoot -PathType Container)) {
    throw "Visual C++ redistributable directory is missing: $RedistRoot"
  }
  $candidates = @(
    foreach ($toolset in (Get-ChildItem -LiteralPath $RedistRoot -Directory)) {
      # Modern Visual Studio also uses aliases such as v145, not just 14.x.y.
      # Inspect actual x64 runtime files; directory names are not versions.
      $architecture = Join-Path $toolset.FullName 'x64'
      if (-not (Test-Path -LiteralPath $architecture -PathType Container)) { continue }
      foreach ($runtime in (Get-ChildItem -LiteralPath $architecture -Directory -Filter 'Microsoft.VC*.CRT')) {
        $complete = $true
        foreach ($name in @('msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll')) {
          if (-not (Test-Path -LiteralPath (Join-Path $runtime.FullName $name) -PathType Leaf)) { $complete = $false; break }
        }
        if (-not $complete) { continue }
        $version = [version](& $ReadVersion (Join-Path $runtime.FullName 'msvcp140.dll'))
        [pscustomobject]@{ Path = $runtime.FullName; Version = $version }
      }
    }
  )
  $selected = $candidates | Sort-Object -Property Version -Descending | Select-Object -First 1
  if (-not $selected) {
    throw "Complete Visual C++ x64 runtime DLLs were not found under: $RedistRoot"
  }
  return $selected.Path
}
