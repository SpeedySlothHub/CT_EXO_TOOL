function Wait-Console {
    param([string]$Message = "Press Enter to continue...")
    Read-Host "`n$Message"
}

function Write-ToggleStatus {
    param(
        [bool]$State,
        [string]$TrueLabel = "ENABLED",
        [string]$FalseLabel = "DISABLED"
    )
    if ($State) { 
        Write-Host "[$TrueLabel]" -ForegroundColor Green 
    } else { 
        Write-Host "[$FalseLabel]" -ForegroundColor Red 
    }
}

function Get-RawBytes {
    param($ByteField)
    if ($null -eq $ByteField) { return 0 }
    
    $StrValue = $ByteField.ToString().Trim()
    if ($StrValue -ieq "Unlimited") {
        return [double]::PositiveInfinity
    }
    
    # Safely extracts pure digits from complex Exchange strings like "45.12 GB (48,449,112,010 bytes)"
    if ($StrValue -match '\(([\d,]+)\s+bytes\)') {
        return [double]($matches[1] -replace ',','')
    }
    if ($StrValue -match '^\d+$') { 
        return [double]$StrValue 
    }
    return 0
}

function Format-StorageSizeMB {
    param([double]$Bytes)
    if ([double]::IsPositiveInfinity($Bytes)) {
        return "Unlimited"
    }
    return [math]::Round($Bytes / 1MB, 2)
}

function Format-StorageSizeGB {
    param([double]$Bytes)
    if ([double]::IsPositiveInfinity($Bytes)) {
        return "Unlimited"
    }
    return [math]::Round($Bytes / 1GB, 2)
}

function Clear-PolicyTagCache {
    $Global:TenantRetentionTagCache = $null
    $Global:TenantRetentionPolicyCache = $null
}

function Get-ArchiveTagsFromPolicy {
    param([string]$PolicyName)
    if ([string]::IsNullOrWhiteSpace($PolicyName)) { return @() }
    
    # In-memory session cache for tenant retention tags to prevent N individual roundtrips
    if ($null -eq $Global:TenantRetentionTagCache) {
        try {
            $allTags = @(Get-RetentionPolicyTag -ResultSize Unlimited -ErrorAction SilentlyContinue)
            $Global:TenantRetentionTagCache = @{}
            foreach ($t in $allTags) {
                if ($t.Name) { $Global:TenantRetentionTagCache[$t.Name] = $t }
                if ($t.Identity) { $Global:TenantRetentionTagCache[$t.Identity.ToString()] = $t }
                if ($t.Guid) { $Global:TenantRetentionTagCache[$t.Guid.ToString()] = $t }
            }
        }
        catch {
            $Global:TenantRetentionTagCache = @{}
        }
    }

    try {
        if ($null -eq $Global:TenantRetentionPolicyCache) { $Global:TenantRetentionPolicyCache = @{} }
        if (-not $Global:TenantRetentionPolicyCache.ContainsKey($PolicyName)) {
            $Policy = Get-RetentionPolicy -Identity $PolicyName -ErrorAction Stop
            $Global:TenantRetentionPolicyCache[$PolicyName] = $Policy
        } else {
            $Policy = $Global:TenantRetentionPolicyCache[$PolicyName]
        }

        $Tags = [System.Collections.Generic.List[PSCustomObject]]::new()
        foreach ($link in $Policy.RetentionPolicyTagLinks) {
            $linkStr = $link.ToString()
            $tagObj = $null
            if ($Global:TenantRetentionTagCache.ContainsKey($linkStr)) {
                $tagObj = $Global:TenantRetentionTagCache[$linkStr]
            } else {
                # Fallback in case tag was created after initial cache
                $tagObj = Get-RetentionPolicyTag -Identity $link -ErrorAction SilentlyContinue
                if ($tagObj) { 
                    $Global:TenantRetentionTagCache[$linkStr] = $tagObj 
                    if ($tagObj.Name) { $Global:TenantRetentionTagCache[$tagObj.Name] = $tagObj }
                }
            }
            if ($tagObj -and $tagObj.RetentionAction -eq "MoveToArchive") {
                $Tags.Add($tagObj)
            }
        }
        return $Tags
    }
    catch {
        return @()
    }
}

function Get-CalendarFolderPath {
    param([string]$UserPrincipalName)
    try {
        # Check folder statistics to resolve regional calendar names (e.g. Kalender, Calendrier)
        $CalFolder = Get-MailboxFolderStatistics -Identity $UserPrincipalName -FolderScope Calendar -ErrorAction Stop |
            Select-Object -First 1
        if ($CalFolder -and $CalFolder.FolderPath) {
            $CleanPath = $CalFolder.FolderPath.TrimStart('/') -replace '/', '\'
            return "$($UserPrincipalName):\$CleanPath"
        }
    }
    catch {
        # Fallback to standard default
    }
    return "$($UserPrincipalName):\Calendar"
}
