# Initialize an empty array to store results
$results = @()

# Get the list of S3 buckets
$s3Buckets = aws s3api list-buckets --query "Buckets[].Name" --output text

# Loop through each bucket
foreach ($bucket in $s3Buckets) {
    # Get the bucket details
    $bucketDetails = aws s3api get-bucket-location --bucket $bucket | ConvertFrom-Json

    # Get the bucket tags
    $bucketTags = aws s3api get-bucket-tagging --bucket $bucket | ConvertFrom-Json

    # Extract tag key-value pairs
    $tags = $bucketTags.TagSet | ForEach-Object {
        "$($_.Key):$($_.Value)"
    }

    # Add the result to the array
    $results += [PSCustomObject]@{
        'S3 bucket name' = $bucket
        'Location' = $bucketDetails.LocationConstraint
        'Tags' = $tags -join ', '
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path "S3_Buckets_Specs_Tags.csv" -NoTypeInformation
