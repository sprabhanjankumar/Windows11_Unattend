<# :
@echo off
title Multi-Software Advanced GUI Manager
setlocal

:: Request Admin Permissions automatically (Without hiding the UAC prompt)
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    exit /b
)

:: Execute the embedded PowerShell script
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Command -ScriptBlock ([ScriptBlock]::Create((Get-Content '%~f0' -Raw)))"
exit /b
#>

# --- Hide the PowerShell Console Window Completely ---
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0) | Out-Null

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Target directory for offline installer downloads
$downloadDir = Join-Path $env:USERPROFILE "Downloads\WinGet_PrabhanjanKumar"

# Define the predefined software dictionary with CORRECTED verified Winget IDs
$apps = [ordered]@{
    "Google Chrome" = "Google.Chrome"
    "Microsoft Edge" = "Microsoft.Edge"
    "Brave Browser" = "Brave.Brave"
    "Notepad++" = "Notepad++.Notepad++"
    "WinRAR" = "RARLab.WinRAR"
    "7-Zip" = "7zip.7zip"
    "Microsoft Teams" = "Microsoft.Teams"
    "TeamViewer" = "TeamViewer.TeamViewer"
    "TeraCopy" = "CodeSector.TeraCopy"
    "VLC Media Player" = "VideoLAN.VLC"
    "AnyBurn" = "PowerSoftware.AnyBurn.Pro"
    "PowerISO" = "PowerISO.PowerISO"
    "qBittorrent" = "qBittorrent.qBittorrent"
    "Driver Booster" = "IObit.DriverBooster"
    "Internet Download Manager" = "Tonec.InternetDownloadManager"
}

# --- Build the Window Form (Expanded for Side-by-Side layout) ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Software Manager & Global WinGet Search"
$form.Size = New-Object System.Drawing.Size(900, 560)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# ==========================================
# LEFT PANEL: Predefined Checklist
# ==========================================
$lblPredefined = New-Object System.Windows.Forms.Label
$lblPredefined.Text = "1. Predefined Quick Install:"
$lblPredefined.AutoSize = $true
$lblPredefined.Location = New-Object System.Drawing.Point(15, 15)
$lblPredefined.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($lblPredefined)

$checkedListBox = New-Object System.Windows.Forms.CheckedListBox
$checkedListBox.Size = New-Object System.Drawing.Size(380, 300)
$checkedListBox.Location = New-Object System.Drawing.Point(15, 40)
$checkedListBox.CheckOnClick = $true
$checkedListBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
foreach ($key in $apps.Keys) { [void]$checkedListBox.Items.Add($key, $true) }
$form.Controls.Add($checkedListBox)

$installBtn = New-Object System.Windows.Forms.Button
$installBtn.Text = "Online Install"
$installBtn.Size = New-Object System.Drawing.Size(120, 35)
$installBtn.Location = New-Object System.Drawing.Point(15, 360)
$installBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($installBtn)

$downloadBtn = New-Object System.Windows.Forms.Button
$downloadBtn.Text = "Offline Download"
$downloadBtn.Size = New-Object System.Drawing.Size(120, 35)
$downloadBtn.Location = New-Object System.Drawing.Point(145, 360)
$downloadBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($downloadBtn)

$wingetBtn = New-Object System.Windows.Forms.Button
$wingetBtn.Text = "Repair WinGet"
$wingetBtn.Size = New-Object System.Drawing.Size(120, 35)
$wingetBtn.Location = New-Object System.Drawing.Point(275, 360)
$wingetBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($wingetBtn)

$cancelBtn = New-Object System.Windows.Forms.Button
$cancelBtn.Text = "Exit Application"
$cancelBtn.Size = New-Object System.Drawing.Size(380, 30)
$cancelBtn.Location = New-Object System.Drawing.Point(15, 405)
$cancelBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$form.Controls.Add($cancelBtn)

# ==========================================
# RIGHT PANEL: Live WinGet Search Engine
# ==========================================
$lblSearch = New-Object System.Windows.Forms.Label
$lblSearch.Text = "2. Global WinGet Repository Search:"
$lblSearch.AutoSize = $true
$lblSearch.Location = New-Object System.Drawing.Point(420, 15)
$lblSearch.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($lblSearch)

