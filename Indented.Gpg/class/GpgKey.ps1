class GpgKey {
    [String]$KeyType

    [String]$Fingerprint

    [Validity]$Validity

    [String]$UserID

    [PublicKeyAlgorithm]$PublicKeyAlgorithm

    [Int32]$KeyLength

    [String]$KeyID

    [DateTime]$CreationDate

    [DateTime]$ExpirationDate

    [String]$SignatureClass

    [Capability]$Capability

    # [GpgSignature[]]$Signature

    GpgKey([String]$Record) {
        $header = 'Type',
                  'Validity',
                  'KeyLength',
                  'PublicKeyAlgorithm',
                  'KeyID',
                  'CreationDate',
                  'ExpirationDate',
                  'Info', 
                  'OwnerTrust',
                  'UserID',
                  'SignatureClass',
                  'Capability',
                  'Issuer',
                  'Flag',
                  'SerialNumber',
                  'HashAlgorithm',
                  'CurveName',
                  'ComplianceFlags',
                  'LastUpdate',
                  'Origin',
                  'Comment'

        foreach ($entry in $Record | ConvertFrom-Csv -Delimiter ':' -Header $header) {
            switch ($entry.Type) {
                'pub' {
                    $this.KeyType = 'Public'
                    $this.Validity = [Int][Char]$entry.Validity
                    $this.KeyLength = $entry.KeyLength
                    $this.PublicKeyAlgorithm = [Int]$entry.PublicKeyAlgorithm
                    $this.KeyID = $entry.KeyID
                    $this.CreationDate = (Get-Date 01/01/1970).AddSeconds($entry.CreationDate)
                    $this.Capability = [Int[]]$entry.Capability.ToCharArray()
                }
                'sec' {
                    $this.KeyType = 'Secret'
                    $this.KeyLength = $entry.KeyLength
                    $this.PublicKeyAlgorithm = [Int]$entry.PublicKeyAlgorithm
                    $this.KeyID = $entry.KeyID
                    $this.CreationDate = (Get-Date 01/01/1970).AddSeconds($entry.CreationDate)
                }
                'fpr' {
                    $this.Fingerprint = $entry.UserID
                }
                'uid' {
                    $this.UserID = $entry.UserID
                }
                'sig' {

                }
            }
        }
# '
# sig:::1:0343247A2A226502:1525776510::::Chris Dent <chris.dent@itv.com>:13x:::::8:
# sub:u:2048:1:5252DFA81413E695:1525776510::::::e:
# sig:::1:0343247A2A226502:1525776510::::Chris Dent <chris.dent@itv.com>:18x:::::8:'
    }
}