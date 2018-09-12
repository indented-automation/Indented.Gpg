function Remove-GpgKey {
    <#
    .SYNOPSIS
        Remove a key from the GPG keyring.
    .DESCRIPTION
        Remove-GpgKey attempts to delete public keys from the keyring.
    
        Remove-GpgKey accepts pipeline input from Get-GpgKey.
    .INPUTS
        System.String
    .EXAMPLE
        Get-GpgKey "*dent*" | Remove-GpgKey
    #>
  
    [CmdletBinding()]
    param (
        # Identity is a value which can be used to uniquely identify the key. Both Owner and Fingerprint are acceptable as these tend to be unique.
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("Name", "Fingerprint")]
        [String]$Identity,
        
        # Key removal will prompt for confirmation. This behaviour may be changed using the Force parameter.
        [Switch]$Force
    )
    
    process {
        if ($Force) {
            gpg '--batch', '--yes', '--delete-keys', $Identity
        } else {
            gpg '--delete-keys', $Identity
        }
    }
  }