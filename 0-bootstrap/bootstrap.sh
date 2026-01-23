#!/bin/sh

# 1. Prerequisite setup (S3/DynamoDB)
terraform -chdir=tf-prerequisites init
terraform -chdir=tf-prerequisites apply --auto-approve

# 2. Initialize and Manage Bootstrap
terraform -chdir=bootstrap init -backend-config=backend.conf

# Import guard to prevent "Resource already managed" errors
ORG_ID=$(aws organizations describe-organization | jq -r .Organization.Id)
if ! terraform -chdir=bootstrap state list | grep -q "aws_organizations_organization.org"; then
    echo "Importing Organization..."
    terraform -chdir=bootstrap import aws_organizations_organization.org "$ORG_ID"
fi

terraform -chdir=bootstrap apply --auto-approve
echo "Bootstrap layer applied successfully."

# 3. Account & Role Validation Check
# Extract the Account ID directly from the bootstrap output
CICD_ACC_ID=$(terraform -chdir=bootstrap output -json accounts_id_map | jq -r '.lz_ci_cd')

echo "Validating accessibility for Account ID: $CICD_ACC_ID..."

# Validation Loop: Try to assume the management role to confirm account is 'ready'
MAX_RETRIES=10
COUNT=0
while [ $COUNT -lt $MAX_RETRIES ]; do
    # Try assuming the role; redirect output to null as we only care about the exit code
    aws sts assume-role \
        --role-arn "arn:aws:iam::$CICD_ACC_ID:role/OrganizationAccountAccessRole" \
        --role-session-name "VerificationSession" \
        --query "Credentials.AccessKeyId" --output text > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo "SUCCESS: Account $CICD_ACC_ID is reachable."
        break
    else
        echo "WAITING: Role not yet assumable in $CICD_ACC_ID (Attempt $((COUNT+1))/$MAX_RETRIES)..."
        sleep 30
        COUNT=$((COUNT+1))
    fi

    if [ $COUNT -eq $MAX_RETRIES ]; then
        echo "ERROR: Timed out waiting for account access. The CI/CD stack will likely fail."
        exit 1
    fi
done

# 4. Initialize and Apply CICD Stack
terraform -chdir=cicd init -backend-config=backend.conf
terraform -chdir=cicd apply --auto-approve
echo "CICD stack applied successfully."