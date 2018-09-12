[Flags()]
enum Capability {
    Unknown                  = 63
    PrimaryKeyAuthentication = 65
    PrimaryKeyCertify        = 67
    Disabled                 = 68
    PrimaryKeyEncrypt        = 69
    PrimaryKeySign           = 83
    Authentication           = 97
    Certify                  = 99
    Encrypt                  = 101
    Sign                     = 115
}