function Get-AuditOperationsCatalog {
    return @(
        # --- Category 1: Mailbox Read & Access ---
        [PSCustomObject]@{
            Category    = "Mailbox Read & Access"
            Operation   = "MailItemsAccessed"
            Friendly    = "Read/Accessed Email"
            RecordType  = "ExchangeItem"
            Description = "Mail items read, previewed, downloaded, or synced via client/MAPI/REST"
        },
        [PSCustomObject]@{
            Category    = "Mailbox Read & Access"
            Operation   = "MessageBind"
            Friendly    = "Opened Single Message"
            RecordType  = "ExchangeItem"
            Description = "Single email message opened directly in Outlook or OWA"
        },
        [PSCustomObject]@{
            Category    = "Mailbox Read & Access"
            Operation   = "FolderBind"
            Friendly    = "Accessed Mailbox Folder"
            RecordType  = "ExchangeItem"
            Description = "Mailbox folder accessed or bound by an admin or delegate"
        },
        [PSCustomObject]@{
            Category    = "Mailbox Read & Access"
            Operation   = "SearchCreated"
            Friendly    = "Search Query Created"
            RecordType  = "ExchangeItem"
            Description = "Discovery or mailbox search query initiated"
        },

        # --- Category 2: Email Sending & Transmission ---
        [PSCustomObject]@{
            Category    = "Email Sending & Transmission"
            Operation   = "SendAs"
            Friendly    = "Sent As Mailbox"
            RecordType  = "ExchangeItem"
            Description = "Message sent using Send-As permissions on another mailbox"
        },
        [PSCustomObject]@{
            Category    = "Email Sending & Transmission"
            Operation   = "SendOnBehalf"
            Friendly    = "Sent on Behalf of Mailbox"
            RecordType  = "ExchangeItem"
            Description = "Message sent on behalf of another user"
        },
        [PSCustomObject]@{
            Category    = "Email Sending & Transmission"
            Operation   = "Send"
            Friendly    = "Sent Email"
            RecordType  = "ExchangeItem"
            Description = "Message sent directly by the primary mailbox owner"
        },
        [PSCustomObject]@{
            Category    = "Email Sending & Transmission"
            Operation   = "Submit"
            Friendly    = "Submitted Message"
            RecordType  = "ExchangeItem"
            Description = "Outbound message submitted to Exchange transport pipeline"
        },

        # --- Category 3: Item Deletions, Purges & Moves ---
        [PSCustomObject]@{
            Category    = "Deletions, Purges & Moves"
            Operation   = "SoftDelete"
            Friendly    = "Deleted (Recoverable)"
            RecordType  = "ExchangeItem"
            Description = "Item deleted to Deleted Items or Recoverable Items folder"
        },
        [PSCustomObject]@{
            Category    = "Deletions, Purges & Moves"
            Operation   = "HardDelete"
            Friendly    = "Permanently Purged Item"
            RecordType  = "ExchangeItem"
            Description = "Item permanently deleted from Recoverable Items (bypassing dumpster)"
        },
        [PSCustomObject]@{
            Category    = "Deletions, Purges & Moves"
            Operation   = "MoveToDeletedItems"
            Friendly    = "Moved to Trash"
            RecordType  = "ExchangeItem"
            Description = "Item moved into the Deleted Items folder"
        },
        [PSCustomObject]@{
            Category    = "Deletions, Purges & Moves"
            Operation   = "Move"
            Friendly    = "Moved Item"
            RecordType  = "ExchangeItem"
            Description = "Item moved from one mailbox folder to another"
        },
        [PSCustomObject]@{
            Category    = "Deletions, Purges & Moves"
            Operation   = "EmptyFolder"
            Friendly    = "Emptied Folder"
            RecordType  = "ExchangeItem"
            Description = "Entire folder emptied by user or retention process"
        },

        # --- Category 4: Mailbox Permissions & Delegation ---
        [PSCustomObject]@{
            Category    = "Permissions & Delegation"
            Operation   = "Add-MailboxPermission"
            Friendly    = "Granted FullAccess/Read"
            RecordType  = "ExchangeAdmin"
            Description = "Granted FullAccess, ReadPermission, or ChangeOwner rights"
        },
        [PSCustomObject]@{
            Category    = "Permissions & Delegation"
            Operation   = "Remove-MailboxPermission"
            Friendly    = "Revoked FullAccess/Read"
            RecordType  = "ExchangeAdmin"
            Description = "Revoked FullAccess or Read permissions from a delegate"
        },
        [PSCustomObject]@{
            Category    = "Permissions & Delegation"
            Operation   = "Add-RecipientPermission"
            Friendly    = "Granted SendAs Right"
            RecordType  = "ExchangeAdmin"
            Description = "Granted SendAs permission to a trustee"
        },
        [PSCustomObject]@{
            Category    = "Permissions & Delegation"
            Operation   = "Remove-RecipientPermission"
            Friendly    = "Revoked SendAs Right"
            RecordType  = "ExchangeAdmin"
            Description = "Revoked SendAs permission from a trustee"
        },
        [PSCustomObject]@{
            Category    = "Permissions & Delegation"
            Operation   = "Set-Mailbox"
            Friendly    = "Modified Mailbox Config"
            RecordType  = "ExchangeAdmin"
            Description = "Modified mailbox properties, quotas, forwarding, or delegation"
        },

        # --- Category 5: Rules & Forwarding Automation ---
        [PSCustomObject]@{
            Category    = "Rules & Forwarding Automation"
            Operation   = "New-InboxRule"
            Friendly    = "Created Inbox Rule"
            RecordType  = "ExchangeItem"
            Description = "Created an automated inbox rule (common phishing/exfiltration vector)"
        },
        [PSCustomObject]@{
            Category    = "Rules & Forwarding Automation"
            Operation   = "Set-InboxRule"
            Friendly    = "Modified Inbox Rule"
            RecordType  = "ExchangeItem"
            Description = "Modified an existing inbox rule or forwarding action"
        },
        [PSCustomObject]@{
            Category    = "Rules & Forwarding Automation"
            Operation   = "Enable-InboxRule"
            Friendly    = "Enabled Inbox Rule"
            RecordType  = "ExchangeItem"
            Description = "Re-enabled a disabled inbox rule"
        },
        [PSCustomObject]@{
            Category    = "Rules & Forwarding Automation"
            Operation   = "Disable-InboxRule"
            Friendly    = "Disabled Inbox Rule"
            RecordType  = "ExchangeItem"
            Description = "Disabled an active inbox rule"
        },
        [PSCustomObject]@{
            Category    = "Rules & Forwarding Automation"
            Operation   = "Remove-InboxRule"
            Friendly    = "Deleted Inbox Rule"
            RecordType  = "ExchangeItem"
            Description = "Deleted an inbox rule"
        },

        # --- Category 6: Modern Sign-In & Authentication ---
        [PSCustomObject]@{
            Category    = "Sign-In & Authentication"
            Operation   = "UserLoggedIn"
            Friendly    = "Successful User Sign-In"
            RecordType  = "AzureActiveDirectoryStsLogon"
            Description = "Successful user authentication to Microsoft 365 / Exchange"
        },
        [PSCustomObject]@{
            Category    = "Sign-In & Authentication"
            Operation   = "UserLoginFailed"
            Friendly    = "Failed User Sign-In"
            RecordType  = "AzureActiveDirectoryStsLogon"
            Description = "Failed sign-in attempt (bad credentials, locked account, or MFA failure)"
        },

        # --- Category 7: Exchange Admin & Transport Routing ---
        [PSCustomObject]@{
            Category    = "Exchange Admin & Mail Flow"
            Operation   = "New-TransportRule"
            Friendly    = "Created Mail Flow Rule"
            RecordType  = "ExchangeAdmin"
            Description = "Created organization-wide mail flow (transport) rule"
        },
        [PSCustomObject]@{
            Category    = "Exchange Admin & Mail Flow"
            Operation   = "Set-TransportRule"
            Friendly    = "Modified Mail Flow Rule"
            RecordType  = "ExchangeAdmin"
            Description = "Modified transport rule conditions or actions"
        },
        [PSCustomObject]@{
            Category    = "Exchange Admin & Mail Flow"
            Operation   = "Remove-TransportRule"
            Friendly    = "Deleted Mail Flow Rule"
            RecordType  = "ExchangeAdmin"
            Description = "Deleted an organization mail flow rule"
        },
        [PSCustomObject]@{
            Category    = "Exchange Admin & Mail Flow"
            Operation   = "Enable-Mailbox"
            Friendly    = "Enabled Mailbox/Archive"
            RecordType  = "ExchangeAdmin"
            Description = "Provisioned a mailbox or enabled online archiving / auto-expansion"
        },
        [PSCustomObject]@{
            Category    = "Exchange Admin & Mail Flow"
            Operation   = "Disable-Mailbox"
            Friendly    = "Disabled Mailbox/Archive"
            RecordType  = "ExchangeAdmin"
            Description = "Deprovisioned a mailbox or disconnected an archive"
        },
        [PSCustomObject]@{
            Category    = "Exchange Admin & Mail Flow"
            Operation   = "Set-TransportConfig"
            Friendly    = "Modified Transport Config"
            RecordType  = "ExchangeAdmin"
            Description = "Altered organization-level mail routing or message size parameters"
        },

        # --- Category 8: Compliance, Retention & eDiscovery ---
        [PSCustomObject]@{
            Category    = "Compliance & eDiscovery"
            Operation   = "SearchExportDownloaded"
            Friendly    = "Export Downloaded"
            RecordType  = "SecurityComplianceCenter"
            Description = "eDiscovery or content search export archive downloaded"
        },
        [PSCustomObject]@{
            Category    = "Compliance & eDiscovery"
            Operation   = "SearchExportCreated"
            Friendly    = "Export Package Created"
            RecordType  = "SecurityComplianceCenter"
            Description = "Content search export package generated"
        },
        [PSCustomObject]@{
            Category    = "Compliance & eDiscovery"
            Operation   = "New-RetentionCompliancePolicy"
            Friendly    = "Created Retention Policy"
            RecordType  = "ComplianceDLP"
            Description = "Created organization retention compliance policy"
        },
        [PSCustomObject]@{
            Category    = "Compliance & eDiscovery"
            Operation   = "Set-RetentionCompliancePolicy"
            Friendly    = "Modified Retention Policy"
            RecordType  = "ComplianceDLP"
            Description = "Modified organization retention policy rules or tag scopes"
        }
    )
}

