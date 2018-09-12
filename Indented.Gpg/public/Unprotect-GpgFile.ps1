using namespace System.Runtime.InteropServices

function Unprotect-GpgFile {
    <#
    .SYNOPSIS
        Unprotects, or decrypts, the specified file.
    .DESCRIPTION
        Unprotect-File attempts to decrypt the specified file using the current private key.
    .INPUTS
        System.String
    .EXAMPLE
        Unprotect-GpgFile C:\temp\somefile.txt.asc
    .EXAMPLE
        Get-ChildItem | Unprotect-GpgFile -ToFile
    .EXAMPLE
        Unprotect-GpgFile c:\temp\somefile.csv.asc -AsCsv | Format-Table
    #>
  
    [CmdletBinding(DefaultParameterSetName = "CSV")]
    param (
        # The file containing the content to be decrypted. Wildcards are not permissible, however pipeline input from Get-ChildItem is supported.
        [Parameter(Position = 1, Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateScript( { Test-Path $_ -PathType Leaf } )]
        [Alias("FullName")]
        [String]$Path,
        
        # Converts output from CSV format when displaying to output to the console.
        [Parameter(ParameterSetName = "CSV")]
        [Switch]$AsCsv,
        
        # By default, Decrypt-File outputs to the console. ToFile forces the CmdLet to write the decrypted content to an ASCII formatted file. The file name will be preserved, the extension denoting encryption type will be removed.
        [Parameter(ParameterSetName = "FILE")]
        [Switch]$ToFile
    )
    
    process {
        if ($Script:sessionKey -is [Security.SecureString]) {
            $Passphrase = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Script:sessionKey))
        }

        if ($Passphrase) {
            $Content = $Passphrase | gpg "--decrypt", "--passphrase-fd", 0, $Path
        } else {
            $Content = gpg "--decrypt", $Path
        }
        
        if ($Content) {
            if ($ToFile) {
                $Content | Out-File $($Path -replace '\.(asc)|(gpg)') -Encoding ASCII
            } elseif ($AsCSV) {
                $Content | ConvertFrom-Csv
            } else {
                $Content
            }
        }
    }
}