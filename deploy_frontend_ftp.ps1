# FTP Upload Script for EzCRM Frontend

$FtpServer   = "ftp://88.222.211.181"
$FtpUsername = "u547357606.app.ezflowcrm.com"
$FtpPassword = "i9|VoJewrp6?+]QU"
$LocalPath   = "I:\Upcoming Projects\Ezcrm\frontend\dist"
$RemotePath  = ""   # FTP root IS public_html on Hostinger — no prefix needed

if (-not (Test-Path $LocalPath)) { Write-Error "Build not found: $LocalPath"; exit 1 }

$credential = New-Object System.Net.NetworkCredential($FtpUsername, $FtpPassword)
$createdDirs = @{}

function Ensure-FtpDir {
    param([string]$remoteDirPath)
    if ($createdDirs[$remoteDirPath]) { return }
    try {
        $dirTarget = if ($remoteDirPath) { "$FtpServer/$remoteDirPath/" } else { "$FtpServer/" }
        $uri = [System.Uri]::new($dirTarget)
        $req = [System.Net.FtpWebRequest]::Create($uri)
        $req.Credentials = $credential
        $req.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
        $req.KeepAlive = $false
        $res = $req.GetResponse()
        $res.Close()
        Write-Host "  Created dir: $remoteDirPath"
    } catch { <# already exists — ignore #> }
    $createdDirs[$remoteDirPath] = $true
}

function Upload-FtpFile {
    param([string]$localFile, [string]$remotePath)
    # Ensure every ancestor directory exists
    $parts = $remotePath.Split('/')
    for ($i = 1; $i -lt $parts.Count; $i++) {
        $dirPath = if ($RemotePath) { "$RemotePath/" + ($parts[0..($i-1)] -join '/') } else { $parts[0..($i-1)] -join '/' }
        Ensure-FtpDir $dirPath
    }
    try {
        $target = if ($RemotePath) { "$FtpServer/$RemotePath/$remotePath" } else { "$FtpServer/$remotePath" }
        $uri = [System.Uri]::new($target)
        $req = [System.Net.FtpWebRequest]::Create($uri)
        $req.Credentials = $credential
        $req.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
        $req.UseBinary = $true
        $req.KeepAlive = $false
        $fs = [System.IO.File]::OpenRead($localFile)
        $us = $req.GetRequestStream()
        $fs.CopyTo($us)
        $fs.Close(); $us.Close()
        $res = $req.GetResponse()
        $res.Close()
        Write-Host "OK  $remotePath"
    } catch {
        Write-Error "FAIL $remotePath : $_"
    }
}

$files = Get-ChildItem -Path $LocalPath -Recurse -File
$displayTarget = if ($RemotePath) { "$FtpServer/$RemotePath" } else { $FtpServer }
Write-Host "Deploying $($files.Count) files to $displayTarget ..."

$ok = 0; $fail = 0
foreach ($file in $files) {
    $rel = $file.FullName.Substring($LocalPath.Length + 1).Replace('\', '/')
    try {
        Upload-FtpFile -localFile $file.FullName -remotePath $rel
        $ok++
    } catch { $fail++ }
    if (($ok + $fail) % 10 -eq 0) { Write-Host "  Progress: $($ok+$fail)/$($files.Count)" }
}

Write-Host ""
Write-Host "Done - $ok uploaded, $fail failed."
