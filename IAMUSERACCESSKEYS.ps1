# Import the AWS module
Import-Module AWSPowerShell

# Get the list of AWS profiles from the credentials file
$awsProfiles = Get-AWSCredential -ListProfileDetail | Select-Object -ExpandProperty ProfileName

# Initialize an empty array to store results
$results = @()

# Loop through each AWS profile
foreach ($awsProfile in $awsProfiles) {
    # Set the AWS profile
    Set-AWSCredential -ProfileName $awsProfile

    # Get all IAM users
    $users = Get-IAMUser

    # Loop through each IAM user
    foreach ($user in $users) {
        # Get the access keys for the user
        $accessKeys = Get-IAMAccessKey -UserName $user.UserName

        # Loop through each access key
        foreach ($accessKey in $accessKeys) {
            # Get the last used information for the access key
            $lastUsed = Get-IAMAccessKeyLastUsed -AccessKeyId $accessKey.AccessKeyId

            # Add the result to the array
            $results += [PSCustomObject]@{
                'Profile name' = $awsProfile
                'Username' = $user.UserName
                'AccessKeyId' = $accessKey.AccessKeyId
                'LastUsedDate' = $lastUsed.LastUsedDate
            }
        }
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path "IAM_User_AccessKeys_LastUsed.csv" -NoTypeInformation
