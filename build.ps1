param([string]$ProjectRoot = $PSScriptRoot)
$ErrorActionPreference = 'Stop'
$mainPath = Join-Path $ProjectRoot '710Hub.lua'
$source = [IO.File]::ReadAllText($mainPath)
$parts = @{
    CORE = "local M = (function()`n" + [IO.File]::ReadAllText((Join-Path $ProjectRoot 'Maintenance.lua')).TrimEnd() + "`nend)()(S, os.clock)`nM:pause(`"Respawn`", true)"
    RUNTIME = [IO.File]::ReadAllText((Join-Path $ProjectRoot 'MaintenanceRuntime.fragment.lua')).TrimEnd()
    UI = [IO.File]::ReadAllText((Join-Path $ProjectRoot 'MaintenanceUI.fragment.lua')).TrimEnd()
    DETECTOR = "local BossDetector = (function()`n" + [IO.File]::ReadAllText((Join-Path $ProjectRoot 'BossDetection.lua')).TrimEnd() + "`nend)()(workspace, Players, S)"
    MENU = [IO.File]::ReadAllText((Join-Path $ProjectRoot 'MenuShell.fragment.lua')).TrimEnd()
}
foreach ($name in @('CORE', 'RUNTIME', 'UI', 'MENU', 'DETECTOR')) {
    $pattern = '(?s)-- BEGIN MAINTENANCE ' + $name + '\r?\n.*?-- END MAINTENANCE ' + $name
    if ([regex]::Matches($source, $pattern).Count -ne 1) { throw "Expected exactly one $name block" }
    $replacement = "-- BEGIN MAINTENANCE $name`n" + $parts[$name] + "`n-- END MAINTENANCE $name"
    $source = [regex]::Replace($source, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($match) $replacement })
}
[IO.File]::WriteAllText($mainPath, $source, [Text.UTF8Encoding]::new($false))
Write-Output '710Hub.lua rebuilt with embedded maintenance modules.'
