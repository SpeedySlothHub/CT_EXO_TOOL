# EXO Tool 

A lightweight, technician-focused PowerShell administration tool to simplify Exchange Online management, archiving, storage optimization, calendar delegation, folder analytics, and security audit log investigations.

It automatically handles Exchange Online module verification, authentication sessions, tenant switching, and REST-accelerated queries.

---

### Running the Program

Just double-click **`Run.bat`** to launch.
- The launcher auto-detects PowerShell 7+ (Core / MSI / Store) or falls back cleanly to Windows PowerShell 5.1.
- Automatically handles execution policy parameters so there is no need to modify system-wide security settings.

---

### Key Features & Architecture Highlights

- **Smart Identity Resolution Everywhere**: Powered by `Resolve-MailboxIdentity` across single-mailbox management, calendar delegation, bulk permission assignments, and audit log filters. Search by partial Display Name, Alias, or UPN with interactive candidate disambiguation menus.
- **REST-Accelerated & Cached Performance**: Instant retention policy tag resolution (<0.01s) via intelligent session caching, replacing slow sequential remote queries in Archive Management and Storage Monitor.
- **Bulk Intelligence**: Real-time rolling ETA calculation, throughput rates (`items/sec`), non-blocking cancellation (`Q`/`Esc`), and a dynamic `[H]` Hide Compliant toggle.
- **Human-Readable Audit Engine**: 32+ categorized audit operations with interactive keyword filtering (`[F]`), friendly description mapping, and zero-crash navigation.

---

### Project Structure

```
EXO_Tool/
│
├── Main.ps1                # Main application loop, engine detection & navigation router
├── Run.bat                 # Multi-edition PowerShell bootstrap launcher
│
└── Functions/
    ├── Startup/
    │   ├── DependencyCheck.ps1   # PowerShell & ExchangeOnlineManagement module validator
    │   ├── Search.ps1            # Mailbox search engine (UPN, Name, Email)
    │   ├── SignIn.ps1            # Tenant authentication & identity resolution
    │   └── Switch.ps1            # Clean tenant sign-out and session cache purge
    │
    ├── Mailbox/
    │   ├── 0_UserHub.ps1         # Individual mailbox operations menu
    │   ├── 1_ManageArchive.ps1   # In-place archiving, MRM policies & Managed Folder Assistant
    │   ├── 2_ManageExpansion.ps1 # Auto-expanding archive provisioning & compliance check
    │   ├── 3_StorageMonitor.ps1  # Live telemetry monitor with delta tracking & hotkeys
    │   ├── 4_CalendarSharing.ps1 # Inbound/outbound calendar delegation & localized paths
    │   ├── 5_FolderStatistics.ps1# Folder breakdown, item counts, size metrics & CSV export
    │   └── Utils/
    │       └── Helpers.ps1       # Byte parser, quota math & localization utilities
    │
    ├── Bulk/
    │   ├── BulkOperations.ps1    # Interactive bulk configuration & analytics matrix
    │   └── ExportReport.ps1      # CSV export engine for tenant mailbox audits
    │
    └── Audit/
        └── AuditLog.ps1          # Unified Audit Log investigation & human-readable filter engine
```

---

### Program Menu & Option Breakdown

#### Main Menu
- **1. Single Mailbox Management**: Search for any user or shared mailbox by Name, Alias, or UPN.
- **2. Bulk Operations & Reporting Matrix**: Manage tenant-wide archiving, auto-expansion, and delegations with REST-based analytics.
- **3. Exchange Online Event Audit Log**: Investigate security and operational events using human-friendly activity profiles or custom filters.
- **4. Switch Tenant / Sign Out**: Safely purge active cached objects and reconnect to a different Microsoft 365 tenant.
- **0. Exit**: Cleanly disconnect remote sessions and close the application.

---

#### 1. Single User Hub (`Option 1`)
Once a target mailbox is selected (via partial Display Name, Alias, or UPN with candidate pick-list support), access dedicated administration workflows:
- **1. Archiving & Retention Policies**: Enable/disable archiving, inspect MRM policy tag mappings, adjust retention policies, or force-run the Managed Folder Assistant (`Start-ManagedFolderAssistant`). Tag lookups are cached tenant-wide for instantaneous page loads.
- **2. Auto-Expanding Archive Management**: Review storage limits, verify prerequisites, and provision auto-expanding archives for mailboxes over standard limits.
- **3. Mailbox Storage & Analytics (Live Monitor)**: Real-time telemetry dashboard monitoring primary and archive mailbox consumption, quotas, item counts, and live session delta changes with instant hotkeys (`R` to refresh, `B` to exit). Rapid connection initialization with step-by-step telemetry progress.
- **4. Calendar Sharing & Permissions Delegation**: View existing calendar permissions, grant delegated rights (Editor, Reviewer, etc.), manage send permissions, or revoke shared access. Supports partial search for target delegates.
- **5. View Folder Statistics & Item Counts**: Detailed per-folder diagnostics displaying folder paths, item counts, sizes, deleted/recoverable items, and optional CSV export.
- **0. Return to User Search**: Select another user or return to the main menu.

