# Import the AWS module
Import-Module AWSPowerShell

# Get the list of AWS profiles from the credentials file
$awsProfiles = Get-AWSCredential -ListProfile

# Initialize an empty array to store results
$results = @()

# Loop through each AWS profile
foreach ($awsProfile in $awsProfiles) {
    # Get the profile name
    $profileName = $awsProfile.ProfileName

    # Get the AWS credentials for the current profile
    $credentials = Get-AWSCredential -ProfileName $profileName

    # Set the AWS credentials
    Set-AWSCredential -AccessKey $credentials.AccessKey -SecretKey $credentials.SecretKey -StoreAs $profileName

    # Get S3 buckets in the current account
    $s3Buckets = Get-S3Bucket -ProfileName $profileName

    # Loop through each S3 bucket
    foreach ($bucket in $s3Buckets) {
        # Get tags for the bucket
        $tags = Get-S3BucketTag -BucketName $bucket.BucketName -ProfileName $profileName -ErrorAction SilentlyContinue

        # Add the result to the array
        $results += [PSCustomObject]@{
            'Profile name' = $profileName
            'S3 bucket name' = $bucket.BucketName
            'Creation Date' = $bucket.CreationDate
            'Owner' = $bucket.Owner.DisplayName
            'Tags' = ($tags | Select-Object -ExpandProperty Tag) -join ', '
        }
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path "S3_Buckets_Tags.csv" -NoTypeInformation

# Remove the AWS module from the session
Remove-Module AWSPowerShell
