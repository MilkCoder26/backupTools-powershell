
# Load WinForms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Disk Backup Tool"
$form.Size = New-Object System.Drawing.Size(500, 350)
$form.StartPosition = "CenterScreen"

# Source Path
$lblSource = New-Object System.Windows.Forms.Label
$lblSource.Text = "Source Path:"
$lblSource.Location = '10,20'

$txtSource = New-Object System.Windows.Forms.TextBox
$txtSource.Location = '120,20'
$txtSource.Width = 250

# Destination Path
$lblDest = New-Object System.Windows.Forms.Label
$lblDest.Text = "Destination Path:"
$lblDest.Location = '10,60'

$txtDest = New-Object System.Windows.Forms.TextBox
$txtDest.Location = '120,60'
$txtDest.Width = 250

# Backup Mode
$grpMode = New-Object System.Windows.Forms.GroupBox
$grpMode.Text = "Backup Type"
$grpMode.Location = '10,100'
$grpMode.Size = '460,80'

$modes = @("Complete","Incremental","Differential","DryRun")
$radioButtons = @()
$x = 10

foreach ($mode in $modes) {
    $rb = New-Object System.Windows.Forms.RadioButton
    $rb.Text = $mode
    $rb.Location = "$x,30"
    $rb.Checked = ($mode -eq "Complete")
    $grpMode.Controls.Add($rb)
    $radioButtons += $rb
    $x += 110
}

# Status Label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Ready."
$statusLabel.Location = '10,200'
$statusLabel.Width = 460

# Start Button
$btnStart = New-Object System.Windows.Forms.Button
$btnStart.Text = "Start Backup"
$btnStart.Location = '180,240'

# Button Click Event
$btnStart.Add_Click({
    $source = $txtSource.Text.Trim()
    $dest   = $txtDest.Text.Trim()
    $mode   = ($radioButtons | Where-Object { $_.Checked }).Text

    Write-Host "disk source: $source"
    Write-Host "disk dest: $dest"
    Write-Host "backup mode: $mode"

    if ([string]::IsNullOrWhiteSpace($source)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a Source Path.")
        return
    }

    if (-not (Test-Path $source)) {
        [System.Windows.Forms.MessageBox]::Show("Invalid source path: $source")
        return
    }

    if ([string]::IsNullOrWhiteSpace($dest)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a Destination Path.")
        return
    }

    if (-not (Test-Path $dest)) {
        [System.Windows.Forms.MessageBox]::Show("Invalid destination path: $dest")
        return
    }

    # Everything looks good, run backup
    $statusLabel.Text = "Running $mode backup..."

    $exeFolder = [System.AppDomain]::CurrentDomain.BaseDirectory
    $diskCopyScript = Join-Path $exeFolder "DiskCopy.ps1"

    Write-Host "diskCopyScript: $diskCopyScript"
    Write-Host "exeFolder: $exeFolder"


    $arguments = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-File", $diskCopyScript,
    "-SourcePath", $source,
    "-DestinationRoot", $dest,
    "-Mode", $mode
)

Start-Process powershell.exe -ArgumentList $arguments -WindowStyle Hidden

})

# Add controls
$form.Controls.AddRange(@(
    $lblSource, $txtSource,
    $lblDest, $txtDest,
    $grpMode,
    $btnStart,
    $statusLabel
))

# Show Form
$form.ShowDialog()

