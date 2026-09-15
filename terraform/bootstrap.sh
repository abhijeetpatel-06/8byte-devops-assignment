#!/usr/bin/env bash
# Run this ONCE before `terraform init`, from your local machine (needs
# aws cli configured with an admin-ish profile). Creates the S3 bucket +
# dynamodb table that the backend{} block in backend.tf points to.
#
# After this you never need to touch this script again - terraform
# manages everything else.

set -e

REGION="ap-south-1"
BUCKET="8byte-terraform-state-432500708653"
TABLE="myapp-terraform-locks"

echo "Creating state bucket: $BUCKET in $REGION ..."
aws s3api create-bucket \
  --bucket "$BUCKET" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION"

aws s3api put-bucket-versioning \
  --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket "$BUCKET" \
  --server-side-encryption-configuration '{
    "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]
  }'

echo "Creating lock table: $TABLE ..."
aws dynamodb create-table \
  --table-name "$TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION"

echo "Bootstrap done. Now run: terraform init"
