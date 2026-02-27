# ============================================================================
# Terraform Aliases
# ============================================================================

# Core commands
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfv='terraform validate'
alias tff='terraform fmt'
alias tfo='terraform output'
alias tfs='terraform show'
alias tfr='terraform refresh'

# Workspace
alias tfw='terraform workspace'
alias tfwl='terraform workspace list'
alias tfws='terraform workspace select'
alias tfwn='terraform workspace new'

# State
alias tfst='terraform state'
alias tfstl='terraform state list'
alias tfsts='terraform state show'
alias tfstmv='terraform state mv'
alias tfstrm='terraform state rm'

# Import
alias tfim='terraform import'

# Taint
alias tft='terraform taint'
alias tfut='terraform untaint'

# Graph
alias tfg='terraform graph'

# ============================================================================
# Terraform Functions
# ============================================================================

# Init and plan
function tfip() {
    terraform init && terraform plan
}

# Init, plan, and apply
function tfipa() {
    terraform init && terraform plan && terraform apply
}

# Plan with auto-approve
function tfpa() {
    terraform plan && terraform apply -auto-approve
}

# Apply with auto-approve
function tfaa() {
    terraform apply -auto-approve
}

# Destroy with auto-approve
function tfda() {
    terraform destroy -auto-approve
}

# Format all files
function tffmt() {
    terraform fmt -recursive
    echo "✅ Formatted all Terraform files"
}

# Validate and format
function tfcheck() {
    terraform fmt -recursive
    terraform validate
}

# Show plan in JSON
function tfpj() {
    terraform plan -out=tfplan
    terraform show -json tfplan | jq
    rm tfplan
}

# Show specific output
function tfout() {
    if [[ -z "$1" ]]; then
        terraform output
    else
        terraform output "$1"
    fi
}

# List all resources
function tfls() {
    terraform state list
}

# Show resource details
function tfshow() {
    if [[ -z "$1" ]]; then
        echo "Usage: tfshow <resource>"
        echo "Available resources:"
        terraform state list
        return 1
    fi
    terraform state show "$1"
}

# Clean Terraform files
function tfclean() {
    echo "🧹 Cleaning Terraform files..."
    rm -rf .terraform
    rm -f .terraform.lock.hcl
    rm -f terraform.tfstate*
    rm -f tfplan
    echo "✅ Done"
}

# Switch workspace
function tfswitch() {
    local workspace="$1"
    if [[ -z "$workspace" ]]; then
        echo "Available workspaces:"
        terraform workspace list
        return 1
    fi
    terraform workspace select "$workspace" || terraform workspace new "$workspace"
}

# Import resource
function tfimport() {
    local resource="$1"
    local id="$2"
    if [[ -z "$resource" ]] || [[ -z "$id" ]]; then
        echo "Usage: tfimport <resource> <id>"
        return 1
    fi
    terraform import "$resource" "$id"
}

# Terraform version info
function tfinfo() {
    echo "Terraform: $(terraform version | head -1)"
    if [[ -f ".terraform.lock.hcl" ]]; then
        echo "Lock file: present"
    fi
    if [[ -d ".terraform" ]]; then
        echo "Initialized: yes"
    fi
    local workspace=$(terraform workspace show 2>/dev/null)
    if [[ -n "$workspace" ]]; then
        echo "Workspace: $workspace"
    fi
}

# Run terraform with specific var file
function tfvar() {
    local var_file="$1"
    shift
    terraform "$@" -var-file="$var_file"
}

# Plan with target
function tfpt() {
    local target="$1"
    if [[ -z "$target" ]]; then
        echo "Usage: tfpt <target>"
        return 1
    fi
    terraform plan -target="$target"
}

# Apply with target
function tfat() {
    local target="$1"
    if [[ -z "$target" ]]; then
        echo "Usage: tfat <target>"
        return 1
    fi
    terraform apply -target="$target"
}
