$profiles = 'default'

# Initialize an empty array to store results
$results = @()

# Loop through each AWS profile
foreach ($profile in $profiles) {
    # Set the AWS profile
    Set-AWSCredential -ProfileName $profiles

    Set-DefaultAWSRegion -Region 'us-east-1'

    # Get EC2 instances in the current account
    $s3 = Get-S3Bucket
    

    # Loop through each EC2 instance
    foreach ($s3Buckets in $s3) {
        # Get instance ID
        $lc_policy_config = Get-S3LifecycleConfiguration -BucketName $s3Buckets.BucketName -ErrorAction SilentlyContinue
        # Get 'data priority' tag
        $AppTag = (Get-S3BucketTagging -BucketName $s3Buckets.BucketName | Where-Object { $_.Key -eq 'Application' }).Value

        # Get encryption status
        $encryptionStatus = (Get-S3BucketEncryption -BucketName $s3Buckets.BucketName).ServerSideEncryptionConfiguration.Rules.Count -gt 0
  
        

        if ($lc_policy_config.Rules.Count -gt 1 ){$lc_policy_status="Enabled"} else {$lc_policy_status="Disabled"}
        #$lc_policy_status
        # Get instance status
        #$instanceStatus = $instanceHealth.InstanceState.Name
        #$s3Buckets.BucketName       

        # Add the result to the array
        $results += [PSCustomObject]@{
            'Profile' = $profile
            'Bucket Name' = $s3Buckets.BucketName
            'LifeCyclePolicy Status' = $lc_policy_status
            'App' = $AppTag
            'Encryption' = $encryptionStatus
       }
    }
}

#$instanceHealth.InstanceState.Name 

# Export the results to a CSV file
$results | Export-Csv -Path "S3_Lifecycle_policy_report.csv" -NoTypeInformation
    
