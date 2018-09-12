using namespace System.Runtime.InteropServices

function Set-GpgKeySignature {
    <#
    .SYNOPSIS
        Set-GpgKeySignature is used to add a signature to a public key.
    .DESCRIPTION
        Add a signature from a private key to a public key on the keyring.
    .INPUTS
        System.String
    .EXAMPLE
        Get-GpgKey "John Doe" | Set-GpgKeySignature
    #>
       
    [CmdletBinding()]
    param (
        # Identity is a value which can be used to uniquely identify the key. Both Owner and Fingerprint are acceptable as these tend to be unique.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Fingerprint', 'Owner')]
        [String]$Identity
    )
    
    process {
        if ($Script:sessionKey -is [Security.SecureString]) {
            $passphrase = [Marshal]::PtrToStringAuto(
                [Marshal]::SecureStringToBSTR($Script:sessionKey)
            )
        }

        if ($passphrase) {
            $passphrase | gpg "--passphrase-fd", 0, "--batch", "--yes", "--sign-key", $Identity
        } else {
            gpg "--sign-key", $Identity
        }
    }
}