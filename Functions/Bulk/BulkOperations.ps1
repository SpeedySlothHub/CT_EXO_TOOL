function Invoke-BulkMenu {
    if ($Global:TenantName -eq "Disconnected") {
        Clear-Host
        Write-Host "=====================================================================" -ForegroundColor Red
        Write-Host "                         NO ACTIVE CONNECTION                        " -ForegroundColor Red
        Write-Host "=====================================================================" -ForegroundColor Red
        Write-Host "You must authenticate to Exchange Online before accessing Bulk Operations." -ForegroundColor Yellow
        Wait-Console "Press Enter to return..."
        return
    }

    # Initialize view registers if unset
    if ($null -eq $Global:ActiveView) { $Global:ActiveView = "Storage" }
    if ($null -eq $Global:StorageAction) { $Global:StorageAction = "Enable" }
    if ($null -eq $Global:DelegateAction) { $Global:DelegateAction = "Add" }
    if ($null -eq $Global:SelectedDelegation) { $Global:SelectedDelegation = "None" }

    $MenuRunning = $true
    while ($MenuRunning) {
        if ($null -eq $Global:CentralMailboxCache) {
            Clear-Host
            Write-Host "=====================================================================" -ForegroundColor Cyan
            Write-Host "              INITIALIZING TENANT MAILBOX AUDIT CACHE                " -ForegroundColor Cyan
            Write-Host "=====================================================================" -ForegroundColor Cyan
            Write-Host "Querying Exchange Online directory endpoints for $Global:TenantName..." -ForegroundColor Gray

            try {
                # Retrieve user and shared mailboxes
                $RawMailboxes = @(Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox, SharedMailbox -ErrorAction Stop -WarningAction SilentlyContinue)
                $CacheList = [System.Collections.Generic.List[PSCustomObject]]::new()
                $Total = $RawMailboxes.Count

                Write-Host "`n[SUCCESS] Discovered $Total mailboxes in tenant." -ForegroundColor Green
                Write-Host "Compiling analytics via REST API (Get-EXOMailboxStatistics)..." -ForegroundColor Cyan
                Write-Host "Tip: Press 'Q' or 'Esc' at any time to stop early and use loaded mailboxes.`n" -ForegroundColor DarkGray
                Start-Sleep -Milliseconds 500

                # --- REST-BASED SEQUENTIAL PIPELINE WITH ETA & CANCEL ---
                $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
                $Cancelled = $false
                $Count = 0
                foreach ($mbx in $RawMailboxes) {
                    # Non-blocking check for cancellation key
                    try {
                        if ([Console]::KeyAvailable) {
                            $Key = [Console]::ReadKey($true)
                            if ($Key.Key -in @('Q', 'Escape', 'C')) {
                                Write-Host "`n[USER STOPPED] Cancellation key received. Finalizing loaded mailboxes..." -ForegroundColor Yellow
                                $Cancelled = $true
                                break
                            }
                        }
                    } catch {}

                    $Count++
                    $Elapsed = $Stopwatch.Elapsed
                    $ElapsedSec = [math]::Max(0.01, $Elapsed.TotalSeconds)
                    $AvgSecPerItem = $ElapsedSec / $Count
                    $RemainingItems = $Total - $Count
                    $EtaSec = [math]::Round($RemainingItems * $AvgSecPerItem)
                    $EtaSpan = [TimeSpan]::FromSeconds($EtaSec)
                    $EtaDisplay = if ($EtaSec -ge 60) {
                        "{0}m {1:d2}s" -f [int]$EtaSpan.TotalMinutes, $EtaSpan.Seconds
                    } else {
                        "{0}s" -f $EtaSec
                    }
                    $RateDisplay = [math]::Round($Count / $ElapsedSec, 1)

                    $StatusMsg = "Processing ($Count/$Total): $($mbx.UserPrincipalName) | Rate: $RateDisplay/s | ETA: ~$EtaDisplay (Press 'Q'/Esc to stop)"
                    Write-Progress -Activity "Compiling Tenant Mailbox Analytics" -Status $StatusMsg -PercentComplete (($Count / $Total) * 100)

                    $stat = Get-EXOMailboxStatistics -Identity $mbx.UserPrincipalName -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
                    $PrimarySizeBytes = Get-RawBytes $stat.TotalItemSize
                    $PrimarySizeGB = [math]::Round($PrimarySizeBytes / 1GB, 2)

                    $QuotaBytes = Get-RawBytes $mbx.ProhibitSendReceiveQuota
                    if ($QuotaBytes -eq 0 -or [double]::IsPositiveInfinity($QuotaBytes)) { 
                        $PrimaryQuotaGB = 50.0 
                    } else {
                        $PrimaryQuotaGB = [math]::Round($QuotaBytes / 1GB, 2)
                    }
                    $PrimaryPercentUsed = if ($PrimaryQuotaGB -gt 0) { [math]::Round(($PrimarySizeGB / $PrimaryQuotaGB) * 100, 1) } else { 0 }

                    $ArchiveSizeGB = 0.0
                    $ArchiveQuotaGB = 100.0
                    $ArchivePercentUsed = 0.0
                    $ArchiveActive = ($mbx.ArchiveStatus -eq "Active" -or $mbx.ArchiveStatus -eq "Local" -or $mbx.ArchiveStatus -eq "Enabled")

                    if ($ArchiveActive) {
                        $archiveStat = Get-EXOMailboxStatistics -Identity $mbx.UserPrincipalName -Archive -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
                        $ArchiveSizeBytes = Get-RawBytes $archiveStat.TotalItemSize
                        $ArchiveSizeGB = [math]::Round($ArchiveSizeBytes / 1GB, 2)

                        $ArchiveQuotaBytes = Get-RawBytes $mbx.ArchiveQuota
                        if ($ArchiveQuotaBytes -gt 0 -and -not [double]::IsPositiveInfinity($ArchiveQuotaBytes)) {
                            $ArchiveQuotaGB = [math]::Round($ArchiveQuotaBytes / 1GB, 2)
                        }
                        $ArchivePercentUsed = if ($ArchiveQuotaGB -gt 0) { [math]::Round(($ArchiveSizeGB / $ArchiveQuotaGB) * 100, 1) } else { 0 }
                    }

                    $IsShared = ($mbx.RecipientTypeDetails -eq 'SharedMailbox')
                    $IsLicensed = if ($IsShared) { $false } else { $true }

                    $CacheList.Add([PSCustomObject]@{
                        Idx                       = $Count
                        DisplayName               = $mbx.DisplayName
                        UserPrincipalName         = $mbx.UserPrincipalName
                        PrimarySizeGB             = $PrimarySizeGB
                        PrimaryQuotaGB            = $PrimaryQuotaGB
                        PrimaryPercentUsed        = $PrimaryPercentUsed
                        ArchiveEnabled            = $ArchiveActive
                        ArchiveSizeGB             = $ArchiveSizeGB
                        ArchiveQuotaGB            = $ArchiveQuotaGB
                        ArchivePercentUsed        = $ArchivePercentUsed
                        AutoExpandingArchiveReady = [bool]$mbx.AutoExpandingArchiveEnabled
                        RetentionPolicy           = if ([string]::IsNullOrWhiteSpace($mbx.RetentionPolicy)) { "No Policy Assigned" } else { $mbx.RetentionPolicy }
                        IsSharedMailbox           = $IsShared
                        IsLicensed                = $IsLicensed
                        Selected                  = $false
                    })
                }
                Write-Progress -Activity "Compiling Tenant Mailbox Analytics" -Completed

                if ($Cancelled) {
                    if ($CacheList.Count -gt 0) {
                        Write-Host "`n[NOTICE] Scan stopped. Retaining $($CacheList.Count) mailboxes scanned so far." -ForegroundColor Yellow
                        Start-Sleep -Seconds 1
                        $Global:CentralMailboxCache = $CacheList
                    } else {
                        Write-Host "`n[NOTICE] Scan aborted before any mailboxes were loaded." -ForegroundColor Yellow
                        $Global:CentralMailboxCache = $null
                        Wait-Console
                        return
                    }
                } else {
                    $Global:CentralMailboxCache = $CacheList
                }
            }
            catch {
                Write-Host "`n[CRITICAL ERROR] Failed to capture tenant data: $($_.Exception.Message)" -ForegroundColor Red
                $Global:CentralMailboxCache = $null
                Wait-Console "Press Enter to return to main menu..."
                return
            }
        }

        # Hand off to interactive matrix auditor
        $NavigationSignal = Invoke-InteractiveMatrixAuditor
        if ($NavigationSignal -eq "EXIT") {
            $MenuRunning = $false
        }
    }
}