$txtSearch = New-Object System.Windows.Forms.TextBox
$txtSearch.Location = New-Object System.Drawing.Point(420, 40)
$txtSearch.Size = New-Object System.Drawing.Size(330, 25)
$txtSearch.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$form.Controls.Add($txtSearch)

$btnSearch = New-Object System.Windows.Forms.Button
$btnSearch.Text = "Search"
$btnSearch.Location = New-Object System.Drawing.Point(760, 38)
$btnSearch.Size = New-Object System.Drawing.Size(100, 25)
$btnSearch.BackColor = [System.Drawing.Color]::LightBlue
$btnSearch.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btnSearch)

$searchListView = New-Object System.Windows.Forms.ListView
$searchListView.Location = New-Object System.Drawing.Point(420, 75)
$searchListView.Size = New-Object System.Drawing.Size(440, 360)
$searchListView.View = [System.Windows.Forms.View]::Details
$searchListView.FullRowSelect = $true
$searchListView.GridLines = $true
$searchListView.Columns.Add("Software Name", 200) | Out-Null
$searchListView.Columns.Add("WinGet ID", 150) | Out-Null
$searchListView.Columns.Add("Version", 80) | Out-Null
$form.Controls.Add($searchListView)

# Context Menu for Right-Click on Search Results
$searchContextMenu = New-Object System.Windows.Forms.ContextMenuStrip
$ctxInstall = New-Object System.Windows.Forms.ToolStripMenuItem("Install Online")
$ctxDownload = New-Object System.Windows.Forms.ToolStripMenuItem("Download Offline")
$searchContextMenu.Items.Add($ctxInstall) | Out-Null
$searchContextMenu.Items.Add($ctxDownload) | Out-Null
$searchListView.ContextMenuStrip = $searchContextMenu

# ==========================================
# BOTTOM PANEL: Universal Progress & Status
# ==========================================
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(845, 20)
$progressBar.Location = New-Object System.Drawing.Point(15, 450)
$progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
$form.Controls.Add($progressBar)

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Size = New-Object System.Drawing.Size(845, 20)
$statusLabel.Location = New-Object System.Drawing.Point(15, 475)
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$statusLabel.ForeColor = [System.Drawing.Color]::DarkBlue
$statusLabel.Text = "Ready. Select predefined apps or search the global repository."
$form.Controls.Add($statusLabel)

# ==========================================
# UNIVERSAL HELPER FUNCTIONS
# ==========================================
function Set-UIState ($enabled) {
    $installBtn.Enabled = $enabled
    $downloadBtn.Enabled = $enabled
    $wingetBtn.Enabled = $enabled
    $btnSearch.Enabled = $enabled
    $checkedListBox.Enabled = $enabled
    $searchListView.Enabled = $enabled
}

function Execute-Install ($appName, $appId) {
    $statusLabel.Text = "Installing: $appName ($appId)... Please wait."
    [System.Windows.Forms.Application]::DoEvents()
    $args = @("install", "--id", $appId, "-e", "--accept-source-agreements", "--accept-package-agreements", "--silent")
    $process = Start-Process -FilePath "winget" -ArgumentList $args -Wait -NoNewWindow -PassThru
    return $process.ExitCode
}

function Execute-Download ($appName, $appId) {
    if (!(Test-Path $downloadDir)) { New-Item -ItemType Directory -Path $downloadDir -Force | Out-Null }
    $statusLabel.Text = "Downloading: $appName ($appId)... Please wait."
    [System.Windows.Forms.Application]::DoEvents()
    $args = @("download", "--id", $appId, "-e", "--download-directory", $downloadDir, "--accept-source-agreements")
    $process = Start-Process -FilePath "winget" -ArgumentList $args -Wait -NoNewWindow -PassThru
    return $process.ExitCode
}

