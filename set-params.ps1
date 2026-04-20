$REGION = "ap-southeast-2"

Push-Location terraform/environments/dev
$RDS_ENDPOINT   = terraform output -raw rds_endpoint
$REDIS_ENDPOINT = terraform output -raw redis_endpoint
$S3_BUCKET      = terraform output -raw s3_bucket_name
Pop-Location

$params = @{
    "DB_SECRET_NAME"   = "awstodo/dev/db/credentials"
    "DB_NAME"          = "postgres"
    "REDIS_HOST"       = $REDIS_ENDPOINT
    "JWT_ACCESS_SECRET"  = "mY9xK2pQ7rL4nV8wZ3jH6cB1sT5uE0fA"
    "JWT_REFRESH_SECRET" = "aX4kN7mW2vY9bR5gQ8eJ1hD6uC3oP0iL"
    "ACCESS_EXPIRE"    = "15m"
    "REFRESH_EXPIRE"   = "7d"
    "AWS_REGION"       = $REGION
    "AWS_S3_BUCKET"    = $S3_BUCKET
}

foreach ($key in $params.Keys) {
    Write-Host "Setting /todoapp/$key ..."
    aws ssm put-parameter `
        --name "/todoapp/$key" `
        --value $params[$key] `
        --type SecureString `
        --region $REGION `
        --overwrite
}

Write-Host "Done."
