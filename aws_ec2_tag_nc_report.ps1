# Script checks the ec2 name tag and check to see if it matches a naming convention sequence
$profiles = 'default'

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

        # Example EC2 name
        $ec2Name = if(![string]::IsNullOrEmpty(($instance.Tags | Where Key -eq 'Name' | Select Value))){($instance.Tags | Where-Object {$_.Key -eq 'Name'}).Value} else {"missing"}

        # Split the EC2 name into its components
        $nameComponents = $ec2Name -split '\.'

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
        $namingConventionPassed
    }
}
