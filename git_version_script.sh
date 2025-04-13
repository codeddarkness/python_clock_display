#!/bin/bash
VERSION="2.2.0"

# Error handling and logging
log_error() {
    echo "[ERROR] $1" >&2
    echo "$1" >> git_version_script.log
}

# Safely execute a git command
safe_git() {
    local cmd="$1"
    shift
    git $cmd "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        log_error "Git command failed: git $cmd $*"
        return $status
    fi
    return 0
}

# Check if a branch exists
branch_exists() {
    git show-ref --verify --quiet refs/heads/"$1"
}

# Generate unique branch name
generate_branch_name() {
    local base_name="$1"
    local suffix=""
    local counter=1
    
    while branch_exists "${base_name}${suffix}"; do
        suffix="_${counter}"
        ((counter++))
    done
    
    echo "${base_name}${suffix}"
}

# Process a single version
process_version() {
    local version="$1"
    local version_dir="v${version}"
    
    # Ensure we start from a clean main branch
    safe_git checkout main || return 1
    
    # Create development branch
    local dev_branch=$(generate_branch_name "dev/version_${version}")
    safe_git checkout -b "$dev_branch" || return 1
    
    # Copy and add version-specific files
    if [ -d "$version_dir" ]; then
        # Copy Python files
        find "$version_dir" -maxdepth 1 -name "*.py" -exec cp {} . \;
        
        # Copy README if exists
        if [ -f "${version_dir}/README.md" ]; then
            cp "${version_dir}/README.md" README.md
        fi
        
        # Stage all new/modified files
        safe_git add . || return 1
    else
        log_error "Version directory ${version_dir} not found"
        return 1
    fi
    
    # Commit changes
    safe_git commit -m "Add files for version ${version}" || return 1
    
    # Create and switch to stable branch
    local stable_branch=$(generate_branch_name "stable/version_${version}")
    safe_git checkout -b "$stable_branch" || return 1
    
    # Tag the version
    safe_git tag -a "v${version}" -m "Release version ${version}" || return 1
    
    # Push branches and tags if remote exists
    if git remote | grep -q "origin"; then
        safe_git push -u origin "$dev_branch" || return 1
        safe_git push -u origin "$stable_branch" || return 1
        safe_git push --tags || return 1
    fi
    
    # Merge stable branch into main
    safe_git checkout main || return 1
    safe_git merge --no-ff "$stable_branch" -m "Merge version ${version} into main" || return 1
    
    # Push main if remote exists
    if git remote | grep -q "origin"; then
        safe_git push || return 1
    fi
    
    echo "Successfully processed version ${version}"
    return 0
}

# Main script execution
main() {
    # Define versions to process in order
    local versions=("0.1" "0.2" "0.3" "1.0" "1.1" "2.0")
    
    # Check for uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        read -p "Uncommitted changes exist. Commit now? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            safe_git add -A
            safe_git commit -m "Auto-commit before version processing"
        else
            echo "Please commit or stash changes manually."
            return 1
        fi
    fi
    
    # Process each version
    for ver in "${versions[@]}"; do
        echo "Processing version ${ver}..."
        process_version "$ver" || {
            echo "Failed to process version ${ver}. Stopping."
            return 1
        }
    done
    
    echo "All versions processed successfully!"
}

# Run the main script
main "$@"