---

#### 2. Bulk Operations & Reporting (`Option 2`)
An interactive matrix for auditing and configuring dozens or hundreds of mailboxes across the tenant:
- **High-Performance REST Backend with Live ETA**:
  - Dynamically calculates rolling average processing speed per mailbox (`ms/mbx`).
  - Displays remaining completion time (`ETA: mm:ss`) and current throughput rate (`items/sec`).
  - **Graceful Cancellation**: Press `[Q]` or `[Esc]` during mailbox queries or statistics discovery to stop cleanly and immediately work with all mailboxes discovered up to that point.
- **Selection Commands (`[#]`, `[A]`, `[D]`)**: Toggle specific items by index (e.g. `1` or `1,3,5`), select all, or clear choices.
- **Dynamic Compliance Filter (`[H]`)**:
  - **Hide Compliant Mailboxes**: Toggle `[H]` to instantly hide mailboxes that are within healthy storage limits and have active archiving or auto-expansion already configured.
  - Automatically re-evaluates and updates in real-time whenever storage thresholds (`[T]`) are adjusted.
- **Threshold & Account Filters (`[T]`, `[L]`, `[F]`)**: Configure primary and archive quota utilization triggers, filter licensed vs. shared mailboxes, and auto-select mailboxes exceeding thresholds.
- **View Modes (`[V1]`, `[V2]`)**: Switch between Storage Utilization view and Delegation / Retention view.
- **Bulk Action Pipelines**:
  - `STOR1`: Bulk enable or disable online archiving across selected mailboxes.
  - `STOR2`: Bulk enable auto-expanding archives.
  - `STOR3`: Dual-provision both online archiving and auto-expansion in one pass.
  - `SEND1`–`SEND3` / `SEND`: Bulk assign or remove SendAs, SendOnBehalf, or FullAccess permissions with partial delegate name searching.
- **Reporting (`[E]`, `[R]`)**: Export all current tenant metrics to an Excel-friendly CSV or force-refresh live data.

---

#### 3. Exchange Online Event Audit Log (`Option 3`)
Search Microsoft Purview / Exchange Online Unified Audit Logs without needing to memorize raw Exchange cmdlet parameters or backend schema strings:

##### Timeframe Presets
- Today (Midnight to now)
- Last 24 Hours
- Last 7 Days
- Specific Single Date (`YYYY-MM-DD`)
- Custom Date Range (`YYYY-MM-DD` start and end)

##### Human-Readable Activity Profiles & Audit Operations Catalog
Rather than typing cryptic Exchange operation strings, technicians can select from common MSP incident profiles or browse the comprehensive operation dictionary:
1. **All Audit Events**: Full audit search with no operation filter.
2. **Mailbox Access / Compromise Investigation**: Reads, message binds, and folder access (`MailItemsAccessed`, `MessageBind`, `FolderBind`).
3. **Email Sending & Impersonation**: Outbound email sending and delegation (`SendAs`, `SendOnBehalf`, `Send`).
4. **Deleted Items & Purges**: Deletions and trash purges (`SoftDelete`, `HardDelete`, `MoveToDeletedItems`).
5. **Admin & Permission Changes**: Mailbox permission grants/revocations (`Add-MailboxPermission`, `Add-RecipientPermission`, `Set-Mailbox`).
6. **Mailbox Configuration & Forwarding Rules**: Creation/updates to inbox forwarding rules (`New-InboxRule`, `Set-InboxRule`, `Set-Mailbox`).
7. **Sign-In & Authentication Events**: Modern sign-in and token events (`UserLoggedIn`, `UserLoginFailed`).
8. **Browse Full Operations Catalog**: Browse over 32+ categorized operations across 8 groups (Mailbox Access, Email Sending, Deletion, Admin & Permissions, Rules & Config, Authentication, Org Admin, eDiscovery) with friendly descriptions. Filter by keyword with `[F]` and select by number.
9. **Custom / Manual Filter**: Advanced mode supporting exact operation and record type queries.

##### Smart User Filtering
Filter audit logs by specific user or mailbox using `Resolve-MailboxIdentity`—enter partial names, aliases, or pick from multiple matches without needing the exact UPN.

##### Results Viewer & Export
- **Paginated Console Table**: Human-friendly event names displayed alongside timestamps and user IDs.
- **Deep JSON Inspector**: Drill down into any event index to view formatted extended payload metadata (`AuditData`).
- **CSV Export Engine**: Export results to CSV for compliance records, client reporting, or ticket attachments.
