# ============================================================================
# AWS Aliases
# ============================================================================

# AWS CLI shortcuts
alias aws='aws'
alias awsl='aws --profile'
alias awsr='aws --region'

# EC2
alias ec2ls='aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,Tags[?Key==\`Name\`].Value|[0]]" --output table'
alias ec2start='aws ec2 start-instances --instance-ids'
alias ec2stop='aws ec2 stop-instances --instance-ids'

# S3
alias s3ls='aws s3 ls'
alias s3sync='aws s3 sync'
alias s3cp='aws s3 cp'
alias s3rm='aws s3 rm'

# Lambda
alias lambdals='aws lambda list-functions --query "Functions[*].[FunctionName,Runtime,LastModified]" --output table'
alias lambdainvoke='aws lambda invoke'

# CloudFormation
alias cfls='aws cloudformation list-stacks --query "StackSummaries[?StackStatus!=\`DELETE_COMPLETE\`].[StackName,StackStatus]" --output table'
alias cfdesc='aws cloudformation describe-stacks --stack-name'

# ECS
alias ecsls='aws ecs list-clusters'
alias ecstasks='aws ecs list-tasks --cluster'

# RDS
alias rdsls='aws rds describe-db-instances --query "DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Engine]" --output table'

# ============================================================================
# AWS Functions
# ============================================================================

# Quick credential update from clipboard
function awsup() {
    local clipboard_content
    if command -v pbpaste >/dev/null 2>&1; then
        clipboard_content=$(pbpaste)
    else
        echo "❌ pbpaste not found"
        return 1
    fi
    
    local profiles=$(echo "$clipboard_content" | grep "^\[.*\]" | sed 's/^\[\(.*\)\]$/\1/')
    
    if [[ -z "$profiles" ]]; then
        echo "❌ No AWS profiles found in clipboard"
        return 1
    fi
    
    echo "Found profiles:"
    echo "$profiles" | nl
    echo
    
    read "choice?Select profile number: "
    
    local selected_profile=$(echo "$profiles" | sed -n "${choice}p")
    
    if [[ -z "$selected_profile" ]]; then
        echo "❌ Invalid selection"
        return 1
    fi
    
    local profile_section=$(echo "$clipboard_content" | grep -A 20 "\[${selected_profile}\]" | head -20)
    local credentials_file="$HOME/.aws/credentials"
    
    mkdir -p "$(dirname "$credentials_file")"
    touch "$credentials_file"
    
    if grep -q "^\[${selected_profile}\]" "$credentials_file"; then
        awk -v profile="$selected_profile" '
        /^\[/ { in_target = ($0 == "[" profile "]") }
        !in_target || /^\[/ && !($0 == "[" profile "]") { print }
        ' "$credentials_file" > "${credentials_file}.tmp" && mv "${credentials_file}.tmp" "$credentials_file"
    fi
    
    echo "$profile_section" >> "$credentials_file"
    
    export AWS_PROFILE="$selected_profile"
    echo "✅ AWS credentials updated: $selected_profile"
}

# Switch AWS profile
function awsp() {
    if [[ -z "$1" ]]; then
        echo "Available profiles:"
        grep "^\[.*\]" "$HOME/.aws/credentials" 2>/dev/null | sed 's/^\[\(.*\)\]$/  \1/' || echo "  No profiles found"
        return 0
    fi
    
    export AWS_PROFILE="$1"
    echo "✅ Switched to: $1"
}

# Show current AWS identity
function awswho() {
    echo "Profile: ${AWS_PROFILE:-default}"
    aws sts get-caller-identity 2>/dev/null || echo "❌ Not authenticated"
}

# List AWS profiles
function awsls() {
    grep "^\[.*\]" "$HOME/.aws/credentials" 2>/dev/null | sed 's/^\[\(.*\)\]$/  \1/'
}

# Set AWS region
function awsregion() {
    if [[ -z "$1" ]]; then
        echo "Current region: ${AWS_DEFAULT_REGION:-not set}"
        return 0
    fi
    export AWS_DEFAULT_REGION="$1"
    echo "✅ Set region to: $1"
}

# SSM Parameter Store
function ssmget() {
    aws ssm get-parameter --name "$1" --with-decryption --query 'Parameter.Value' --output text
}

function ssmput() {
    local name="$1"
    local value="$2"
    if [[ -z "$name" ]] || [[ -z "$value" ]]; then
        echo "Usage: ssmput <name> <value>"
        return 1
    fi
    aws ssm put-parameter --name "$name" --value "$value" --type SecureString --overwrite
}

# Secrets Manager
function secretget() {
    aws secretsmanager get-secret-value --secret-id "$1" --query 'SecretString' --output text
}

# CloudWatch Logs
function cwlogs() {
    local group="$1"
    if [[ -z "$group" ]]; then
        echo "Available log groups:"
        aws logs describe-log-groups --query 'logGroups[*].logGroupName' --output table
        return 1
    fi
    aws logs tail "$group" --follow
}

# S3 bucket size
function s3size() {
    local bucket="$1"
    if [[ -z "$bucket" ]]; then
        echo "Usage: s3size <bucket-name>"
        return 1
    fi
    aws s3 ls s3://"$bucket" --recursive --summarize | grep "Total Size"
}

# List all resources in region
function awsresources() {
    echo "EC2 Instances:"
    aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name]' --output table
    echo "\nS3 Buckets:"
    aws s3 ls
    echo "\nLambda Functions:"
    aws lambda list-functions --query 'Functions[*].FunctionName' --output table
}
