function Protect-GpgFile {
    <#
    .SYNOPSIS
        Protect a file by encrypting the content.
    .DESCRIPTION
        Protect file encrypts file content using public keys from the GPG keyring. The current users public key is included by default.
    .INPUTS
        System.String
    .EXAMPLE
        Protect-File C:\Temp\Test.txt -IncludeKeys "jane.doe@domain.example", "john.doe@domain.example"
    .EXAMPLE
        Protect-File C:\Temp\Test.txt -IncludeKeys "An AD Group", "Another AD Group"
    #>
  
    [CmdletBinding(DefaultParameterSetName = 'KeyList')]
    param (
        # The file containing the content to be encrypted. Wildcards are not permissible, however pipeline input from Get-ChildItem is supported.
        [Parameter(Position = 1, Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateScript( { Test-Path $_ -PathType Leaf } )]
        [Alias('FullName')]
        [String]$Path,

        # Specify additional public keys to include when encrypting the file (to let others decrypt the file). All keys must exist on the keyring.
        [Parameter(ParameterSetName = 'KeyList')]
        [String[]]$IncludeKeys,

        # Additional public keys may be selected using Active Directory group membership. Multiple group names may be defined.
        [Parameter(ParameterSetName = 'Group')]
        [String[]]$Group
    )
  
    process {
        if ($File -notmatch '^".+"$') {
            $File = '"{0}"' -f $Path
        } else {
            $File = $Path
        }

        if ($pscmdlet.ParameterSetName -eq "Group") {
            # Cache a parsed copy of the keyring in memory for a while
            $KeyCache = Get-Key

            $IncludeKeys = $Group | ForEach-Object {
                ([ADSISearcher]"(&(objectClass=group)(name=$_))").FindAll() | ForEach-Object {
                    $DN = $_.Properties["distinguishedname"][0]

                    ([ADSISearcher]"(&(objectClass=user)(objectCategory=person)(memberOf:1.2.840.113556.1.4.1941:=$DN))").FindAll() | ForEach-Object {
                        $User = $_

                        # Attempt to match the user to a valid key
                        if ($KeyCache | Where-Object { $_.Email -match $User.Properties["mail"][0] }) {
                            $User.Properties["mail"][0]
                        } elseif ($KeyCache | Where-Object { $_.Owner -match $User.Properties["name"][0] }) {
                            $User.Properties["name"][0]
                        } elseif ($KeyCache | Where-Object { $_.Owner -match $User.Properties["samaccountname"][0] }) {
                            $User.Properties["samaccountname"][0]
                        } elseif ($KeyCache | Where-Object { $_.Owner -match ($User.Properties["name"][0] -replace ' ') }) {
                            $User.Properties["name"][0] -replace ' '
                        } else {
                            $LooseMatch = Get-Key "$($User.Properties["name"][0]) (*)"
                            if (([Array]$LooseMatch).Count -eq 1) {
                                $LooseMatch.Email
                            }
                        }
                    }
                }
            }

            Write-Verbose "Protect-File: Retrieved keys from Active Directory:"
            $IncludeKeys | ForEach-Object { Write-Verbose $_ }
        }

        $argumentList = "--encrypt", "-a", "--recipient", (Get-GpgKey -Private).Email
        If ($IncludeKeys) {
            $IncludeKeys | ForEach-Object {
                $argumentList += "--recipient", """$_"""
            }
        }

        $argumentList += $File

        gpg $argumentList
    }
}