function Show-AuditOperationsCatalog {
    $Catalog = Get-AuditOperationsCatalog
    $FilterKeyword = ""

    while ($true) {
        Clear-Host
        Write-Host "=========================================================================================================" -ForegroundColor Cyan
        Write-Host "                             UNIFIED AUDIT LOG OPERATIONS CATALOG                                       " -ForegroundColor Cyan
        Write-Host "=========================================================================================================" -ForegroundColor Cyan
        Write-Host " Browse all searchable operations grouped by category with brief descriptions." -ForegroundColor Gray
        if (-not [string]::IsNullOrWhiteSpace($FilterKeyword)) {
            Write-Host " [KEYWORD FILTER: '$FilterKeyword'] - Type 'ALL' to reset" -ForegroundColor Yellow
        }
        Write-Host "---------------------------------------------------------------------------------------------------------" -ForegroundColor Gray

        $FilteredItems = if ([string]::IsNullOrWhiteSpace($FilterKeyword)) {
            $Catalog
        } else {
            @($Catalog | Where-Object { 
                $_.Category -like "*$FilterKeyword*" -or 
                $_.Operation -like "*$FilterKeyword*" -or 
                $_.Friendly -like "*$FilterKeyword*" -or 
                $_.Description -like "*$FilterKeyword*" 
            })
        }

        # Group by Category
        $Grouped = $FilteredItems | Group-Object Category
        $Index = 1
        $IndexMap = @{}

        foreach ($grp in $Grouped) {
            Write-Host "`n [ CATEGORY: $($grp.Name.ToUpper()) ]" -ForegroundColor Yellow
            $FormatStr = "  {0,-5} {1,-30} {2,-26} {3}"
            Write-Host ($FormatStr -f "#", "OPERATION (API)", "FRIENDLY NAME", "BRIEF DESCRIPTION") -ForegroundColor White
            Write-Host "  -------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
            foreach ($item in $grp.Group) {
                $IndexMap[$Index] = $item
                Write-Host ($FormatStr -f "[$Index]", $item.Operation, $item.Friendly, $item.Description) -ForegroundColor Gray
                $Index++
            }
        }

        Write-Host "`n=========================================================================================================" -ForegroundColor Gray
        Write-Host " COMMANDS:" -ForegroundColor Cyan
        Write-Host "  [#] Enter number to select operation to search (e.g. 1)" -ForegroundColor White
        Write-Host "  [F] Filter by keyword (e.g. type 'rule', 'delete', 'send')" -ForegroundColor Yellow
        Write-Host "  [0] Return to Filter Options" -ForegroundColor DarkGray
        Write-Host "=========================================================================================================" -ForegroundColor Gray

        $Cmd = (Read-Host "Command").Trim()

        if ($Cmd -eq "0" -or [string]::IsNullOrWhiteSpace($Cmd)) {
            return $null
        }

        if ($Cmd -match '^\d+$') {
            $SelectedIdx = [int]$Cmd
            if ($IndexMap.ContainsKey($SelectedIdx)) {
                $Chosen = $IndexMap[$SelectedIdx]
                Write-Host "`nSelected Operation: $($Chosen.Operation) ($($Chosen.Friendly))" -ForegroundColor Green
                Start-Sleep -Milliseconds 600
                return $Chosen
            } else {
                Write-Host "Invalid operation index number." -ForegroundColor Red
                Start-Sleep -Seconds 1
                continue
            }
        }

        if ($Cmd -imatch '^F(\s+.*)?$') {
            $K = (Read-Host "Enter search keyword (or Enter to clear)").Trim()
            $FilterKeyword = $K
            continue
        }

        if ($Cmd -ieq "ALL") {
            $FilterKeyword = ""
            continue
        }

        # If user directly typed a search keyword
        $FilterKeyword = $Cmd
    }
}

