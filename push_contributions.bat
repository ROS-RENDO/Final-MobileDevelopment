<# :
@echo off
setlocal
title GitHub Contribution Booster
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$script = [System.IO.File]::ReadAllText('%~f0'); & ([ScriptBlock]::Create($script)) %*"
set EXITCODE=%ERRORLEVEL%
if "%1"=="" (
    echo.
    echo Press any key to exit...
    pause >nul
)
exit /b %EXITCODE%
#>
param(
    [string]$Arg1 = "",
    [string]$Arg2 = "",
    [string]$Arg3 = ""
)

$ErrorActionPreference = "Continue"
$DEFAULT_REMOTE_URL = "https://github.com/ROS-RENDO/Final-MobileDevelopment.git"

function Write-Banner {
    Clear-Host
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "                GITHUB CONTRIBUTION BOOSTER & AUTO-PUSHER                       " -ForegroundColor Green
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host " Target Repo: $DEFAULT_REMOTE_URL" -ForegroundColor Magenta
    Write-Host " Fill your GitHub contribution graph with active green squares effortlessly!   " -ForegroundColor DarkGray
    Write-Host ""
}

function Test-GitInstalled {
    try {
        $gitVer = & git --version 2>$null
        if (-not $gitVer) {
            Write-Host "[ERROR] Git is not installed or not in your system PATH." -ForegroundColor Red
            Write-Host "Please install Git for Windows from https://git-scm.com/ and try again." -ForegroundColor Yellow
            return $false
        }
        return $true
    }
    catch {
        Write-Host "[ERROR] Failed to execute git command: $_" -ForegroundColor Red
        return $false
    }
}

function Get-GitBranch {
    $branch = (& git branch --show-current 2>$null)
    if (-not $branch) {
        $branch = "main"
    }
    return $branch.Trim()
}

function Ensure-GitRepo {
    if (-not (Test-Path -Path ".git")) {
        Write-Host "[*] No Git repository detected. Initializing new repository..." -ForegroundColor Yellow
        & git init | Out-Null
        & git branch -M main | Out-Null
    }
    
    # Auto-ensure default target remote origin
    $currentOrigin = (& git remote get-url origin 2>$null)
    if (-not $currentOrigin) {
        & git remote add origin $DEFAULT_REMOTE_URL | Out-Null
    } elseif ($currentOrigin -ne $DEFAULT_REMOTE_URL) {
        & git remote set-url origin $DEFAULT_REMOTE_URL | Out-Null
    }
}

function Show-StatusSummary {
    $userName = (& git config --get user.name 2>$null)
    $userEmail = (& git config --get user.email 2>$null)
    $remoteUrl = (& git remote get-url origin 2>$null)
    $branch = Get-GitBranch
    $commitCount = 0
    try {
        $countOutput = (& git rev-list --count HEAD 2>$null)
        if ($countOutput) { $commitCount = [int]$countOutput }
    } catch {}

    $displayUser = if ($userName) { $userName } else { "[NOT CONFIGURED]" }
    $displayEmail = if ($userEmail) { $userEmail } else { "[NOT CONFIGURED]" }
    Write-Host " Current Status:" -ForegroundColor DarkYellow
    Write-Host "   - User Name   : " -NoNewline; Write-Host $displayUser -ForegroundColor White
    Write-Host "   - User Email  : " -NoNewline; Write-Host $displayEmail -ForegroundColor White
    Write-Host "   - Branch      : " -NoNewline; Write-Host $branch -ForegroundColor White
    Write-Host "   - Remote (URL): " -NoNewline
    if ($remoteUrl) {
        Write-Host $remoteUrl -ForegroundColor Green
    } else {
        Write-Host "[Not Set - Commits will stay local until remote is set]" -ForegroundColor Yellow
    }
    Write-Host "   - Total Commits: " -NoNewline; Write-Host "$commitCount commits" -ForegroundColor Cyan
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
}