function Invoke-InteractiveMatrixAuditor {
    $PrimaryThreshold = 90
    $ArchiveThreshold = 75
    $FilterLicensedOnly = $true
    $HideCompliant = $false

    $WorkspaceRunning = $true
    while ($WorkspaceRunning) {
        Clear-Host
        
        $TotalItems = $Global:CentralMailboxCache.Count
        $SelectedCount = ($Global:CentralMailboxCache | Where-Object { $_.Selected }).Count

        # Header Interface
        Write-Host "=========================================================================================================" -ForegroundColor Cyan
        Write-Host "                      BULK MAILBOX AUDIT & CONFIGURATION MATRIX [$Global:TenantName]                     " -ForegroundColor Cyan
        Write-Host "=========================================================================================================" -ForegroundColor Cyan
        
        # Display Active View settings
        Write-Host " ACTIVE VIEW: " -NoNewline; Write-Host "$($Global:ActiveView.ToUpper()) MODE" -ForegroundColor White -NoNewline
        if ($Global:ActiveView -eq "Storage") {
            Write-Host "  |  Rules: Primary >= " -NoNewline; Write-Host "$PrimaryThreshold%" -ForegroundColor Yellow -NoNewline
            Write-Host " | Archive >= " -NoNewline; Write-Host "$ArchiveThreshold%" -ForegroundColor Yellow -NoNewline
            Write-Host " | Target Action: " -NoNewline; Write-Host "$($Global:StorageAction.ToUpper())" -ForegroundColor Cyan
        } else {
            Write-Host "  |  Target Action: " -NoNewline; Write-Host "$($Global:DelegateAction.ToUpper())" -ForegroundColor Cyan -NoNewline
            Write-Host " | Permission Type: " -NoNewline; Write-Host "$($Global:SelectedDelegation)" -ForegroundColor Yellow
        }
        
        Write-Host " License Filter: " -NoNewline
        if ($FilterLicensedOnly) { 
            Write-Host "ACTIVE (Skip Unlicensed / Shared)" -ForegroundColor Green -NoNewline 
        } else { 
            Write-Host "INACTIVE (Include All)" -ForegroundColor Yellow -NoNewline 
        }

        Write-Host "  |  Compliance Filter: " -NoNewline
        if ($HideCompliant) {
            Write-Host "ACTIVE (Hide Compliant)" -ForegroundColor Green -NoNewline
        } else {
            Write-Host "INACTIVE (Show All)" -ForegroundColor Gray -NoNewline
        }
        
        Write-Host ("  |  Loaded: {0} | Selected: {1}" -f $TotalItems, $SelectedCount) -ForegroundColor Green
        Write-Host "=========================================================================================================" -ForegroundColor Gray
        
        # Build dynamic columns depending on active layout
        if ($Global:ActiveView -eq "Storage") {
            $FormatStr = "{0,-4} {1,-6} {2,-24} {3,-8} {4,-5} {5,-24} {6,-22}"
            Write-Host ($FormatStr -f "ID", "STATE", "DISPLAY NAME", "TYPE", "LIC", "PRIMARY UTILIZATION", "ARCHIVE UTILIZATION") -ForegroundColor White
        } else {
            $FormatStr = "{0,-4} {1,-6} {2,-25} {3,-8} {4,-5} {5,-32} {6,-20}"
            Write-Host ($FormatStr -f "ID", "STATE", "DISPLAY NAME", "TYPE", "LIC", "USER PRINCIPAL NAME", "RETENTION POLICY") -ForegroundColor White
        }
        Write-Host "=========================================================================================================" -ForegroundColor Gray

        # Data Display Layer
        $DisplayedCount = 0
        $HiddenCount = 0
        foreach ($mbx in $Global:CentralMailboxCache) {
            $TypeStr = if ($mbx.IsSharedMailbox) { "Shared" } else { "User" }
            $LicStr = if ($mbx.IsLicensed) { "Yes" } else { "No" }
            $StateCheckbox = if ($mbx.Selected) { "[X]" } else { "[ ]" }
            
            if ($Global:ActiveView -eq "Storage") {
                $PrimaryUtilStr = "{0}/{1} GB ({2}%)" -f $mbx.PrimarySizeGB, $mbx.PrimaryQuotaGB, $mbx.PrimaryPercentUsed
                if ($mbx.ArchiveEnabled) {
                    $ArchiveUtilStr = "{0}/{1} GB ({2}%)" -f $mbx.ArchiveSizeGB, $mbx.ArchiveQuotaGB, $mbx.ArchivePercentUsed
                    if ($mbx.AutoExpandingArchiveReady) { $ArchiveUtilStr += " [Exp]" }
                } else {
                    $ArchiveUtilStr = "Disabled"
                }
                $RowString = $FormatStr -f $mbx.Idx, $StateCheckbox, $mbx.DisplayName, $TypeStr, $LicStr, $PrimaryUtilStr, $ArchiveUtilStr
            } else {
                $RowString = $FormatStr -f $mbx.Idx, $StateCheckbox, $mbx.DisplayName, $TypeStr, $LicStr, $mbx.UserPrincipalName, $mbx.RetentionPolicy
            }

            $QualifiesPrimary = (-not $mbx.ArchiveEnabled -and $mbx.PrimaryPercentUsed -ge $PrimaryThreshold)
            $QualifiesArchive = ($mbx.ArchiveEnabled -and -not $mbx.AutoExpandingArchiveReady -and $mbx.ArchivePercentUsed -ge $ArchiveThreshold)
            $PassesLicense = (-not $FilterLicensedOnly -or $mbx.IsLicensed)
            $IsActionRequired = ($QualifiesPrimary -or $QualifiesArchive) -and $PassesLicense

            # Filter out compliant mailboxes if toggle is enabled (unless user has explicitly selected it)
            if ($HideCompliant -and -not $IsActionRequired -and -not $mbx.Selected) {
                $HiddenCount++
                continue
            }
            $DisplayedCount++

            if ($mbx.Selected) {
                Write-Host $RowString -ForegroundColor Green
            } elseif (($Global:ActiveView -eq "Storage") -and $IsActionRequired) {
                Write-Host $RowString -ForegroundColor Cyan
            } else {
                Write-Host $RowString -ForegroundColor Gray
            }
        }

        if ($DisplayedCount -eq 0 -and $HideCompliant) {
            Write-Host "`n   >>> ALL $TotalItems MAILBOXES ARE CURRENTLY COMPLIANT WITH ACTIVE RULES! <<<" -ForegroundColor Green
            Write-Host "   (Press [H] to toggle view back to Show All, or [T] to adjust rule thresholds)`n" -ForegroundColor DarkGray
        }

        Write-Host "=========================================================================================================" -ForegroundColor Gray
        Write-Host " COMMANDS & NAVIGATION:" -ForegroundColor Cyan
        Write-Host "  [#] Toggle index state (e.g. 1 or 1,3,5) | [A] Select All | [D] Clear All" -ForegroundColor Gray
        Write-Host "  [V1] Switch to Storage View              | [V2] Switch to Delegation View" -ForegroundColor White
        Write-Host "  [T]  Set Threshold Limits                | [L]  Toggle License Filter" -ForegroundColor Gray
        Write-Host "  [H]  Toggle Hide Compliant Mailboxes     | [F]  Auto-Select by Thresholds" -ForegroundColor Cyan
        Write-Host "  [E]  Export Current Data to CSV          | [R]  Force Refresh & Rescan Metrics" -ForegroundColor Yellow
        Write-Host "  [0]  Return to Main Menu" -ForegroundColor DarkGray
        Write-Host "---------------------------------------------------------------------------------------------------------" -ForegroundColor Gray
        
        # Contextual action menus
        if ($Global:ActiveView -eq "Storage") {
            Write-Host " STORAGE ACTIONS (Selected Mailboxes):" -ForegroundColor Magenta
            Write-Host "  [STOR0] Toggle Action Mode (Current: $Global:StorageAction)" -ForegroundColor White
            Write-Host "  [STOR1] Bulk Apply Online Archiving"
            Write-Host "  [STOR2] Bulk Apply Auto-Expanding Archive"
            Write-Host "  [STOR3] Bulk Apply BOTH Online Archive & Auto-Expansion"
        } else {
            Write-Host " DELEGATION ACTIONS (Selected Mailboxes):" -ForegroundColor Magenta
            Write-Host "  [SEND0] Toggle Delegation Mode (Current: $Global:DelegateAction)" -ForegroundColor White
            Write-Host "  [SEND1] Select SendAs Permission"
            Write-Host "  [SEND2] Select SendOnBehalf Permission"
            Write-Host "  [SEND3] Select FullAccess Permission"
            Write-Host "  [SEND]  EXECUTE BULK PERMISSION ASSIGNMENT" -ForegroundColor Green
        }
        Write-Host "=========================================================================================================" -ForegroundColor Gray

        $Action = (Read-Host "`nSelection Command").ToUpper().Trim()

        # Handle numeric index toggling (e.g. "1" or "1,2,3")
        if ($Action -match '^[0-9, ]+$' -and $Action -ne "0") {
            $Indices = $Action -split ',' | ForEach-Object { $_.Trim() }
            foreach ($idx in $Indices) {
                if ($idx -match '^\d+$') {
                    $TargetID = [int]$idx
                    $MatchedMbx = $Global:CentralMailboxCache | Where-Object { $_.Idx -eq $TargetID }
                    if ($MatchedMbx) { $MatchedMbx.Selected = -not $MatchedMbx.Selected }
                }
            }
            continue
        }

        switch ($Action) {
            "0" { return "EXIT" }
            
            # View switches
            { $_ -in @("V1", "VIEW1") } { $Global:ActiveView = "Storage"; continue }
            { $_ -in @("V2", "VIEW2") } { $Global:ActiveView = "Delegation"; continue }

            # Toggle Hide Compliant
            { $_ -in @("H", "HIDE", "COMPLIANT") } {
                $HideCompliant = -not $HideCompliant
                continue
            }

            # Storage Mode Toggle
            { $_ -in @("STOR0", "MODE") -and $Global:ActiveView -eq "Storage" } {
                $Global:StorageAction = if ($Global:StorageAction -eq "Enable") { "Disable" } else { "Enable" }
                continue
            }

            # Delegation Mode Toggle
            { $_ -in @("SEND0", "MODE") -and $Global:ActiveView -eq "Delegation" } {
                $Global:DelegateAction = if ($Global:DelegateAction -eq "Add") { "Remove" } else { "Add" }
                continue
            }

            # Delegation Permission selection
            "SEND1" { $Global:SelectedDelegation = "SendAs"; continue }
            "SEND2" { $Global:SelectedDelegation = "SendOnBehalf"; continue }
            "SEND3" { $Global:SelectedDelegation = "FullAccess"; continue }

            # Execute Delegation
            { $_ -in @("SEND", "APPLY") } {
                $Targets = @($Global:CentralMailboxCache | Where-Object { $_.Selected })
                if ($Targets.Count -eq 0) { 
                    Write-Host "`n[ERROR] No mailboxes selected. Select mailboxes first." -ForegroundColor Red
                    Start-Sleep -Seconds 1
                    continue 
                }
                if ($Global:SelectedDelegation -eq "None") { 
                    Write-Host "`n[ERROR] No permission type selected. Please choose SEND1 (SendAs), SEND2 (SendOnBehalf), or SEND3 (FullAccess)." -ForegroundColor Red
                    Start-Sleep -Seconds 1.5
                    continue 
                }

                $delegateMbx = Resolve-MailboxIdentity -Prompt "Enter delegate user receiving/losing access (Name, Alias, or UPN)" -AllowCancel
                if ($null -eq $delegateMbx) { continue }
                $DelegateUser = $delegateMbx.UserPrincipalName

                Clear-Host
                Write-Host "=====================================================================" -ForegroundColor Magenta
                Write-Host " BULK DELEGATION: $Global:DelegateAction $Global:SelectedDelegation" -ForegroundColor Magenta
                Write-Host " Delegate User:   $($delegateMbx.DisplayName) ($DelegateUser)" -ForegroundColor White
                Write-Host " Target Count:    $($Targets.Count) mailboxes" -ForegroundColor Yellow
                Write-Host "=====================================================================" -ForegroundColor Magenta
                
                $Confirm = Read-Host "`nCommit permission changes to Microsoft 365? (Y/N)"
                if ($Confirm.Trim() -imatch '^Y') {
                    foreach ($t in $Targets) {
                        try {
                            Write-Host "Processing $($t.UserPrincipalName)..." -NoNewline -ForegroundColor Gray
                            if ($Global:SelectedDelegation -eq "FullAccess") {
                                if ($Global:DelegateAction -eq "Add") {
                                    $null = Add-MailboxPermission -Identity $t.UserPrincipalName -User $DelegateUser -AccessRights FullAccess -InheritanceType All -Confirm:$false -ErrorAction Stop
                                } else {
                                    $null = Remove-MailboxPermission -Identity $t.UserPrincipalName -User $DelegateUser -AccessRights FullAccess -Confirm:$false -ErrorAction Stop
                                }
                            }
                            elseif ($Global:SelectedDelegation -eq "SendAs") {
                                if ($Global:DelegateAction -eq "Add") {
                                    $null = Add-RecipientPermission -Identity $t.UserPrincipalName -Trustee $DelegateUser -AccessRights SendAs -Confirm:$false -ErrorAction Stop
                                } else {
                                    $null = Remove-RecipientPermission -Identity $t.UserPrincipalName -Trustee $DelegateUser -AccessRights SendAs -Confirm:$false -ErrorAction Stop
                                }
                            }
                            elseif ($Global:SelectedDelegation -eq "SendOnBehalf") {
                                if ($Global:DelegateAction -eq "Add") {
                                    $null = Set-Mailbox -Identity $t.UserPrincipalName -GrantSendOnBehalfTo @{Add=$DelegateUser} -ErrorAction Stop
                                } else {
                                    $null = Set-Mailbox -Identity $t.UserPrincipalName -GrantSendOnBehalfTo @{Remove=$DelegateUser} -ErrorAction Stop
                                }
                            }
                            $t.Selected = $false
                            Write-Host " [OK]" -ForegroundColor Green
                        }
                        catch {
                            Write-Host " [FAILED: $($_.Exception.Message)]" -ForegroundColor Red
                        }
                    }
                    Wait-Console "Bulk delegation complete. Press Enter to continue..."
                }
                continue
            }

            # Cache Refresh
            "R" {
                $Global:CentralMailboxCache = $null
                Write-Host "`nFlushing local cache and rescanning..." -ForegroundColor Yellow
                Start-Sleep -Seconds 1
                return "REFRESH" 
            }

            # Threshold Configuration
            "T" {
                Clear-Host
                Write-Host "=====================================================================" -ForegroundColor Cyan
                Write-Host "                     STORAGE THRESHOLD SETTINGS                      " -ForegroundColor Cyan
                Write-Host "=====================================================================" -ForegroundColor Cyan
                Write-Host " 1. Modify Primary Mailbox Threshold (Current: $PrimaryThreshold%)"
                Write-Host " 2. Modify Online Archive Threshold  (Current: $ArchiveThreshold%)"
                Write-Host " 0. Return to Matrix"
                Write-Host "---------------------------------------------------------------------"
                
                $TChoice = (Read-Host "Selection").Trim()
                if ($TChoice -eq "1") {
                    $NewT = (Read-Host "Enter new Primary percentage threshold (1-99)").Trim()
                    if ($NewT -match '^\d+$' -and [int]$NewT -ge 1 -and [int]$NewT -le 99) { 
                        $PrimaryThreshold = [int]$NewT 
                    }
                }
                elseif ($TChoice -eq "2") {
                    $NewT = (Read-Host "Enter new Archive percentage threshold (1-99)").Trim()
                    if ($NewT -match '^\d+$' -and [int]$NewT -ge 1 -and [int]$NewT -le 99) { 
                        $ArchiveThreshold = [int]$NewT 
                    }
                }
            }

            # License Filter Toggle
            "L" { 
                $FilterLicensedOnly = -not $FilterLicensedOnly 
                continue
            }

            # Auto-Select matching thresholds
            { $_ -in @("V", "F") } {
                foreach ($mbx in $Global:CentralMailboxCache) {
                    $QualifiesPrimary = (-not $mbx.ArchiveEnabled -and $mbx.PrimaryPercentUsed -ge $PrimaryThreshold)
                    $QualifiesArchive = ($mbx.ArchiveEnabled -and -not $mbx.AutoExpandingArchiveReady -and $mbx.ArchivePercentUsed -ge $ArchiveThreshold)
                    $PassesLicense = (-not $FilterLicensedOnly -or $mbx.IsLicensed)
                    
                    $mbx.Selected = ($QualifiesPrimary -or $QualifiesArchive) -and $PassesLicense
                }
                Write-Host "`nAuto-selection rules evaluated across mailboxes!" -ForegroundColor Green
                Start-Sleep -Seconds 1
            }

            # Select All / Clear All
            "A" { foreach ($mbx in $Global:CentralMailboxCache) { $mbx.Selected = $true }; continue }
            "D" { foreach ($mbx in $Global:CentralMailboxCache) { $mbx.Selected = $false }; continue }

            # Export to CSV
            "E" {
                Export-MailboxAuditReport -MailboxData $Global:CentralMailboxCache
                continue
            }

            # Bulk Provision Online Archive
            "STOR1" {
                $Targets = @($Global:CentralMailboxCache | Where-Object { $_.Selected })
                if ($Targets.Count -eq 0) { 
                    Write-Host "`n[ERROR] No mailboxes selected." -ForegroundColor Red
                    Start-Sleep -Seconds 1
                    continue 
                }
                Clear-Host
                Write-Host "=====================================================================" -ForegroundColor Magenta
                Write-Host " BULK ACTION: $($Global:StorageAction.ToUpper()) ONLINE ARCHIVE" -ForegroundColor Magenta
                Write-Host " Total Targets: $($Targets.Count) mailboxes" -ForegroundColor White
                Write-Host "=====================================================================" -ForegroundColor Magenta
                foreach ($t in $Targets) { Write-Host " - $($t.UserPrincipalName)" -ForegroundColor Cyan }
                
                $Confirm = Read-Host "`nCommit updates to Microsoft 365? (Y/N)"
                if ($Confirm.Trim() -imatch '^Y') {
                    foreach ($t in $Targets) {
                        try {
                            Write-Host "Processing $($t.UserPrincipalName)..." -NoNewline -ForegroundColor Gray
                            if ($Global:StorageAction -eq "Enable") {
                                $null = Enable-Mailbox -Identity $t.UserPrincipalName -Archive -ErrorAction Stop
                                $t.ArchiveEnabled = $true
                            } else {
                                $null = Disable-Mailbox -Identity $t.UserPrincipalName -Archive -Confirm:$false -ErrorAction Stop
                                $t.ArchiveEnabled = $false
                            }
                            $t.Selected = $false
                            Write-Host " [OK]" -ForegroundColor Green
                        }
                        catch {
                            Write-Host " [FAILED: $($_.Exception.Message)]" -ForegroundColor Red
                        }
                    }
                    Wait-Console "Bulk archive operation complete. Press Enter to return..."
                }
            }

            # Bulk Provision Auto-Expanding Archive
            "STOR2" {
                $Targets = @($Global:CentralMailboxCache | Where-Object { $_.Selected })
                if ($Targets.Count -eq 0) { 
                    Write-Host "`n[ERROR] No mailboxes selected." -ForegroundColor Red
                    Start-Sleep -Seconds 1
                    continue 
                }
                Clear-Host
                Write-Host "=====================================================================" -ForegroundColor Magenta
                Write-Host " BULK ACTION: ENABLE AUTO-EXPANDING ARCHIVE" -ForegroundColor Magenta
                Write-Host " Total Targets: $($Targets.Count) mailboxes" -ForegroundColor White
                Write-Host "=====================================================================" -ForegroundColor Magenta
                foreach ($t in $Targets) { Write-Host " - $($t.UserPrincipalName)" -ForegroundColor Cyan }
                
                if ($Global:StorageAction -ne "Enable") {
                    Write-Host "`n[NOTICE] Auto-Expanding Archives cannot be disabled once enabled per Microsoft architecture." -ForegroundColor Yellow
                    Wait-Console
                    continue
                }

                $Confirm = Read-Host "`nCommit updates to Microsoft 365? (Y/N)"
                if ($Confirm.Trim() -imatch '^Y') {
                    foreach ($t in $Targets) {
                        try {
                            Write-Host "Processing $($t.UserPrincipalName)..." -NoNewline -ForegroundColor Gray
                            $null = Enable-Mailbox -Identity $t.UserPrincipalName -AutoExpandingArchive -ErrorAction Stop
                            $t.AutoExpandingArchiveReady = $true
                            $t.Selected = $false
                            Write-Host " [OK]" -ForegroundColor Green
                        }
                        catch {
                            Write-Host " [FAILED: $($_.Exception.Message)]" -ForegroundColor Red
                        }
                    }
                    Wait-Console "Bulk auto-expansion operation complete. Press Enter to return..."
                }
            }

            # Bulk Provision Both (Archive + Auto-Expansion)
            "STOR3" {
                $Targets = @($Global:CentralMailboxCache | Where-Object { $_.Selected })
                if ($Targets.Count -eq 0) { 
                    Write-Host "`n[ERROR] No mailboxes selected." -ForegroundColor Red
                    Start-Sleep -Seconds 1
                    continue 
                }
                Clear-Host
                Write-Host "=====================================================================" -ForegroundColor Yellow
                Write-Host " BULK ACTION: DUAL ARCHIVE & AUTO-EXPANSION" -ForegroundColor Yellow
                Write-Host " Total Targets: $($Targets.Count) mailboxes" -ForegroundColor White
                Write-Host "=====================================================================" -ForegroundColor Yellow
                foreach ($t in $Targets) { Write-Host " - $($t.UserPrincipalName)" -ForegroundColor Cyan }
                
                $Confirm = Read-Host "`nCommit updates to Microsoft 365? (Y/N)"
                if ($Confirm.Trim() -imatch '^Y') {
                    foreach ($t in $Targets) {
                        try {
                            Write-Host "Processing $($t.UserPrincipalName)..." -NoNewline -ForegroundColor Gray
                            if ($Global:StorageAction -eq "Enable") {
                                if (-not $t.ArchiveEnabled) {
                                    $null = Enable-Mailbox -Identity $t.UserPrincipalName -Archive -ErrorAction Stop
                                    $t.ArchiveEnabled = $true
                                }
                                $null = Enable-Mailbox -Identity $t.UserPrincipalName -AutoExpandingArchive -ErrorAction Stop
                                $t.AutoExpandingArchiveReady = $true
                            } else {
                                $null = Disable-Mailbox -Identity $t.UserPrincipalName -Archive -Confirm:$false -ErrorAction Stop
                                $t.ArchiveEnabled = $false
                            }
                            $t.Selected = $false
                            Write-Host " [OK]" -ForegroundColor Green
                        }
                        catch {
                            Write-Host " [FAILED: $($_.Exception.Message)]" -ForegroundColor Red
                        }
                    }
                    Wait-Console "Bulk dual operation complete. Press Enter to return..."
                }
            }

            Default {
                Write-Host "Invalid command selection." -ForegroundColor Red
                Start-Sleep -Milliseconds 600
            }
        }
    }
}