function Get-FriendlyAuditOperation {
    param([string]$Operation)

    if ([string]::IsNullOrWhiteSpace($Operation)) { return "Unknown Event" }

    # Quick catalog match if available
    $CatalogMatch = Get-AuditOperationsCatalog | Where-Object { $_.Operation -ieq $Operation } | Select-Object -First 1
    if ($CatalogMatch) {
        return $CatalogMatch.Friendly
    }

    switch -Exact ($Operation) {
        # Mailbox read/bind
        "MailItemsAccessed"          { return "Read/Accessed Email" }
        "MessageBind"                { return "Opened Single Message" }
        "FolderBind"                 { return "Accessed Folder" }
        
        # Email transmission
        "SendAs"                     { return "Sent As Mailbox" }
        "SendOnBehalf"               { return "Sent on Behalf of Mailbox" }
        "Send"                       { return "Sent Email" }
        "Submit"                     { return "Submitted Message" }

        # Deletions / Purges
        "SoftDelete"                 { return "Deleted (Recoverable)" }
        "HardDelete"                 { return "Permanently Purged Item" }
        "MoveToDeletedItems"         { return "Moved to Trash" }
        "Move"                       { return "Moved Item" }

        # Permissions & Admin
        "Add-MailboxPermission"      { return "Granted FullAccess/Read" }
        "Remove-MailboxPermission"   { return "Revoked FullAccess/Read" }
        "Add-RecipientPermission"    { return "Granted SendAs Right" }
        "Remove-RecipientPermission" { return "Revoked SendAs Right" }
        "Set-Mailbox"                { return "Modified Mailbox Config" }

        # Rules
        "New-InboxRule"              { return "Created Inbox Rule" }
        "Set-InboxRule"              { return "Modified Inbox Rule" }
        "Enable-InboxRule"           { return "Enabled Inbox Rule" }
        "Disable-InboxRule"          { return "Disabled Inbox Rule" }
        "Remove-InboxRule"           { return "Deleted Inbox Rule" }

        # Sign-in
        "UserLoggedIn"               { return "Successful Sign-In" }
        "UserLoginFailed"            { return "Failed Sign-In" }

        # Default fallback
        Default                      { return $Operation }
    }
}

