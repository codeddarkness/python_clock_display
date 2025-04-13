#!/bin/bash
VERSION="1.1.1"
# Script to manage git versioning for the Block Clock project

# Error handling function
handle_error() {
    echo "Error: $1"
    # Save error state to a recovery file
    echo "$CURRENT_VERSION:$LAST_COMMAND" > .version_recovery
    exit 1
}

# Get current branch (compatible with older Git versions)
get_current_branch() {
    git branch | grep '^*' | cut -d' ' -f2
}

# Recovery check function
check_recovery() {
    if [ -f .version_recovery ]; then
        RECOVERY_DATA=$(cat .version_recovery)
        RECOVERY_VERSION=$(echo $RECOVERY_DATA | cut -d':' -f1)
        RECOVERY_STEP=$(echo $RECOVERY_DATA | cut -d':' -f2)
        
        echo "Recovering from previous failed version: $RECOVERY_VERSION"
        echo "Last failed step: $RECOVERY_STEP"
        
        # Prompt user to continue or start over
        read -p "Do you want to continue from the last version? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Remove the recovery file to prevent repeated recovery
            rm .version_recovery
            
            # Set the version to continue from
            VERSION_TO_PROCESS=()
            FOUND_RECOVERY=0
            for ver in "${VERSIONS[@]}"; do
                if [ "$ver" = "$RECOVERY_VERSION" ]; then
                    FOUND_RECOVERY=1
                fi
                
                if [ $FOUND_RECOVERY -eq 1 ]; then
                    VERSION_TO_PROCESS+=("$ver")
                fi
            done
        else
            # Start over
            rm .version_recovery
            VERSION_TO_PROCESS=("${VERSIONS[@]}")
        fi
    else
        VERSION_TO_PROCESS=("${VERSIONS[@]}")
    fi
}

# Versions to process
VERSIONS=("0.1" "0.2" "0.3" "1.0" "1.1" "2.0")

# Check for recovery
check_recovery

# Process versions
for ver in "${VERSION_TO_PROCESS[@]}"; do
    echo "Processing version $ver..."
    CURRENT_VERSION=$ver
    LAST_COMMAND=""
    
    # Check if we can continue safely
    if [ -n "$(git status --porcelain)" ]; then
        echo "Working directory is not clean."
        read -p "Do you want to commit all current changes before proceeding? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git add -A
            git commit -m "Auto-commit changes before versioning"
        else
            echo "Please commit or stash your changes manually, then run the script again."
            exit 1
        fi
    fi
    
    # Create and switch to development branch
    git checkout -b dev/version_$ver || handle_error "Failed to create development branch"
    
    # Copy version-specific files to project root
    if [ -d "v$ver" ]; then
        cp v$ver/* . 2>/dev/null || handle_error "Failed to copy files"
    fi
    
    # Add files to git
    git add *.py 2>/dev/null
    
    # If README exists in version directory, update main README
    if [ -f "v$ver/README.md" ]; then
        cp "v$ver/README.md" "README.md" 2>/dev/null
    fi
    
    # Commit changes
    git add README.md 2>/dev/null
    if [ -n "$(git status --porcelain)" ]; then
        git commit -m "Add version $ver files" || handle_error "Failed to commit changes"
    fi
    
    # Create version tag
    git tag -a v$ver -m "Version $ver" || handle_error "Failed to create tag"
    
    # Push if remote exists
    if git remote | grep -q "origin"; then
        git push -u origin dev/version_$ver || handle_error "Failed to push development branch"
        git push --tags || handle_error "Failed to push tags"
    fi
    
    echo "Version $ver processed successfully."
done

# Clean up recovery file
[ -f .version_recovery ] && rm .version_recovery

echo "All versions processed successfully!"
exit 0