function Set-GitHubRemote {
    Write-Host "`n[ SETUP GITHUB REMOTE REPOSITORY ]" -ForegroundColor Cyan
    $currentUrl = (& git remote get-url origin 2>$null)
    if ($currentUrl) {
        Write-Host "Current Remote URL: $currentUrl" -ForegroundColor Yellow
        $choice = Read-Host "Do you want to change it? (Y/N)"
        if ($choice -ne "Y" -and $choice -ne "y") { return }
    }
    
    Write-Host "Enter your GitHub repository URL (HTTPS or SSH):" -ForegroundColor Cyan
    Write-Host "Example: https://github.com/ROS-RENDO/my-contributions.git" -ForegroundColor DarkGray
    $url = Read-Host "Repository URL"
    if ([string]::IsNullOrWhiteSpace($url)) {
        Write-Host "[!] Cancelled - No URL entered." -ForegroundColor Yellow
        return
    }
    
    if ($currentUrl) {
        & git remote set-url origin $url.Trim()
    } else {
        & git remote add origin $url.Trim()
    }
    
    Write-Host "[+] Remote origin set to: $($url.Trim())" -ForegroundColor Green
    
    $test = Read-Host "Test remote connection now? (Y/N)"
    if ($test -eq "Y" -or $test -eq "y") {
        Write-Host "Testing remote connection..." -ForegroundColor DarkGray
        & git ls-remote origin | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[+] Connection successful!" -ForegroundColor Green
        } else {
            Write-Host "[!] Could not query remote. Ensure repository exists on GitHub and permissions are granted." -ForegroundColor Yellow
        }
    }
}

function Push-ToGitHub {
    $remoteUrl = (& git remote get-url origin 2>$null)
    if (-not $remoteUrl) {
        & git remote add origin $DEFAULT_REMOTE_URL | Out-Null
        $remoteUrl = $DEFAULT_REMOTE_URL
        Write-Host "[+] Configured remote origin to: $remoteUrl" -ForegroundColor Green
    }
    
    $branch = Get-GitBranch
    Write-Host "`n[*] Pushing commits to GitHub ($branch branch)..." -ForegroundColor Cyan
    
    $pushOutput = (& git push -u origin $branch 2>&1)
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n[SUCCESS] Successfully pushed all commits to GitHub!" -ForegroundColor Green
        Write-Host "Check your GitHub profile to see your updated green contribution grid!" -ForegroundColor Cyan
        Write-Host "Tip: It can take 1-5 minutes for GitHub to re-index and refresh your contribution squares." -ForegroundColor DarkGray
    } else {
        Write-Host "`n[!] Push encountered an error:" -ForegroundColor Red
        $pushOutput | ForEach-Object { Write-Host "   $_" -ForegroundColor DarkRed }
        
        Write-Host "`nTroubleshooting options:" -ForegroundColor Yellow
        Write-Host "1. If GitHub rejected because remote contains commits you don't have: Pull with rebase."
        Write-Host "2. If this is a fresh dedicated contribution repository: Force push to overwrite remote."
        Write-Host "3. If authentication failed: Sign in via GitHub browser prompt or Personal Access Token (PAT)."
        
        $action = Read-Host "Choose an action: [1] Pull & Rebase, [2] Force Push (--force), [3] Skip push for now"
        if ($action -eq "1") {
            Write-Host "Pulling remote changes..." -ForegroundColor Cyan
            & git pull --rebase origin $branch
            Write-Host "Re-attempting push..." -ForegroundColor Cyan
            & git push -u origin $branch
        } elseif ($action -eq "2") {
            Write-Host "Force pushing to origin $branch..." -ForegroundColor Yellow
            & git push -u origin $branch --force
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[SUCCESS] Force push completed successfully!" -ForegroundColor Green
            }
        }
    }
}

