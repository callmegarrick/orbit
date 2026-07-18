# Orbit local server - serves the app at http://localhost:8123/
# Uses only built-in Windows components; no installs needed.
param([int]$Port = 8123)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$prefix = "http://localhost:$Port/"

# If another Orbit server is already running, just exit quietly.
try {
    $probe = New-Object System.Net.Sockets.TcpClient
    $probe.Connect("127.0.0.1", $Port)
    $probe.Close()
    Write-Host "Orbit is already running at $prefix"
    exit 0
} catch { }

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
$listener.Start()
Write-Host "Orbit is serving $root at $prefix (the installed app keeps working even if you close this window)"

$mime = @{
    ".html" = "text/html; charset=utf-8"
    ".js"   = "text/javascript; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".svg"  = "image/svg+xml"
    ".png"  = "image/png"
    ".ico"  = "image/x-icon"
    ".webmanifest" = "application/manifest+json"
}

while ($listener.IsListening) {
    try {
        $ctx = $listener.GetContext()
        $req = $ctx.Request
        $res = $ctx.Response
        $path = $req.Url.AbsolutePath.TrimStart("/")
        if ([string]::IsNullOrEmpty($path)) { $path = "index.html" }
        $file = Join-Path $root $path
        # keep requests inside the app folder
        $full = [System.IO.Path]::GetFullPath($file)
        if (-not $full.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path $full -PathType Leaf)) {
            $res.StatusCode = 404
            $bytes = [System.Text.Encoding]::UTF8.GetBytes("Not found")
        } else {
            $ext = [System.IO.Path]::GetExtension($full).ToLower()
            $type = $mime[$ext]
            if ($type) { $res.ContentType = $type }
            $res.Headers.Add("Cache-Control", "no-cache")
            $bytes = [System.IO.File]::ReadAllBytes($full)
        }
        $res.ContentLength64 = $bytes.Length
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
        $res.OutputStream.Close()
    } catch {
        # keep serving on individual request errors
    }
}