function Invoke-AuditLogMenu {
    if ($Global:TenantName -eq "Disconnected") {
        Clear-Host
        Write-Host "=====================================================================" -ForegroundColor Red
        Write-Host "                         NO ACTIVE CONNECTION                        " -ForegroundColor Red
        Write-Host "=====================================================================" -ForegroundColor Red
        Write-Host "You must authenticate to Exchange Online before searching audit logs." -ForegroundColor Yellow
        Wait-Console "Press Enter to return..."
        return
    }

    $AuditMenuRunning = $true
    while ($AuditMenuRunning) {
        Clear-Host
        Write-Host "=====================================================================" -ForegroundColor Cyan
        Write-Host "              EXCHANGE ONLINE UNIFIED AUDIT LOG AUDITOR              " -ForegroundColor Cyan
        Write-Host "=====================================================================" -ForegroundColor Cyan
        Write-Host " Tenant: $Global:TenantName" -ForegroundColor White
        Write-Host "---------------------------------------------------------------------"
        Write-Host " 1. Audit Events from Today"
        Write-Host " 2. Audit Events from Last 24 Hours"
        Write-Host " 3. Audit Events from Last 7 Days"
        Write-Host " 4. Audit Events on a Specific Date (Single Day)"
        Write-Host " 5. Audit Events within a Custom Date Range"
        Write-Host " 0. Return to Main Menu"
        Write-Host "---------------------------------------------------------------------"

        $Choice = (Read-Host "Selection").Trim()

        $Now = Get-Date
        $StartDate = $null
        $EndDate = $null

        switch ($Choice) {
            "1" {
                $StartDate = $Now.Date
                $EndDate = $Now
            }
            "2" {
                $StartDate = $Now.AddHours(-24)
                $EndDate = $Now
            }
            "3" {
                $StartDate = $Now.AddDays(-7)
                $EndDate = $Now
            }
            "4" {
                $DateInput = Read-ValidDate -Prompt "Enter audit date (YYYY-MM-DD)"
                if ($null -eq $DateInput) { continue }
                $StartDate = $DateInput.Date
                $EndDate = $DateInput.Date.AddDays(1).AddSeconds(-1)
                if ($EndDate -gt $Now) { $EndDate = $Now }
            }
            "5" {
                $StartInput = Read-ValidDate -Prompt "Enter Start Date (YYYY-MM-DD)"
                if ($null -eq $StartInput) { continue }
                $EndInput = Read-ValidDate -Prompt "Enter End Date (YYYY-MM-DD)"
                if ($null -eq $EndInput) { continue }

                $StartDate = $StartInput.Date
                $EndDate = $EndInput.Date.AddDays(1).AddSeconds(-1)

                if ($StartDate -gt $EndDate) {
                    Write-Host "`n[ERROR] Start Date cannot be later than End Date." -ForegroundColor Red
                    Start-Sleep -Seconds 1.5
                    continue
                }
                if ($EndDate -gt $Now) {
                    $EndDate = $Now
                }
            }
            "0" {
                return
            }
            Default {
                Write-Host "Invalid selection. Please choose 0 to 5." -ForegroundColor Red
                Start-Sleep -Seconds 1
                continue
            }
        }

        # Guard against cancelled date selection or menu exit
        if (-not $AuditMenuRunning -or $null -eq $StartDate -or $null -eq $EndDate) {
            continue
        }

        # Interactive / Human-Friendly Filter Selection
        Clear-Host
        Write-Host "=====================================================================" -ForegroundColor Cyan
        Write-Host "                     AUDIT LOG FILTER OPTIONS                        " -ForegroundColor Cyan
        Write-Host "=====================================================================" -ForegroundColor Cyan
        Write-Host " Time Window: $($StartDate.ToString('yyyy-MM-dd HH:mm:ss')) to $($EndDate.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Yellow
        Write-Host "---------------------------------------------------------------------"
        Write-Host " 1. All Audit Events (No activity filter)" -ForegroundColor White
        Write-Host " 2. Mailbox Access / Compromise Investigation (Read/Accessed/Downloaded)" -ForegroundColor White
        Write-Host " 3. Email Sending / Impersonation (Sent As, Sent on Behalf)" -ForegroundColor White
        Write-Host " 4. Deleted Items & Purges (Soft/Hard Deletes, Emptied Trash)" -ForegroundColor White
        Write-Host " 5. Admin & Mailbox Permission Changes (Delegation, FullAccess, SendAs)" -ForegroundColor White
        Write-Host " 6. Mailbox Configuration & Forwarding Rules (Inbox rules, Set-Mailbox)" -ForegroundColor White
        Write-Host " 7. Modern Sign-in & Authentication Events (UserLoggedIn, STS Tokens)" -ForegroundColor White
        Write-Host " 8. Browse & Search All Operations Catalog (Grouped by Category)" -ForegroundColor Cyan
        Write-Host " 9. Custom / Manual Filter (Enter exact Exchange/Purview strings)" -ForegroundColor Gray
        Write-Host " 0. Cancel & Return to Timeframe Menu" -ForegroundColor DarkGray
        Write-Host "---------------------------------------------------------------------"
        $ActivityChoice = (Read-Host "Select activity profile (1-9, Default: 1)").Trim()

        if ($ActivityChoice -eq "0") {
            continue
        }

        $UserFilter = ""
        $OpFilter   = ""
        $RecordType = ""

        switch ($ActivityChoice) {
            "2" {
                $OpFilter = "MailItemsAccessed,MessageBind,FolderBind"
                $RecordType = "ExchangeItem"
                Write-Host "`nSelected Profile: Mailbox Access / Read Activities" -ForegroundColor Green
            }
            "3" {
                $OpFilter = "SendAs,SendOnBehalf,Send"
                $RecordType = "ExchangeItem"
                Write-Host "`nSelected Profile: Sent / Impersonation Activities" -ForegroundColor Green
            }
            "4" {
                $OpFilter = "SoftDelete,HardDelete,MoveToDeletedItems"
                $RecordType = "ExchangeItem"
                Write-Host "`nSelected Profile: Deletion & Purge Activities" -ForegroundColor Green
            }
            "5" {
                $OpFilter = "Add-MailboxPermission,Remove-MailboxPermission,Add-RecipientPermission,Remove-RecipientPermission,Set-Mailbox"
                Write-Host "`nSelected Profile: Permission & Admin Changes" -ForegroundColor Green
            }
            "6" {
                $OpFilter = "New-InboxRule,Set-InboxRule,Enable-InboxRule,Set-Mailbox"
                Write-Host "`nSelected Profile: Rules & Configuration Updates" -ForegroundColor Green
            }
            "7" {
                $OpFilter = "UserLoggedIn,UserLoginFailed"
                $RecordType = "AzureActiveDirectoryStsLogon"
                Write-Host "`nSelected Profile: User Sign-in & Authentication" -ForegroundColor Green
            }
            "8" {
                $ChosenCatalogItem = Show-AuditOperationsCatalog
                if ($ChosenCatalogItem) {
                    $OpFilter = $ChosenCatalogItem.Operation
                    if ($ChosenCatalogItem.RecordType) { $RecordType = $ChosenCatalogItem.RecordType }
                    Write-Host "`nSelected Operation from Catalog: $($ChosenCatalogItem.Operation) ($($ChosenCatalogItem.Friendly))" -ForegroundColor Green
                } else {
                    Write-Host "`nCatalog browser closed without selection. Defaulting to all activities." -ForegroundColor Yellow
                }
            }
            "9" {
                Write-Host "`nEnter manual search strings (or press Enter to skip):" -ForegroundColor Gray
                $OpFilter   = (Read-Host " Filter by Operation (e.g. MailItemsAccessed, SendAs)").Trim()
                $RecordType = (Read-Host " Filter by RecordType (e.g. ExchangeItem, ExchangeAdmin)").Trim()
            }
            Default {
                Write-Host "`nSelected Profile: All Audit Events (No Activity Filter)" -ForegroundColor Green
            }
        }

        Write-Host "`nUser / Mailbox Filter (Optional):" -ForegroundColor Cyan
        $TargetMbx = Resolve-MailboxIdentity -Prompt "Filter by User / Mailbox (Name, Alias, or UPN)" -AllowSkip
        $UserFilter = if ($TargetMbx) { $TargetMbx.UserPrincipalName } else { "" }
        if (-not [string]::IsNullOrWhiteSpace($UserFilter)) {
            Write-Host "Audit query locked to target: $($TargetMbx.DisplayName) ($UserFilter)" -ForegroundColor Green
        } else {
            Write-Host "Searching across all tenant mailboxes and user accounts." -ForegroundColor DarkGray
        }

        Execute-AuditLogQuery -StartDate $StartDate -EndDate $EndDate -UserFilter $UserFilter -OpFilter $OpFilter -RecordType $RecordType
    }
}

