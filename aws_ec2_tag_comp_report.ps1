#Script compare 2 tags on an ec2 and check to see if the tags match
$profiles = 'default'

# Initialize an empty array to store results
$results = @()

# Loop through each AWS profile
foreach ($profile in $profiles) {
    # Set the AWS profile
    Set-AWSCredential -ProfileName $profiles

    # Get EC2 instances in the current account
    $instances = Get-EC2Instance

    # Loop through each EC2 instance
    foreach ($instance in $instances.Instances) {
        # Get instance ID
        $instanceId = $instance.InstanceId

        $ec2_name = if(![string]::IsNullOrEmpty(($instance.Tags | Where Key -eq 'Name' | Select Value))){($instance.Tags | Where-Object {$_.Key -eq 'Name'}).Value} else {"missing"}

        $ec2_hostname = if(![string]::IsNullOrEmpty(($instance.Tags | Where Key -eq 'Hostname' | Select Value))){($instance.Tags | Where-Object {$_.Key -eq 'Hostname'}).Value} else {"missing"}


        $ec2_name_without_delimiters = $ec2_name -replace '\.',''

        $compare_names = if ($ec2_name_without_delimiters -eq $ec2_hostname){'True'}else{'False'}
        

        # Add the result to the array
        $results += [PSCustomObject]@{
            'Profile' = $profile
            'Instance ID' = $instanceId
            'Name' = $ec2_name
            'Hostname' = $ec2_hostname
            'Comparision' = $compare_names
        }
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path "EC2_tag_comp_Report.csv" -NoTypeInformation
