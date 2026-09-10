param(
    [string]$Version
)

$manifestPath = Resolve-Path "src\cascadia\CascadiaPackage\Package-Dev.appxmanifest"
[xml]$manifest = Get-Content $manifestPath

if ($Version) {
    if ($Version -notmatch '^\d+\.\d+\.\d+\.\d+$') {
        throw "Version must use A.B.C.D"
    }
    $manifest.Package.Identity.Version = $Version
}

# Windows 11 only permits -AllowUnsigned registration when this marker is the
# final field of Publisher. It also keeps the unsigned identity separate from
# any future certificate-signed HookDock Terminal package.
$manifest.Package.Identity.Publisher =
    "CN=HookDock, OID.2.25.311729368913984317654407730594956997722=1"
$manifest.Save($manifestPath)

Write-Host "Prepared unsigned HookDock Terminal package identity$(
    if ($Version) { " version $Version" } else { "" }
)"
