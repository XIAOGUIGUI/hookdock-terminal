# HookDock Terminal integration

HookDock Terminal is a companion build of Windows Terminal Stable. It can be
installed alongside Microsoft's Stable package and exists for one narrow API
that Windows Terminal does not expose: focusing an existing pane by its stable
`WT_SESSION` identifier.

## Runtime contract

Every ConPTY child receives these variables:

```text
WT_SESSION=<guid>
HOOKDOCK_TERMINAL=1
HOOKDOCK_TERMINAL_PROTOCOL=1
```

The HookDock Codex bridge only records a terminal target when all three values
are present and the GUID is valid. This prevents an ordinary Windows Terminal
session from advertising an activation feature it does not implement.

HookDock activates a target without a shell:

```powershell
hookdock-terminal.exe --focus-session 7f6b3978-25f1-4519-8b02-8fe67f35991f
```

The command searches the live pane trees of every HookDock Terminal window.
When it finds the connection's session ID, it selects that tab, focuses that
pane, and summons its window. Tab indexes are never persisted. A stale or
unknown ID is a no-op and never creates a new tab or focuses a fallback pane.

## Package identity and updates

The companion uses the development-branding build path with its own package
identity (`HookDock.Terminal`) and execution alias (`hookdock-terminal.exe`).
Release builds must continue to pass `WindowsTerminalBranding=Dev`; building
with `Release` would select Microsoft's package manifest and alias.

`packaging/HookDockTerminal.appinstaller.in` enables daily App Installer update
checks. Release signing uses a certificate whose subject is exactly
`CN=HookDock`. Configure these repository secrets before publishing:

- `HOOKDOCK_TERMINAL_CERTIFICATE_BASE64`: base64-encoded PFX
- `HOOKDOCK_TERMINAL_CERTIFICATE_PASSWORD`: PFX password

The tag format is `hookdock-vA.B.C.D`, where `A.B.C.D` is also written into the
MSIX and App Installer manifests.

## Following upstream Stable

`.hookdock/upstream.json` records the reviewed Microsoft Stable tag and commit.
The weekly `upstream-stable.yml` workflow asks GitHub for Microsoft's latest
release, merges that release tag on an automation branch, updates the metadata,
and opens a pull request. It never publishes automatically.

If the small HookDock patch surface conflicts, the workflow aborts the merge
and opens an issue. Resolve the conflict on an update branch, run the Windows
build workflow, and merge only after these invariants are checked:

1. the environment markers still reach Windows and WSL children;
2. `--focus-session` never creates a tab or window;
3. matching still uses `ITerminalConnection.SessionId`, not a tab index;
4. the Dev package identity and execution alias remain independent;
5. HookDock notification activation still launches the exact alias and GUID.

Keep product features out of this fork. A narrow patch makes Stable upgrades
reviewable and allows the companion to be retired if upstream adds an equivalent
public activation API.
