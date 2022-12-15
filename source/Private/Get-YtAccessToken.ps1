function Get-YtAccessToken {
    [CmdletBinding()]
    param (
        $AccessTokenPath = "$env:USERPROFILE\.creds\YouTube\YoutubeAccessToken.xml"
    )

    process {
        if (!(Test-Path -Path $AccessTokenPath)) {
            New-YtAccessToken
        }
    
        $TimeTillTokenExpiry = (Import-Clixml -Path $AccessTokenPath).expiry_date - (Get-Date)
        
        #Check if there's less than 5 minutes till the current access token expires
        if (($TimeTillTokenExpiry.Minutes) -lt 5) {
            New-YtAccessToken
        }

        (Import-Clixml -Path $AccessTokenPath).access_token | ConvertFrom-SecureString -AsPlainText
    }
}