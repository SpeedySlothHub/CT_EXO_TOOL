function Resolve-MailboxIdentity {
    param(
        [string]$InitialQuery = "",
        [string]$Prompt = "Search Mailbox (Display Name, Alias, or UPN)",
        [switch]$AllowCancel,
        [switch]$AllowSkip
    )

    if ($Global:TenantName -eq "Disconnected") {
        Write-Host "`n[ERROR] No active Exchange Online connection." -ForegroundColor Red
        return $null
    }

    $FirstAttempt = $true
    while ($true) {
        if ($FirstAttempt -and -not [string]::IsNullOrWhiteSpace($InitialQuery)) {
            $Query = $InitialQuery.Trim()
            $FirstAttempt = $false
        } else {
            $CancelHint = if ($AllowSkip) { " (or press Enter to search all/skip)" } elseif ($AllowCancel) { " (or '0' to cancel)" } else { " (or '0' to return)" }
            Write-Host "`n$Prompt$CancelHint" -ForegroundColor Cyan
            $Query = (Read-Host "Search Term").Trim()
            $FirstAttempt = $false
        }

        if ($AllowSkip -and [string]::IsNullOrWhiteSpace($Query)) {
            return $null
        }

        if ($Query -eq "0" -or [string]::IsNullOrWhiteSpace($Query)) {
            return $null
        }

        Write-Host "Searching Exchange Online directory for '$Query'..." -ForegroundColor Gray
        
        try {
            # 1. Direct exact UPN / PrimarySmtpAddress check if input contains '@'
            if ($Query -match '@') {
                $Exact = Get-Mailbox -Identity $Query -ErrorAction SilentlyContinue
                if ($Exact) {
                    Write-Host "Direct Match: $($Exact.DisplayName) ($($Exact.UserPrincipalName))" -ForegroundColor Green
                    return $Exact
                }
            }

            # 2. Ambiguous Name Resolution (ANR) or prefix lookup
            if ($Query.Length -lt 3) {
                # Fallback for short prefix queries (1-2 chars)
                $FilterString = "DisplayName -like '$Query*' -or Alias -like '$Query*' -or UserPrincipalName -like '$Query*'"
                [array]$Results = @(Get-Mailbox -ResultSize 50 -Filter $FilterString -ErrorAction Stop)
            } else {
                # High-speed Ambiguous Name Resolution for 3+ characters
                [array]$Results = @(Get-Mailbox -ResultSize 50 -Anr $Query -ErrorAction Stop)
            }
        }
        catch {
            Write-Host "`n[SEARCH ERROR] Directory lookup failed: $($_.Exception.Message)" -ForegroundColor Red
            if ($AllowSkip) { return $null }
            Wait-Console "Press Enter to try again..."
            continue
        }

        if ($Results.Count -eq 0) {
            Write-Host "`n[NOTICE] No mailboxes found matching '$Query'." -ForegroundColor Yellow
            if ($AllowSkip) { return $null }
            Start-Sleep -Seconds 1
            continue
        }

        # Scenario A: Exactly one match found
        if ($Results.Count -eq 1) {
            Write-Host "Matched: $($Results[0].DisplayName) ($($Results[0].UserPrincipalName))" -ForegroundColor Green
            return $Results[0]
        }

        # Scenario B: Multiple matches found - present interactive selection table
        Write-Host "`nFound $($Results.Count) matching mailboxes for '$Query':" -ForegroundColor Cyan
        Write-Host "---------------------------------------------------------------------"
        $FormatStr = "{0,-4} {1,-32} {2,-35}"
        Write-Host ($FormatStr -f "#", "Display Name", "UserPrincipalName") -ForegroundColor White
        Write-Host "---------------------------------------------------------------------"
        for ($i = 0; $i -lt $Results.Count; $i++) {
            Write-Host ($FormatStr -f ($i + 1), $Results[$i].DisplayName, $Results[$i].UserPrincipalName)
        }
        Write-Host "---------------------------------------------------------------------"
        Write-Host " 0. Cancel and search again"

        $Selection = (Read-Host "`nSelect mailbox number [1-$($Results.Count)]").Trim()
        if ($Selection -eq "0" -or [string]::IsNullOrWhiteSpace($Selection)) {
            continue
        }

        if ($Selection -match '^\d+$') {
            $Index = [int]$Selection
            if ($Index -ge 1 -and $Index -le $Results.Count) {
                return $Results[$Index - 1]
            }
        }
        
        Write-Host "Invalid selection number." -ForegroundColor Red
        Start-Sleep -Seconds 1
    }
}

function Invoke-Search {
    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "                           USER MAILBOX LOOKUP                       " -ForegroundColor Cyan
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "Search by Display Name, UserPrincipalName (Email), or Alias." -ForegroundColor Gray
    Write-Host "Enter '0' at any time to return to the main menu.`n" -ForegroundColor DarkGray
    return (Resolve-MailboxIdentity -Prompt "Enter mailbox to manage" -AllowCancel)
}
