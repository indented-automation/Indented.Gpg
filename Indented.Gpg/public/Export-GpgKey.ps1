function Export-GpgKey {
    <#
    .SYNOPSIS
        Exports a key to an ASCII Armour file.
    .DESCRIPTION
        Export-GpgKey attempts to export keys to a file named after the key identity. For example, a key with with Identity set to "Chris Dent" will be named ChrisDent.asc.
    .INPUTS
        System.String
    .EXAMPLE
        Get-GpgKey name | Export-GpgKey
    #>
  
    [CmdletBinding()]
    param (
        # Identity is a value which can be used to uniquely identify the key. Both Owner and Fingerprint are acceptable as these tend to be unique.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Owner', 'Fingerprint')]
        [String]$Identity,

        # Export the key to the specified file or folder. If an existing folder is specified a file will be created named after the key identity.
        [ValidateScript( { Test-Path $_ -PathType Container } )]
        [String]$Path,
        
        # Export a private key instead of public keys.
        [Switch]$Private
    )

    begin {
        if ($Path) {
            $Path = $pscmdlet.GetUnresolvedProviderPathFromPSPath($Path)
        }
    }
    
    process {
        $argumentList = @(
            ('--export', '--export-secret-key')[$Private.ToBool()]
            '-a'
            $Identity
        )
        $asciiArmour = gpg $argumentList
        
        if ($Path) {
            if (Test-Path $Path -PathType Container) {
                $outputPath = Join-Path $Path $Identity
            } else {
                $outputPath = $Path
            }

            Set-Content -Path $outputPath -Value $asciiArmour -Encoding ASCII
        } else {
            $asciiArmour
        }
    }
}