function Read-ValidDate {
    param([string]$Prompt)

    while ($true) {
        Write-Host "`n$Prompt (or '0' to cancel):" -ForegroundColor Gray
        $RawInput = (Read-Host "Date").Trim()

        if ($RawInput -eq "0" -or [string]::IsNullOrWhiteSpace($RawInput)) {
            return $null
        }

        $ParsedDate = [DateTime]::MinValue
        $Formats = @("yyyy-MM-dd", "yyyy/MM/dd", "dd-MM-yyyy", "dd/MM/yyyy")
        $Valid = [DateTime]::TryParseExact($RawInput, $Formats, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None, [ref]$ParsedDate)
        
        if (-not $Valid) {
            $Valid = [DateTime]::TryParse($RawInput, [ref]$ParsedDate)
        }

        if ($Valid) {
            if ($ParsedDate -gt (Get-Date)) {
                Write-Host "[ERROR] Date cannot be in the future." -ForegroundColor Red
                continue
            }
            return $ParsedDate
        }

        Write-Host "[ERROR] Invalid date format. Please use YYYY-MM-DD (e.g. 2026-11-12)." -ForegroundColor Red
    }
}

function Execute-AuditLogQuery {
    param(
        [DateTime]$StartDate,
        [DateTime]$EndDate,
        [string]$UserFilter,
        [string]$OpFilter,
        [string]$RecordType
    )

    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "                   QUERYING UNIFIED AUDIT LOG                        " -ForegroundColor Cyan
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host " Start Time:   $($StartDate.ToString('yyyy-MM-dd HH:mm:ss')) (Local)" -ForegroundColor Gray
    Write-Host " End Time:     $($EndDate.ToString('yyyy-MM-dd HH:mm:ss')) (Local)" -ForegroundColor Gray
    if (-not [string]::IsNullOrWhiteSpace($UserFilter)) { Write-Host " User Filter:  $UserFilter" -ForegroundColor Gray }
    if (-not [string]::IsNullOrWhiteSpace($OpFilter))   { Write-Host " Operation:    $OpFilter" -ForegroundColor Gray }
    if (-not [string]::IsNullOrWhiteSpace($RecordType)) { Write-Host " RecordType:   $RecordType" -ForegroundColor Gray }
    Write-Host "---------------------------------------------------------------------"
    Write-Host "Submitting search request to Microsoft Purview / Exchange Online..." -ForegroundColor DarkGray

    $QueryParams = @{
        StartDate  = $StartDate
        EndDate    = $EndDate
        ResultSize = 5000
        ErrorAction = "Stop"
    }

    if (-not [string]::IsNullOrWhiteSpace($UserFilter)) { 
        $QueryParams["UserIds"] = $UserFilter 
    }
    if (-not [string]::IsNullOrWhiteSpace($OpFilter)) { 
        # Support comma-separated strings as string array for Search-UnifiedAuditLog
        $OpArray = @($OpFilter -split ',' | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        if ($OpArray.Count -gt 0) {
            $QueryParams["Operations"] = $OpArray
        }
    }
    if (-not [string]::IsNullOrWhiteSpace($RecordType)) { 
        $QueryParams["RecordType"] = $RecordType 
    }

    try {
        $RawEvents = @(Search-UnifiedAuditLog @QueryParams)
    }
    catch {
        Write-Host "`n[AUDIT LOG ERROR] Failed to query Unified Audit Log." -ForegroundColor Red
        Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "`nEnsure your account has the 'View-Only Audit Logs' or 'Audit Logs' role" -ForegroundColor Yellow
        Write-Host "and that Unified Auditing is enabled in your Microsoft 365 tenant." -ForegroundColor Yellow
        Wait-Console
        return
    }

    if ($RawEvents.Count -eq 0) {
        Write-Host "`n[RESULT] No audit events found matching the specified timeframe and criteria." -ForegroundColor Yellow
        Wait-Console
        return
    }

    # Transform events into display-friendly objects
    $EventsList = [System.Collections.Generic.List[PSCustomObject]]::new()
    $Idx = 1
    foreach ($evt in $RawEvents) {
        $FriendlyOp = Get-FriendlyAuditOperation -Operation $evt.Operations
        $EventsList.Add([PSCustomObject]@{
            Index        = $Idx
            CreationDate = $evt.CreationDate
            UserIds      = if ($evt.UserIds) { $evt.UserIds } else { "N/A" }
            Operations   = $evt.Operations
            FriendlyOp   = $FriendlyOp
            RecordType   = $evt.RecordType
            ResultStatus = if ($evt.ResultStatus) { $evt.ResultStatus } else { "Success" }
            AuditData    = $evt.AuditData
        })
        $Idx++
    }

    # Paginated Display Viewer
    Show-AuditLogViewer -AuditRecords $EventsList -StartDate $StartDate -EndDate $EndDate
}

function Show-AuditLogViewer {
    param(
        [System.Collections.Generic.List[PSCustomObject]]$AuditRecords,
        [DateTime]$StartDate,
        [DateTime]$EndDate
    )

    $PageSize = 15
    $CurrentPage = 1
    $TotalPages = [math]::Max(1, [math]::Ceiling($AuditRecords.Count / $PageSize))

    $Viewing = $true
    while ($Viewing) {
        Clear-Host
        $StartIndex = ($CurrentPage - 1) * $PageSize
        $PageItems = @($AuditRecords | Select-Object -Skip $StartIndex -First $PageSize)

        Write-Host "=========================================================================================================" -ForegroundColor Cyan
        Write-Host "                                   UNIFIED AUDIT LOG RESULTS                                             " -ForegroundColor Cyan
        Write-Host "=========================================================================================================" -ForegroundColor Cyan
        Write-Host (" Total Events: {0} | Page: {1} of {2} | Window: {3} to {4}" -f $AuditRecords.Count, $CurrentPage, $TotalPages, $StartDate.ToString("yyyy-MM-dd"), $EndDate.ToString("yyyy-MM-dd")) -ForegroundColor Yellow
        Write-Host "=========================================================================================================" -ForegroundColor Gray

        $FormatStr = "{0,-4} {1,-20} {2,-28} {3,-32} {4,-15}"
        Write-Host ($FormatStr -f "#", "TIMESTAMP", "USER / IDENTITY", "ACTIVITY / EVENT", "RECORD TYPE") -ForegroundColor White
        Write-Host "---------------------------------------------------------------------------------------------------------" -ForegroundColor Gray

        foreach ($item in $PageItems) {
            $DateStr = if ($item.CreationDate) { $item.CreationDate.ToString("yyyy-MM-dd HH:mm:ss") } else { "Unknown" }
            $UserStr = if ($item.UserIds.Length -gt 26) { $item.UserIds.Substring(0, 23) + "..." } else { $item.UserIds }
            
            # Show friendly description if available, otherwise raw operation
            $DisplayOp = if (-not [string]::IsNullOrWhiteSpace($item.FriendlyOp)) { $item.FriendlyOp } else { $item.Operations }
            if ($DisplayOp.Length -gt 30) { $DisplayOp = $DisplayOp.Substring(0, 27) + "..." }
            
            $RecStr = if ($item.RecordType.ToString().Length -gt 15) { $item.RecordType.ToString().Substring(0, 12) + "..." } else { $item.RecordType }

            Write-Host ($FormatStr -f $item.Index, $DateStr, $UserStr, $DisplayOp, $RecStr) -ForegroundColor Green
        }

        Write-Host "=========================================================================================================" -ForegroundColor Gray
        Write-Host " COMMANDS:" -ForegroundColor Yellow
        Write-Host "  [N] Next Page  | [P] Previous Page  | [E] Export All to CSV" -ForegroundColor Gray
        Write-Host "  [#] View Record Detail JSON (e.g. enter record index number)" -ForegroundColor Gray
        Write-Host "  [0] Return to Audit Menu" -ForegroundColor DarkGray
        Write-Host "=========================================================================================================" -ForegroundColor Gray

        $Cmd = (Read-Host "Command").Trim()

        switch -Regex ($Cmd) {
            "^0$" { $Viewing = $false }
            "(?i)^N$" {
                if ($CurrentPage -lt $TotalPages) { $CurrentPage++ }
                else { Write-Host "Already on the last page." -ForegroundColor Yellow; Start-Sleep -Milliseconds 600 }
            }
            "(?i)^P$" {
                if ($CurrentPage -gt 1) { $CurrentPage-- }
                else { Write-Host "Already on the first page." -ForegroundColor Yellow; Start-Sleep -Milliseconds 600 }
            }
            "(?i)^E$" {
                Export-AuditRecordsToCsv -Records $AuditRecords
            }
            "^\d+$" {
                $RecordId = [int]$Cmd
                $Matched = $AuditRecords | Where-Object { $_.Index -eq $RecordId }
                if ($Matched) {
                    Show-AuditRecordDetails -Record $Matched
                } else {
                    Write-Host "Invalid record number." -ForegroundColor Red
                    Start-Sleep -Seconds 1
                }
            }
            Default {
                Write-Host "Invalid command." -ForegroundColor Red
                Start-Sleep -Milliseconds 600
            }
        }
    }
}

function Show-AuditRecordDetails {
    param([PSCustomObject]$Record)

    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "                       AUDIT RECORD DETAILS                          " -ForegroundColor Cyan
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host " Index:       $($Record.Index)" -ForegroundColor White
    Write-Host " Timestamp:   $($Record.CreationDate)" -ForegroundColor White
    Write-Host " User:        $($Record.UserIds)" -ForegroundColor Yellow
    Write-Host " Activity:    $($Record.FriendlyOp)" -ForegroundColor Green
    Write-Host " Raw Op:      $($Record.Operations)" -ForegroundColor DarkGray
    Write-Host " RecordType:  $($Record.RecordType)" -ForegroundColor Gray
    Write-Host " Status:      $($Record.ResultStatus)" -ForegroundColor Gray
    Write-Host "---------------------------------------------------------------------"
    Write-Host " Extended Payload (AuditData):" -ForegroundColor Cyan

    if (-not [string]::IsNullOrWhiteSpace($Record.AuditData)) {
        try {
            $JsonObj = $Record.AuditData | ConvertFrom-Json
            $JsonObj | Format-List | Out-String | Write-Host -ForegroundColor DarkCyan
        }
        catch {
            Write-Host $Record.AuditData -ForegroundColor DarkGray
        }
    } else {
        Write-Host "[No extended AuditData payload present]" -ForegroundColor DarkGray
    }

    Write-Host "=====================================================================" -ForegroundColor Cyan
    Wait-Console "Press Enter to return to audit log viewer..."
}

function Export-AuditRecordsToCsv {
    param([System.Collections.Generic.List[PSCustomObject]]$Records)

    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "                  EXPORT AUDIT LOG RESULTS TO CSV                    " -ForegroundColor Cyan
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host " Total Records to export: $($Records.Count)" -ForegroundColor Gray
    
    $TargetDir = (Read-Host "`nEnter export directory (leave empty for current directory, or '0' to cancel)").Trim()
    if ($TargetDir -eq "0") { return }
    if ([string]::IsNullOrWhiteSpace($TargetDir)) { $TargetDir = "." }

    if (-not (Test-Path -Path $TargetDir)) {
        try { New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null }
        catch { $TargetDir = "." }
    }

    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $FilePath = Join-Path $TargetDir "EXO_AuditLog_$Timestamp.csv"

    Write-Host "Writing audit records to CSV..." -ForegroundColor Gray
    try {
        $Records | Select-Object Index, CreationDate, UserIds, FriendlyOp, Operations, RecordType, ResultStatus, AuditData |
            Export-Csv -Path $FilePath -NoTypeInformation -Encoding UTF8
        Write-Host "`n[SUCCESS] Audit records exported successfully:" -ForegroundColor Green
        Write-Host " -> $FilePath" -ForegroundColor Cyan
    }
    catch {
        Write-Host "`n[ERROR] Failed to export CSV: $($_.Exception.Message)" -ForegroundColor Red
    }
    Wait-Console
}
