using namespace System.Collections.Generic

function Get-GpgKey {
    <#
    .SYNOPSIS
        Get keys stored on a GPG keyring.
    .DESCRIPTION
        Get-Key prepares a command to pass to the GPG command line executable. The output from the command is parsed and presented as a PSObject.
    
        Filtering options are applied after all keys have been returned and processed.
    .INPUTS
        System.String
    .EXAMPLE
        Get-GpgKey "*dent*"
    #>

    [CmdletBinding()]
    [OutputType('GpgKey')]
    param (
        # Filters the return value to the specified Identity. Matches by Fingerprint, Owner or Email.
        [Parameter(ValueFromPipeline)]
        [String]$Identity = '*',
        
        # Gets private keys instead of public keys.
        [Switch]$Private,

        # 
        [Switch]$Signatures
    )

    process {
        $argumentList = [List[String]]('--fingerprint', '--with-colons')
        if ($Private) {
            $argumentList.Add('--list-secret-keys')
        } elseif ($Signatures) {
            $argumentList.Add('--list-sigs')
        } else {
            $argumentList.Add('--list-keys')
        }

        [GpgKey[]]((gpg $argumentList | Out-String) -split '(?=(pub|sec))' -match '^(pub|sec):')
    }
}