function Set-GpgSessionKey {
    <#
    .SYNOPSIS
        Set and store a passphrase for a key.
    .DESCRIPTION
        Set-SessionKey populates a script-level variable with an encrypted form of the passphrase. The value is only accessible by the module (not the session).

        Later versions of GPG do not require this, an agent process is spawned (by GPG) to acquire a passphrase.
    .EXAMPLE
        Set-SessionKey
    #>
    
    [CmdletBinding()]
    param( )
  
    $Script:sessionKey = Read-Host -Prompt "Please enter your passphrase" -AsSecureString
  }
  