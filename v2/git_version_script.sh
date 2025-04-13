#!/bin/bash
VERSION="1.0.0"
# Script to manage git versioning for the Block Clock project
# Usage: ./git_version_manager.sh [version_number]
# Example: ./git_version_manager.sh 0.1

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

# Check if version is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 [version_number]"
    echo "Example: $0 0.1"
    exit 1
fi

# Initialize variables
VERSION_NUM=$1
LAST_COMMAND=""
LAST_BRANCH=$(get_current_branch)
SCRIPT_PATH="$0"
SUPPORT_FILES="setup_block_clock.sh README.md git_version_manager.sh version_script.sh"

# Process all versions in sequence if all is specified
if [ "$VERSION_NUM" = "all" ]; then
    for ver in 0.1 0.2 0.3 1.0 1.1 1.2; do
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

# Make sure we're working with a clean state
if [ -n "$(git status --porcelain)" ]; then
    echo "Working directory is not clean. Please commit or stash changes first."
    exit 1
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
    echo "Version directory v$VERSION_NUM not found, skipping copy"
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

# Commit changes
echo "Committing changes for version $VERSION_NUM..."
git commit -m "Add version $VERSION_NUM files" || handle_error "Failed to commit changes"

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

# Clean up working directory
echo "Cleaning up working directory..."
for file in $(find . -maxdepth 1 -name "*.py"); do
    rm "$file" 2>/dev/null
done

echo "Done!"
