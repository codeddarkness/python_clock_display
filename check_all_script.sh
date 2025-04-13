#!/bin/bash
VERSION="1.0.0"
# Script to check if required git commands are available for git_version_manager.sh

echo "Checking Git installation..."
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Please install Git before proceeding."
    exit 1
fi

echo "Git is installed."

echo "Checking Git version..."
GIT_VERSION=$(git --version | awk '{print $3}')
echo "Git version: $GIT_VERSION"

echo "Testing Git commands used in the versioning script..."

# Test branch creation
echo "Testing branch creation..."
git branch -D test_branch &>/dev/null # Remove if exists
git checkout -b test_branch &>/dev/null
if [ $? -ne 0 ]; then
    echo "WARNING: Unable to create test branch. The versioning script may fail."
else
    echo "Branch creation: OK"
fi

# Test current branch detection
echo "Testing current branch detection..."
CURRENT_BRANCH=$(git branch | grep '^*' | cut -d' ' -f2)
if [ -z "$CURRENT_BRANCH" ]; then
    echo "WARNING: Unable to detect current branch. The versioning script may fail."
else
    echo "Current branch detection: OK (Current branch: $CURRENT_BRANCH)"
fi

# Test tagging
echo "Testing tag creation..."
git tag -d test_tag &>/dev/null # Remove if exists
git tag -a test_tag -m "Test tag" &>/dev/null
if [ $? -ne 0 ]; then
    echo "WARNING: Unable to create test tag. The versioning script may fail."
else
    echo "Tag creation: OK"
    git tag -d test_tag &>/dev/null # Clean up
fi

# Test merge capabilities
echo "Testing merge capabilities..."
git branch -D test_merge_branch &>/dev/null # Remove if exists
git checkout -b test_merge_branch &>/dev/null
touch test_file.txt
git add test_file.txt &>/dev/null
git commit -m "Test commit" &>/dev/null
git checkout test_branch &>/dev/null
git merge --no-ff test_merge_branch -m "Test merge" &>/dev/null
if [ $? -ne 0 ]; then
    echo "WARNING: Unable to perform test merge. The versioning script may fail."
else
    echo "Merge capabilities: OK"
fi

# Cleanup
echo "Cleaning up test branches..."
git checkout main &>/dev/null || git checkout master &>/dev/null
git branch -D test_branch &>/dev/null
git branch -D test_merge_branch &>/dev/null
rm -f test_file.txt &>/dev/null

echo ""
echo "Git command check complete."
echo "If all tests passed, the git_version_manager.sh script should work correctly."
echo "If any warnings were displayed, you may need to update your Git version or use a modified script."
