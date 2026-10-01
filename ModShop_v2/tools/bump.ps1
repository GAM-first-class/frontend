param([string]$Root)

if (-not $Root) { $Root = Split-Path -Parent $PSScriptRoot }

$ErrorActionPreference = 'Stop'
$ver = Get-Date -Format 'yyyyMMddHHmmss'
$enc = New-Object System.Text.UTF8Encoding $false
$changed = @()

foreach ($f in Get-ChildItem -Path $Root -Filter '*.html' -File) {
    $c = [System.IO.File]::ReadAllText($f.FullName)
    $o = $c

    $link = [regex]'(<link\b[^>]*\bhref=")(css/[^"?]+)(\?v=[^"]*)?(")'
    $script = [regex]'(<script\b[^>]*\bsrc=")(js/[^"?]+)(\?v=[^"]*)?(")'

    $c = [regex]::Replace($c, $link, { param($m) $m.Groups[1].Value + $m.Groups[2].Value + '?v=' + $ver + $m.Groups[4].Value })
    $c = [regex]::Replace($c, $script, { param($m) $m.Groups[1].Value + $m.Groups[2].Value + '?v=' + $ver + $m.Groups[4].Value })

    if ($c -ne $o) {
        [System.IO.File]::WriteAllText($f.FullName, $c, $enc)
        $changed += $f.Name
    }
}

"cache-bust version: v=$ver"
"updated: " + $(if ($changed.Count) { $changed -join ', ' } else { 'none (already up to date)' })