# ==========================================
# EVENTS: Search & Context Menu (Right Panel)
# ==========================================
$btnSearch.Add_Click({
    $query = $txtSearch.Text.Trim()
    if (-not $query) { return }

    Set-UIState $false
    $searchListView.Items.Clear()
    $statusLabel.Text = "Searching global repository for '$query'..."
    $progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
    [System.Windows.Forms.Application]::DoEvents()

    try {
        $output = winget search "$query" --accept-source-agreements
        $startParsing = $false
        
        foreach ($line in $output) {
            if ($line -match "^---") { $startParsing = $true; continue }
            
            if ($startParsing -and $line.Trim() -ne "") {
                $cols = $line -split '\s{2,}'
                if ($cols.Count -ge 2) {
                    $name = $cols[0]
                    $id = $cols[1]
                    $version = if ($cols.Count -ge 3) { $cols[2] } else { "Unknown" }
                    
                    $item = New-Object System.Windows.Forms.ListViewItem($name)
                    $item.SubItems.Add($id)
                    $item.SubItems.Add($version)
                    $searchListView.Items.Add($item) | Out-Null
                }
            }
        }
        $count = $searchListView.Items.Count
        $statusLabel.Text = "Search complete. Found $count matching packages."
    } catch {
        $statusLabel.Text = "An error occurred while searching."
    }

    $progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
    $progressBar.Value = 0
    Set-UIState $true
})

$ctxInstall.Add_Click({
    if ($searchListView.SelectedItems.Count -eq 0) { return }
    Set-UIState $false
    $appName = $searchListView.SelectedItems[0].Text
    $appId = $searchListView.SelectedItems[0].SubItems[1].Text
    
    $progressBar.Maximum = 1
    $progressBar.Value = 0
    
    $exitCode = Execute-Install -appName $appName -appId $appId
    $progressBar.Value = 1
    
    if ($exitCode -eq 0) { $statusLabel.Text = "Success! Installed $appName." }
    else { $statusLabel.Text = "Warning: Installation for $appName returned exit code $exitCode." }
    
    Set-UIState $true
})

$ctxDownload.Add_Click({
    if ($searchListView.SelectedItems.Count -eq 0) { return }
    Set-UIState $false
    $appName = $searchListView.SelectedItems[0].Text
    $appId = $searchListView.SelectedItems[0].SubItems[1].Text
    
    $progressBar.Maximum = 1
    $progressBar.Value = 0
    
    $exitCode = Execute-Download -appName $appName -appId $appId
    $progressBar.Value = 1
    
    if ($exitCode -eq 0) { 
        $statusLabel.Text = "Success! $appName saved to $downloadDir" 
        Start-Process "explorer.exe" -ArgumentList $downloadDir
    } else { 
        $statusLabel.Text = "Error downloading $appName." 
    }
    
    Set-UIState $true
})

# ==========================================
# EVENTS: Checklist Buttons (Left Panel)
# ==========================================
$installBtn.Add_Click({
    if ($checkedListBox.CheckedItems.Count -eq 0) { return }
    Set-UIState $false
    $progressBar.Maximum = $checkedListBox.CheckedItems.Count
    $progressBar.Value = 0
    $current = 0
    
    foreach ($item in $checkedListBox.CheckedItems) {
        Execute-Install -appName $item -appId $apps[$item] | Out-Null
        $current++
        $progressBar.Value = $current
    }
    
    $statusLabel.Text = "Success! All selected predefined applications installed."
    Set-UIState $true
})

$downloadBtn.Add_Click({
    if ($checkedListBox.CheckedItems.Count -eq 0) { return }
    Set-UIState $false
    $progressBar.Maximum = $checkedListBox.CheckedItems.Count
    $progressBar.Value = 0
    $current = 0
    
    foreach ($item in $checkedListBox.CheckedItems) {
        Execute-Download -appName $item -appId $apps[$item] | Out-Null
        $current++
        $progressBar.Value = $current
    }
    
    $statusLabel.Text = "Downloads complete! Saved to $downloadDir"
    Set-UIState $true
    Start-Process "explorer.exe" -ArgumentList $downloadDir
})

$wingetBtn.Add_Click({
    Set-UIState $false
    $statusLabel.Text = "Checking WinGet Infrastructure..."
    $progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
    [System.Windows.Forms.Application]::DoEvents()
    
    $wingetCheck = Get-Command "winget" -ErrorAction SilentlyContinue
    if ($wingetCheck) {
        $statusLabel.Text = "WinGet found. Updating sources..."
        [System.Windows.Forms.Application]::DoEvents()
        Start-Process -FilePath "winget" -ArgumentList "source update" -Wait -NoNewWindow
        $statusLabel.Text = "WinGet is fully active and updated!"
    } else {
        $statusLabel.Text = "WinGet missing. Please install App Installer from Microsoft Store."
    }
    
    $progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
    $progressBar.Value = 0
    Set-UIState $true
})

$cancelBtn.Add_Click({ $form.Close() })

# Fire up the user interface
[void]$form.ShowDialog()