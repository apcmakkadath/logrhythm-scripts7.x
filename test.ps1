function Upload-FileToGitHub {
    param(
        [string]$Owner,
        [string]$Repo,
        [string]$FilePath,
        [string]$Branch,
        [string]$Token
    )

    # Read the file content
    $Content = [System.IO.File]::ReadAllBytes($FilePath)
    
    # Encode the file content as Base64
    $ContentEncoded = [System.Convert]::ToBase64String($Content)
    
    # Construct the API URL
    $Url = "https://api.github.com/repos/$Owner/$Repo/contents/$(Split-Path -Leaf $FilePath)"
    
    # Construct the request headers
    $Headers = @{
        "Authorization" = "Bearer $Token"
        "Accept" = "application/vnd.github.v3+json"
    }
    
    # Construct the request payload
    $Payload = @{
        "message" = "Upload file"
        "content" = $ContentEncoded
        "branch" = $Branch
    } | ConvertTo-Json
    
    try {
        # Send the PUT request
        $Response = Invoke-RestMethod -Uri $Url -Headers $Headers -Method Put -Body $Payload
        
        # Check the response status
        if ($Response.StatusCode -eq 201) {
            Write-Host "File uploaded successfully!"
        } else {
            Write-Host "Failed to upload file. Error:" $Response
        }
    } catch {
        Write-Host "An error occurred: $_"
    }
}


# Example usage
$Owner = "apcmakkadath"
$Repo = "logrhythm-scripts7.x"
$FilePath = "C:\Users\apc\Documents\desk\scripts\test.ps1"
$Branch = "main"  # Replace with the branch name you want to upload to
$Token = "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"

Upload-FileToGitHub -Owner $Owner -Repo $Repo -FilePath $FilePath -Branch $Branch -Token $Token
