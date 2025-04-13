#!/bin/bash
VERSION="1.0.0"
# Script to manage git versioning for the Block Clock project
# Usage: ./git_version_script.sh [version_number]
# Example: ./git_version_script.sh 0.1
# Features:
# - Skips versions that have already been processed
# - Automatically cleans and commits between versions
# - Handles errors with proper rollback
# - Supports running all versions in sequence

# Error handling function
handle_error() {
    echo "Error: $1"
    echo "Attempting to revert the last command..."
    
    # Check what went wrong and revert
    if [ -n "$LAST_BRANCH" ]; then
        git checkout $LAST_BRANCH 2>/dev/null || echo "Could not switch back to previous branch"
    fi
    
    if [ $LAST_COMMAND = "create" ]; then
        # If we failed creating a branch, no need to delete anything
        echo "No changes were committed"
    elif [ $LAST_COMMAND = "commit" ]; then
        # If commit failed, reset changes
        git reset --hard HEAD 2>/dev/null || echo "Failed to reset changes"
    elif [ $LAST_COMMAND = "push" ]; then
        # If push failed, no remote changes to worry about
        echo "No remote changes were made"
    elif [ $LAST_COMMAND = "merge" ]; then
        # If merge failed, abort the merge
        git merge --abort 2>/dev/null || echo "Failed to abort merge"
    fi
    
    exit 1
}

# Get current branch (compatible with older Git versions)
get_current_branch() {
    git branch | grep '^*' | cut -d' ' -f2
}

# Check if a branch exists locally or remotely
branch_exists() {
    # Check if branch exists locally
    if git show-ref --verify --quiet refs/heads/$1; then
        return 0  # Branch exists
    fi
    
    # Check if branch exists remotely
    if git ls-remote --exit-code --heads origin $1 >/dev/null 2>&1; then
        return 0  # Branch exists
    fi
    
    return 1  # Branch doesn't exist
}

# Check if a tag exists
tag_exists() {
    git rev-parse --verify --quiet refs/tags/$1 >/dev/null 2>&1
    return $?
}

# Clean up working directory and commit changes
cleanup_and_commit() {
    # Clean up working directory
    echo "Cleaning up working directory..."
    for file in $(find . -maxdepth 1 -name "*.py"); do
        rm "$file" 2>/dev/null
    done
    
    # Commit the cleanup if there are changes
    if [ -n "$(git status --porcelain)" ]; then
        echo "Committing cleanup changes..."
        git add -A
        git commit -m "Clean up after version $1" || handle_error "Failed to commit cleanup"
        
        # Push changes if we have a remote
        if git remote | grep -q "origin"; then
            echo "Pushing cleanup changes..."
            git push || handle_error "Failed to push cleanup changes"
        fi
    else
        echo "No changes to commit after cleanup"
    fi
}

# Check if version is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 [version_number]"
    echo "Example: $0 0.1"
    echo "         $0 all"
    exit 1
fi

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

# Initialize variables
VERSION_NUM=$1
LAST_COMMAND=""
LAST_BRANCH=$(get_current_branch)
SCRIPT_PATH="$0"
SUPPORT_FILES="setup_block_clock.sh README.md git_version_script.sh version_script.sh check_git_commands.sh"

# Make sure we're on main branch to start
git checkout main 2>/dev/null || handle_error "Failed to switch to main branch"

# Process all versions in sequence if all is specified
if [ "$VERSION_NUM" = "all" ]; then
    # Define versions to process
    VERSIONS=("0.1" "0.2" "0.3" "1.1" "1.2")
    
    for ver in "${VERSIONS[@]}"; do
        echo "Processing version $ver..."
        $SCRIPT_PATH $ver
        RESULT=$?
        if [ $RESULT -ne 0 ]; then
            echo "Error processing version $ver, stopping."
            exit $RESULT
        fi
        echo "Version $ver processed successfully."
    done
    exit 0
fi

echo "=== Starting versioning process for v$VERSION_NUM ==="

# Check if this version has already been processed
if tag_exists "v$VERSION_NUM"; then
    echo "Version $VERSION_NUM already has a tag, checking branches..."
    if branch_exists "dev/version_$VERSION_NUM" && branch_exists "stable/version_$VERSION_NUM"; then
        echo "Development and stable branches already exist for version $VERSION_NUM"
        echo "Skipping this version as it appears to be already processed."
        echo "To force reprocessing, delete the tag and branches first:"
        echo "  git tag -d v$VERSION_NUM"
        echo "  git branch -D dev/version_$VERSION_NUM stable/version_$VERSION_NUM"
        echo "  git push origin :refs/tags/v$VERSION_NUM :refs/heads/dev/version_$VERSION_NUM :refs/heads/stable/version_$VERSION_NUM"
        exit 0
    fi
