function Import-GpgKey {
    <#
    .SYNOPSIS
      Import a public key into to the keyring from a file.
    .DESCRIPTION
      Import-Key allows the addition of keys from a file. Import-Key accepts pipeline input from Get-ChildItem.
    .PARAMETER Path
    .INPUTS
        System.String
    .EXAMPLE 
        Get-ChildItem C:\Keys\*.asc | Import-Key
    #>
  
    [CmdletBinding()]
    param (
        # The file containing the key to be imported. Wildcards are not permissible, however pipeline input from Get-ChildItem is supported.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [ValidateScript( { Test-Path $_ -PathType Leaf } )]
        [String]$Path
    )
  
    process {
        gpg "--import", $Path
    }
}