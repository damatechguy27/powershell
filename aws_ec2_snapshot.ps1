# Import the AWS PowerShell module
#Get-Module -Name AWSPowerShell
#Import-Module AWSPowerShell

# Get the list of AWS profiles from the credentials file
#$awsProfiles = Get-AWSCredential -ListProfileDetail | Select-Object -ExpandProperty ProfileName
$profiles = 'default'

# Initialize an empty array to store results
$results = @()

# Loop through each AWS profile
foreach ($profile in $profiles) {
    # Set the AWS profile
    Set-AWSCredential -ProfileName $profiles

    # Get EC2 instances in the current account
    $snapshots = Get-EC2Snapshot -Owner self -Region "us-west-2"

    # Loop through each EC2 instance
    foreach ($snaps in $snapshots) {
        $snapshotDate = $snaps.StartTime
        
        # Calculate the number of days since the snapshot was created
        $daysSinceCreation = (Get-Date) - $snapshotDate
        $daysSinceCreation = $daysSinceCreation.Days
        
        if ($daysSinceCreation -gt 30)
        {
            # Get snapshot details
            $snapshotId = $snaps.SnapshotId
            $snapshotName = $snaps.Tags | Where-Object { $_.Key -eq "Name" } | Select-Object -ExpandProperty Value
            
            #$snapshotAge = $snaps.Days
            $snapshotSize = $snaps.VolumeSize

            
            $encryption = $snaps.Encrypted
            # Get instance status
            #$instanceStatus = $instanceHealth.InstanceState.Name
            

            # Add the result to the array
            $results += [PSCustomObject]@{
                'Profile' = $profile
                'Snapshot ID' = $snapshotId
                'Snapshot Name' = $snapshotName
                'Date Created' = $snapshotDate
                'Snapshot Age' = $daysSinceCreation
                'Snapshot Size(GB)'=$snapshotSize
                'Encrypted' = $encryption
                #'Instance Status' = $instanceStatus
            }
        }
    }
}

#$instanceHealth.InstanceState.Name 

# Export the results to a CSV file
$results | Export-Csv -Path "EC2_Snapshot_Report.csv" -NoTypeInformation
    