fi

# Create and switch to development branch
echo "Creating dev branch for version $VERSION_NUM..."
LAST_COMMAND="create"
git checkout -b dev/version_$VERSION_NUM 2>/dev/null || handle_error "Failed to create development branch"

# Copy version-specific files to project root
echo "Copying version $VERSION_NUM files to project root..."
if [ -d "v$VERSION_NUM" ]; then
    cp v$VERSION_NUM/* . 2>/dev/null || handle_error "Failed to copy files"
else
    echo "Warning: Version directory v$VERSION_NUM not found, looking for files in other locations..."
    
    # Try to find matching files elsewhere
    if [ "$VERSION_NUM" = "0.1" ]; then
        cp block_clock.py clock_v1.py pi_clock.py . 2>/dev/null || true
    elif [ "$VERSION_NUM" = "0.2" ]; then
        cp countdown*.py . 2>/dev/null || true
    elif [ "$VERSION_NUM" = "0.3" ]; then
        cp block_countdown_switch.py time_countdown_*.py toggle_time_countdown.py . 2>/dev/null || true
    fi
    
    # Check if we found any files
    if [ -z "$(ls -A *.py 2>/dev/null)" ]; then
        echo "Error: No Python files found for version $VERSION_NUM"
        handle_error "No files to commit for this version"
    fi
fi

# Add files to git
echo "Adding version $VERSION_NUM files to git..."
LAST_COMMAND="commit"
# First add the specific version files
git add *.py 2>/dev/null
# Then add support files
for file in $SUPPORT_FILES; do
    if [ -f "$file" ]; then
        git add "$file" 2>/dev/null
    fi
done

# Add README if present
if [ -f "v$VERSION_NUM/README.md" ]; then
    cp "v$VERSION_NUM/README.md" "README.md" 2>/dev/null || true
elif [ -f "readme_v${VERSION_NUM/./}".md ]; then
    cp "readme_v${VERSION_NUM/./}".md "README.md" 2>/dev/null || true
fi

git add README.md 2>/dev/null || true

# Commit changes
echo "Committing changes for version $VERSION_NUM..."
if [ -n "$(git status --porcelain)" ]; then
    git commit -m "Add version $VERSION_NUM files" || handle_error "Failed to commit changes"
else
    echo "No changes to commit. Did you copy the right files?"
    handle_error "No changes to commit for this version"
fi

# Create version tag
echo "Creating tag for version $VERSION_NUM..."
git tag -a v$VERSION_NUM -m "Version $VERSION_NUM" || handle_error "Failed to create tag"

# Push development branch if we have a remote
if git remote | grep -q "origin"; then
    echo "Pushing development branch..."
    LAST_COMMAND="push"
    git push -u origin dev/version_$VERSION_NUM || handle_error "Failed to push development branch"
    git push --tags || handle_error "Failed to push tags"
else
    echo "No remote found, skipping push"
fi

# Create and switch to stable branch
echo "Creating stable branch for version $VERSION_NUM..."
LAST_COMMAND="create"
git checkout -b stable/version_$VERSION_NUM || handle_error "Failed to create stable branch"

# Commit to stable branch (usually would include additional testing/verification)
echo "Committing to stable branch..."
LAST_COMMAND="commit"
git commit --allow-empty -m "Stable version $VERSION_NUM" || handle_error "Failed to commit to stable branch"

# Push stable branch if we have a remote
if git remote | grep -q "origin"; then
    echo "Pushing stable branch..."
    LAST_COMMAND="push"
    git push -u origin stable/version_$VERSION_NUM || handle_error "Failed to push stable branch"
else
    echo "No remote found, skipping push"
fi

# Switch to main and merge stable branch
echo "Switching to main branch..."
LAST_COMMAND="create"
git checkout main || handle_error "Failed to switch to main branch"

# Merge stable branch into main
echo "Merging stable version into main..."
LAST_COMMAND="merge"
git merge --no-ff stable/version_$VERSION_NUM -m "Merge version $VERSION_NUM into main" || handle_error "Failed to merge into main"

# Push main branch if we have a remote
if git remote | grep -q "origin"; then
    echo "Pushing main branch..."
    LAST_COMMAND="push"
    git push || handle_error "Failed to push main branch"
else
    echo "No remote found, skipping push"
fi

echo "=== Version $VERSION_NUM processing complete ==="
echo "Development branch: dev/version_$VERSION_NUM"
echo "Stable branch: stable/version_$VERSION_NUM"
echo "Tag: v$VERSION_NUM"
echo "All changes have been merged into main"

# Clean up and commit before moving to the next version
cleanup_and_commit $VERSION_NUM

echo "Done!"
