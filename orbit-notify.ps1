# Orbit morning nudge - native Windows toast, works with the browser fully closed.
# Reads the newest orbit-backup*.json (written by the app's auto-backup) and shows
# who is overdue, upcoming birthdays (7 days) and occasions (3 days).
# Run daily via setup-morning-toast.bat. ASCII-only file (PS 5.1 parses ANSI).
param(
    [string]$BackupPath = "",
    [switch]$Test
)

$ErrorActionPreference = "Stop"
$appUrl = "http://localhost:8123/"

function Find-Backup {
    if ($BackupPath -and (Test-Path $BackupPath)) { return (Get-Item $BackupPath) }
    $candidates = @()
    $dirs = @(
        $PSScriptRoot,
        (Join-Path $env:USERPROFILE "Documents"),
        (Join-Path $env:USERPROFILE "OneDrive\Documents"),
        (Join-Path $env:USERPROFILE "OneDrive"),
        (Join-Path $env:USERPROFILE "Downloads"),
        (Join-Path $env:USERPROFILE "Desktop")
    )
    foreach ($d in $dirs) {
        if ($d -and (Test-Path $d)) {
            $candidates += Get-ChildItem -Path $d -Filter "orbit-backup*.json" -File -ErrorAction SilentlyContinue
        }
    }
    if (-not $candidates) { return $null }
    return ($candidates | Sort-Object LastWriteTime -Descending | Select-Object -First 1)
}

function Esc-Xml([string]$s) {
    $s = $s -replace "&", "&amp;"
    $s = $s -replace "<", "&lt;"
    $s = $s -replace ">", "&gt;"
    $s = $s -replace '"', "&quot;"
    $s -replace "'", "&apos;"
}

function Show-Toast([string]$title, [string]$line1, [string]$line2) {
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
    [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType = WindowsRuntime] | Out-Null
    $t1 = Esc-Xml $title; $l1 = Esc-Xml $line1; $l2 = Esc-Xml $line2
    $xmlText = "<toast activationType=""protocol"" launch=""$appUrl""><visual><binding template=""ToastGeneric""><text>$t1</text><text>$l1</text><text>$l2</text></binding></visual></toast>"
    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($xmlText)
    $toast = New-Object Windows.UI.Notifications.ToastNotification($xml)
    $appId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show($toast)
}

if ($Test) {
    Show-Toast "Orbit - time to reach out" "Amma (4d overdue), Rohan (2d overdue)" "Priya's birthday in 3 days"
    Write-Host "TEST TOAST SHOWN"
    exit 0
}

$today = (Get-Date).Date
$file = Find-Backup

if (-not $file) {
    # No backup file yet - still give the daily nudge, generically.
    Show-Toast "Orbit - morning check-in" "Open Orbit to see who needs a hello today." "Tip: turn on auto-backup in Settings for named reminders."
    Write-Host "GENERIC TOAST (no orbit-backup*.json found)"
    exit 0
}

$json = Get-Content $file.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
$data = if ($json.PSObject.Properties["data"]) { $json.data } else { $json }

$overdue = @()
$bdays = @()
$occs = @()

foreach ($p in @($data.people)) {
    if ($null -eq $p -or -not $p.name) { continue }
    # snoozed people are skipped
    if ($p.snoozedUntil) {
        try { if ([datetime]::ParseExact($p.snoozedUntil, "yyyy-MM-dd", $null) -gt $today) { continue } } catch {}
    }
    # overdue check
    $last = $null
    foreach ($i in @($p.interactions)) {
        if ($i.date) {
            try {
                $d = [datetime]::ParseExact($i.date, "yyyy-MM-dd", $null)
                if ($null -eq $last -or $d -gt $last) { $last = $d }
            } catch {}
        }
    }
    if ($null -eq $last -and $p.createdAt) {
        try { $last = [datetime]::ParseExact($p.createdAt, "yyyy-MM-dd", $null) } catch {}
    }
    if ($last -and $p.cadence) {
        $late = ($today - $last).Days - [int]$p.cadence
        if ($late -ge 0) {
            $first = ($p.name -split " ")[0]
            $overdue += @{ name = $first; late = $late }
        }
    }
    # birthday within 7 days
    if ($p.birthday -and $p.birthday.Length -ge 5) {
        $md = $p.birthday.Substring($p.birthday.Length - 5)
        try {
            $bd = [datetime]::ParseExact("$($today.Year)-$md", "yyyy-MM-dd", $null)
            if ($bd -lt $today) { $bd = $bd.AddYears(1) }
            $du = ($bd - $today).Days
            if ($du -le 7) {
                $first = ($p.name -split " ")[0]
                $when = if ($du -eq 0) { "TODAY" } elseif ($du -eq 1) { "tomorrow" } else { "in $du days" }
                $bdays += "$first's birthday $when"
            }
        } catch {}
    }
}

# occasions within 3 days
try {
    foreach ($o in @($data.occasions)) {
        if ($null -eq $o -or -not $o.enabled) { continue }
        $next = $null
        if ($o.fixed) {
            $d = [datetime]::ParseExact("$($today.Year)-$($o.fixed)", "yyyy-MM-dd", $null)
            if ($d -lt $today) { $d = $d.AddYears(1) }
            $next = $d
        } elseif ($o.dates) {
            foreach ($prop in $o.dates.PSObject.Properties) {
                try {
                    $d = [datetime]::ParseExact($prop.Value, "yyyy-MM-dd", $null)
                    if ($d -ge $today -and ($null -eq $next -or $d -lt $next)) { $next = $d }
                } catch {}
            }
        }
        if ($next) {
            $du = ($next - $today).Days
            if ($du -le 3) {
                $when = if ($du -eq 0) { "TODAY" } elseif ($du -eq 1) { "tomorrow" } else { "in $du days" }
                $occs += "$($o.name) $when"
            }
        }
    }
} catch {}

# plans due today or tomorrow
try {
    foreach ($pl in @($data.plans)) {
        if ($null -eq $pl -or $pl.done -or -not $pl.date) { continue }
        try {
            $pd = [datetime]::ParseExact($pl.date, "yyyy-MM-dd", $null)
            $du = ($pd - $today).Days
            if ($du -ge 0 -and $du -le 1) {
                $when = if ($du -eq 0) { "TODAY" } else { "tomorrow" }
                $occs += "Plan: $($pl.title) $when"
            }
        } catch {}
    }
} catch {}

if (-not $overdue -and -not $bdays -and -not $occs) {
    Write-Host "ALL CLEAR - no toast needed"
    exit 0
}

$line1 = ""
if ($overdue) {
    $parts = @($overdue | Sort-Object { -$_.late } | Select-Object -First 3 | ForEach-Object {
        if ($_.late -gt 0) { "$($_.name) ($($_.late)d over)" } else { "$($_.name) (due)" }
    })
    $more = if ($overdue.Count -gt 3) { " +$($overdue.Count - 3) more" } else { "" }
    $line1 = "Say hello to: " + ($parts -join ", ") + $more
}
$line2 = (@($bdays + $occs) | Select-Object -First 2) -join "  |  "
if (-not $line1) { $line1 = $line2; $line2 = "" }

Show-Toast "Orbit - time to reach out" $line1 $line2
Write-Host "TOAST SHOWN: $line1 | $line2 (from $($file.Name))"
