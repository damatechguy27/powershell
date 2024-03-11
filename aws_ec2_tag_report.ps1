#Script perform both a tag comparision and naming convention check 
#performs both tag comparision and naming convention checks

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

        # tag comparision check 
        $ec2_name_without_delimiters = $ec2_name -replace '\.',''

        $compare_names = if ($ec2_name_without_delimiters -eq $ec2_hostname){'True'}else{'False'}

        #naming convention Check
        # Split the EC2 name into its components
        $nameComponents = $ec2_name -split '\.'

        # Check 1: Location (LA1 or DC1)
        $locationCheck = $nameComponents[0] -in @("LA1", "DC1")

        # Check 2: Name (Length <= 20)
        $nameCheck = $nameComponents[1].Length -le 20

        # Check 3: Function (WEB, AWS, or EKS)
        $functionCheck = $nameComponents[2] -in @("WEB", "AWS", "EKS")

        # Check 4: Environment (PR, DE, or TE)
        # Extract environment (first two characters)
        $environment = $nameComponents[3].Substring(0, 2)
        $environmentCheck = $environment -match '^PR|DE|TE$'

        # Check 5: Sequence (01-99)
        # Extract sequence (remaining characters)
        $sequence = $nameComponents[3].Substring(2)
        $sequenceCheck = $sequence -match '^\d{2}$' -and $sequence -ge "01" -and $sequence -le "99"

        # Check if all checks passed
        $namingConventionPassed = $locationCheck -and $nameCheck -and $functionCheck -and $environmentCheck -and $sequenceCheck

        # Print the result
        #$namingConventionPassed

        # Add the result to the array
       # Add the result to the array
       $results += [PSCustomObject]@{
        'Profile' = $profile
        'Instance ID' = $instanceId
        'Name' = $ec2_name
        'Hostname' = $ec2_hostname
        'Comparision' = $compare_names
        'Naming Convention Audit' = $namingConventionPassed
    }
}
}

# Export the results to a CSV file
$results | Export-Csv -Path "EC2_tag_Report.csv" -NoTypeInformation
