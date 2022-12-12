function New-YtAccessToken {
    [CmdletBinding()]
    param (
        $ClientIdPath = "$env:USERPROFILE\.creds\YouTube\YoutubeClientId.xml",
        $ClientSecretPath = "$env:USERPROFILE\.creds\YouTube\YoutubeClientSecret.xml",
        $RefreshTokenPath = "$env:USERPROFILE\.creds\YouTube\YoutubeRefreshToken.xml",
        $AccessTokenPath = "$env:USERPROFILE\.creds\YouTube\YoutubeAccessToken.xml"
    )

    process {
        #Create folder to store credentials
        $AccessTokenDir = $AccessTokenPath.Substring(0, $AccessTokenPath.lastIndexOf('\'))
        if (!(Test-Path $AccessTokenDir)) {
            $null = New-Item -ItemType Directory $AccessTokenDir
        }

        #Create ClientId file
        if (!(Test-Path $ClientIdPath)) {
            Read-Host "Enter YouTube ClientId" | ConvertTo-SecureString -AsPlainText | Export-Clixml $ClientIdPath
        }

        #Create ClientSecret file
        if (!(Test-Path $ClientSecretPath)) {
            Read-Host "Enter YouTube ClientSecret" | ConvertTo-SecureString -AsPlainText | Export-Clixml $ClientSecretPath
        }

        #Create RefreshToken file
        if (!(Test-Path $RefreshTokenPath)) {
            Read-Host "Enter YouTube RefreshToken" | ConvertTo-SecureString -AsPlainText | Export-Clixml $RefreshTokenPath
        }

        #Request new accesstoken
        $splat = @{
            "Method" = "POST"
            "Uri" = "https://www.googleapis.com/oauth2/v4/token"
            "Body" = @{
                "client_id" = Import-Clixml $ClientIdPath | ConvertFrom-SecureString -AsPlainText
                "client_secret" = Import-Clixml $ClientSecretPath | ConvertFrom-SecureString -AsPlainText
                "refresh_token" = Import-Clixml $RefreshTokenPath | ConvertFrom-SecureString -AsPlainText
                "grant_type" = "refresh_token"
            }
        }
        $result = Invoke-RestMethod @splat

        #Set up output
        @{
            "access_token" = $result.access_token | ConvertTo-SecureString -AsPlainText
            "expiry_date" = (Get-Date).AddSeconds($result.expires_in)
        } | Export-Clixml -Path $AccessTokenPath
    }
}