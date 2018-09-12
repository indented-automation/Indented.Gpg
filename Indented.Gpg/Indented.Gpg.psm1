# Development time root module
foreach ($name in 'enum', 'private', 'public') {
    Get-ChildItem (Join-Path $psscriptroot $name) -Filter *.ps1 -File -Recurse | ForEach-Object {
        . $_.FullName
    }
}

. "$psscriptroot\class\GpgSignature.ps1"
. "$psscriptroot\class\GpgKey.ps1"