function Make-SingleCommit {
    param(
        [string]$Message,
        [string]$DateStr = ""
    )
    
    $logFile = "contributions.log"
    $timestamp = if ($DateStr) { $DateStr } else { (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") }
    $guid = [System.Guid]::NewGuid().ToString()
    $line = "[$timestamp] $guid - $Message"
    Add-Content -Path $logFile -Value $line -Encoding utf8
    
    & git add $logFile | Out-Null
    
    if ($DateStr) {
        $env:GIT_AUTHOR_DATE = $DateStr
        $env:GIT_COMMITTER_DATE = $DateStr
        & git commit -m "$Message" --date "$DateStr" | Out-Null
        $env:GIT_AUTHOR_DATE = ""
        $env:GIT_COMMITTER_DATE = ""
    } else {
        & git commit -m "$Message" | Out-Null
    }
}

function Start-TodayBurst {
    param([int]$Count = 0)
    
    Write-Host "`n[ TODAY'S BURST MODE ]" -ForegroundColor Cyan
    Write-Host "Generate multiple commits for today to boost your contribution count.`n" -ForegroundColor DarkGray
    
    if ($Count -le 0) {
        $inputCount = Read-Host "How many commits do you want to generate for today? (Default: 10)"
        if ([string]::IsNullOrWhiteSpace($inputCount)) {
            $Count = 10
        } else {
            $Count = [int]$inputCount
        }
    }
    
    if ($Count -le 0) {
        Write-Host "[!] Invalid count. Aborting." -ForegroundColor Red
        return
    }
    
    Write-Host "`n[*] Generating $Count commits for today..." -ForegroundColor Cyan
    for ($i = 1; $i -le $Count; $i++) {
        $now = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        $msg = "Contribution update: $now [#$i of $Count]"
        Make-SingleCommit -Message $msg
        
        $percent = [math]::Round(($i / $Count) * 100)
        Write-Progress -Activity "Generating Commits" -Status "$i of $Count completed ($percent%)" -PercentComplete $percent
    }
    Write-Progress -Activity "Generating Commits" -Completed
    Write-Host "[+] Generated $Count commits successfully!" -ForegroundColor Green
    
    Push-ToGitHub
}

function Start-HistoryBackdate {
    param(
        [int]$Days = 0,
        [int]$MinPerDay = 2,
        [int]$MaxPerDay = 5,
        [bool]$SkipWeekends = $false,
        [bool]$Interactive = $true
    )
    
    Write-Host "`n[ HISTORY STREAK BOOSTER (FILL GREEN SQUARES) ]" -ForegroundColor Cyan
    Write-Host "Backdate commits across past days to fill past contribution grid squares!`n" -ForegroundColor DarkGray
    
    if ($Days -le 0) {
        Write-Host "Common options: [30] 1 Month | [90] 3 Months | [180] 6 Months | [365] Full Year" -ForegroundColor Yellow
        $daysInput = Read-Host "How many past days to fill? (Default: 30)"
        if ([string]::IsNullOrWhiteSpace($daysInput)) {
            $Days = 30
        } else {
            $Days = [int]$daysInput
        }
    }
    
    if ($Days -le 0) {
        Write-Host "[!] Invalid number of days. Aborting." -ForegroundColor Red
        return
    }
    
    if ($Interactive) {
        Write-Host "`nSelect Green Square Intensity:" -ForegroundColor Yellow
        Write-Host "  [1] Light Green    (1 - 2 commits / day)"
        Write-Host "  [2] Medium Green   (2 - 5 commits / day) [Recommended]"
        Write-Host "  [3] Dark Green     (6 - 12 commits / day)"
        Write-Host "  [4] Custom Range"
        $intensity = Read-Host "Select intensity (1-4, Default: 2)"
        
        switch ($intensity) {
            "1" { $MinPerDay = 1; $MaxPerDay = 2 }
            "3" { $MinPerDay = 6; $MaxPerDay = 12 }
            "4" {
                $minIn = Read-Host "Minimum commits per day (e.g. 1)"
                $maxIn = Read-Host "Maximum commits per day (e.g. 8)"
                $MinPerDay = [Math]::Max(1, [int]$minIn)
                $MaxPerDay = [Math]::Max($MinPerDay, [int]$maxIn)
            }
            Default { $MinPerDay = 2; $MaxPerDay = 5 }
        }
        
        $weekendChoice = Read-Host "Skip weekends? (Y/N, Default: N - include weekends for full coverage)"
        if ($weekendChoice -eq "Y" -or $weekendChoice -eq "y") {
            $SkipWeekends = $true
        } else {
            $SkipWeekends = $false
        }
    }
    
    $startDate = (Get-Date).AddDays(-$Days)
    $today = Get-Date
    $totalCommits = 0
    
    Write-Host "`n[*] Simulating and generating historical commits from $($startDate.ToString('yyyy-MM-dd')) to $($today.ToString('yyyy-MM-dd'))..." -ForegroundColor Cyan
    
    for ($d = 0; $d -le $Days; $d++) {
        $currentDate = $startDate.AddDays($d)
        
        if ($SkipWeekends -and ($currentDate.DayOfWeek -eq [DayOfWeek]::Saturday -or $currentDate.DayOfWeek -eq [DayOfWeek]::Sunday)) {
            continue
        }
        
        $dailyCount = Get-Random -Minimum $MinPerDay -Maximum ($MaxPerDay + 1)
        
        for ($c = 1; $c -le $dailyCount; $c++) {
            $hour = Get-Random -Minimum 9 -Maximum 22
            $minute = Get-Random -Minimum 0 -Maximum 60
            $second = Get-Random -Minimum 0 -Maximum 60
            
            $commitDate = $currentDate.Date.AddHours($hour).AddMinutes($minute).AddSeconds($second)
            $isoDate = $commitDate.ToString("yyyy-MM-ddTHH:mm:ss")
            $msg = "Activity log: $($commitDate.ToString('yyyy-MM-dd HH:mm:ss')) [#$c of $dailyCount]"
            
            Make-SingleCommit -Message $msg -DateStr $isoDate
            $totalCommits++
        }
        
        $percent = [math]::Round((($d + 1) / ($Days + 1)) * 100)
        Write-Progress -Activity "Backdating Commits" -Status "Day $($d+1) of $($Days+1) ($($currentDate.ToString('yyyy-MM-dd'))) - $totalCommits commits so far" -PercentComplete $percent
    }
    Write-Progress -Activity "Backdating Commits" -Completed
    
    Write-Host "`n[+] Created $totalCommits historical commits covering $Days days!" -ForegroundColor Green
    
    Push-ToGitHub
}

function Start-CustomRange {
    Write-Host "`n[ CUSTOM DATE RANGE BACKDATE ]" -ForegroundColor Cyan
    Write-Host "Specify exact start and end dates to fill with contributions.`n" -ForegroundColor DarkGray
    
    $startInput = Read-Host "Start Date (YYYY-MM-DD, e.g. 2026-01-01)"
    $endInput = Read-Host "End Date   (YYYY-MM-DD, e.g. 2026-06-30)"
    
    $startParsed = [DateTime]::MinValue
    $endParsed = [DateTime]::MinValue
    
    if (-not [DateTime]::TryParse($startInput, [ref]$startParsed) -or -not [DateTime]::TryParse($endInput, [ref]$endParsed)) {
        Write-Host "[!] Invalid date format. Please use YYYY-MM-DD." -ForegroundColor Red
        return
    }
    
    if ($startParsed -gt $endParsed) {
        Write-Host "[!] Start date cannot be after end date." -ForegroundColor Red
        return
    }
    
    $commitsPerDayInput = Read-Host "Commits per day (Default: 3)"
    $commitsPerDay = if ([string]::IsNullOrWhiteSpace($commitsPerDayInput)) { 3 } else { [int]$commitsPerDayInput }
    if ($commitsPerDay -lt 1) { $commitsPerDay = 1 }
    
    $daysDiff = [int]($endParsed - $startParsed).TotalDays
    $totalCommits = 0
    
    Write-Host "`n[*] Generating contributions for $daysDiff days..." -ForegroundColor Cyan
    for ($d = 0; $d -le $daysDiff; $d++) {
        $currentDate = $startParsed.AddDays($d)
        for ($c = 1; $c -le $commitsPerDay; $c++) {
            $hour = Get-Random -Minimum 9 -Maximum 22
            $minute = Get-Random -Minimum 0 -Maximum 60
            $second = Get-Random -Minimum 0 -Maximum 60
            
            $commitDate = $currentDate.Date.AddHours($hour).AddMinutes($minute).AddSeconds($second)
            $isoDate = $commitDate.ToString("yyyy-MM-ddTHH:mm:ss")
            $msg = "Historical contribution: $($commitDate.ToString('yyyy-MM-dd HH:mm:ss')) [#$c]"
            
            Make-SingleCommit -Message $msg -DateStr $isoDate
            $totalCommits++
        }
    }
    
    Write-Host "[+] Generated $totalCommits commits across the specified range!" -ForegroundColor Green
    Push-ToGitHub
}

function Set-GitUserConfig {
    Write-Host "`n[ CONFIGURE GIT AUTHOR & EMAIL ]" -ForegroundColor Cyan
    Write-Host "GitHub matches contributions ONLY if the commit email is registered on your GitHub account!" -ForegroundColor Yellow
    $currentName = (& git config --get user.name 2>$null)
    $currentEmail = (& git config --get user.email 2>$null)
    Write-Host "Current Name : $currentName" -ForegroundColor White
    Write-Host "Current Email: $currentEmail" -ForegroundColor White
    
    $newName = Read-Host "New Author Name (Press Enter to keep '$currentName')"
    if (-not [string]::IsNullOrWhiteSpace($newName)) {
        & git config user.name "$newName"
        Write-Host "[+] Updated git user.name to: $newName" -ForegroundColor Green
    }
    
    $newEmail = Read-Host "New Author Email (Press Enter to keep '$currentEmail')"
    if (-not [string]::IsNullOrWhiteSpace($newEmail)) {
        & git config user.email "$newEmail"
        Write-Host "[+] Updated git user.email to: $newEmail" -ForegroundColor Green
    }
}

function Show-RecentLog {
    Write-Host "`n[ RECENT COMMITS PREVIEW ]" -ForegroundColor Cyan
    & git log -n 10 --oneline --decorate --color
    Write-Host ""
}

# --- CLI ARGUMENT PROCESSING ---
if (-not (Test-GitInstalled)) { exit 1 }
Ensure-GitRepo

if ($Arg1 -eq "--help" -or $Arg1 -eq "-h" -or $Arg1 -eq "/?") {
    Write-Host "GitHub Contribution Booster - Usage:" -ForegroundColor Cyan
    Write-Host "  push_contributions.bat              : Launch interactive menu"
    Write-Host "  push_contributions.bat 20           : Generate 20 commits for today and push"
    Write-Host "  push_contributions.bat --days 30    : Fill past 30 days history and push"
    Write-Host "  push_contributions.bat --push       : Push all pending commits"
    exit 0
}

if ($Arg1 -match '^\d+$') {
    # Direct numeric argument -> burst for today
    $count = [int]$Arg1
    Start-TodayBurst -Count $count
    exit 0
}

if ($Arg1 -eq "--days" -and $Arg2 -match '^\d+$') {
    $days = [int]$Arg2
    Start-HistoryBackdate -Days $days -Interactive $false
    exit 0
}

if ($Arg1 -eq "--push") {
    Push-ToGitHub
    exit 0
}

# --- INTERACTIVE MENU LOOP ---
while ($true) {
    Write-Banner
    Show-StatusSummary
    
    Write-Host "  [1] Rapid Burst for Today       -> Push X commits for today's streak" -ForegroundColor Green
    Write-Host "  [2] Fill History (Green Squares)-> Backdate commits across past N days" -ForegroundColor Green
    Write-Host "  [3] Custom Date Range Backdate  -> Specify custom start & end dates" -ForegroundColor Green
    Write-Host "  [4] Express 1-Click Boost       -> Instant 15 commits for today + Push" -ForegroundColor Green
    Write-Host "  [5] Setup / Change Remote URL   -> Link to your GitHub repository" -ForegroundColor Cyan
    Write-Host "  [6] Push Pending Commits Now    -> Run 'git push' to sync local commits" -ForegroundColor Cyan
    Write-Host "  [7] View Recent Commit Log      -> Inspect recent commits in terminal" -ForegroundColor Yellow
    Write-Host "  [8] Configure Git Name & Email  -> Ensure email matches your GitHub account" -ForegroundColor Yellow
    Write-Host "  [0] Exit" -ForegroundColor DarkGray
    Write-Host ""
    
    $choice = Read-Host "Select an option (0-8)"
    
    switch ($choice) {
        "1" { Start-TodayBurst }
        "2" { Start-HistoryBackdate }
        "3" { Start-CustomRange }
        "4" { Start-TodayBurst -Count 15 }
        "5" { Set-GitHubRemote }
        "6" { Push-ToGitHub }
        "7" { Show-RecentLog }
        "8" { Set-GitUserConfig }
        "0" { Write-Host "`nGoodbye! Happy coding!`n" -ForegroundColor Cyan; exit 0 }
        Default { Write-Host "Invalid option. Please choose between 0 and 8." -ForegroundColor Red }
    }
    
    Write-Host "`nPress Enter to return to main menu..." -ForegroundColor DarkGray
    Read-Host | Out-Null
}
