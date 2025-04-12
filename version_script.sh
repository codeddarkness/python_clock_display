#!/bin/bash
# Universal script to add version numbers to Python, Bash, and Markdown files
# Works on both macOS (BSD) and Linux (GNU) environments
# Usage: ./add_version.sh VERSION_NUMBER [directory]
# Example: ./add_version.sh 1.2.0
# Example with directory: ./add_version.sh 1.2.0 ./v2

# Check if version number was provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 VERSION_NUMBER [directory]"
    echo "Example: $0 1.2.0"
    echo "Example with directory: $0 1.2.0 ./v2"
    exit 1
fi

VERSION="$1"
DIRECTORY="."

# If a directory was specified, use it
if [ $# -ge 2 ]; then
    DIRECTORY="$2"
fi

echo "Adding version $VERSION to Python, Bash, and Markdown files in $DIRECTORY"

# Detect environment (macOS or Linux)
OS_TYPE="linux"
if [[ "$(uname)" == "Darwin" ]]; then
    OS_TYPE="macos"
    echo "Detected macOS environment"
else
    echo "Detected Linux environment"
fi

# Process Python files
find "$DIRECTORY" -type f -name "*.py" | while read file; do
    echo "Processing $file..."
    
    # Check if VERSION line already exists
    if grep -q "^VERSION\s*=" "$file"; then
        echo "  Version line already exists in $file, skipping"
    else
        # Create a temporary file for macOS
        if [ "$OS_TYPE" == "macos" ]; then
            tmp_file=$(mktemp)
            
            # Add VERSION line after the encoding line or the first line
            if grep -q "# -\*-" "$file"; then
                # Add after the encoding line
                awk '/-\*-/ {print; print "VERSION=\"'"$VERSION"'\""; next} {print}' "$file" > "$tmp_file"
            else
                # Add after the first line (shebang)
                awk 'NR==1 {print; print "VERSION=\"'"$VERSION"'\""; next} {print}' "$file" > "$tmp_file"
            fi
            
            # Replace original file with modified content
            mv "$tmp_file" "$file"
        else
            # Linux version using sed
            if grep -q "# -\*-" "$file"; then
                # Add after the encoding line
                sed -i '/-\*-/ a\
VERSION="'"$VERSION"'"' "$file"
            else
                # Add after the first line (shebang)
                sed -i '1 a\
VERSION="'"$VERSION"'"' "$file"
            fi
        fi
        echo "  Added version $VERSION to $file"
    fi
done

# Process Bash files
find "$DIRECTORY" -type f -name "*.sh" | while read file; do
    echo "Processing $file..."
    
    # Check if VERSION line already exists
    if grep -q "^VERSION\s*=" "$file"; then
        echo "  Version line already exists in $file, skipping"
    else
        if [ "$OS_TYPE" == "macos" ]; then
            # Create a temporary file
            tmp_file=$(mktemp)
            
            # Add VERSION line after the shebang line
            awk 'NR==1 {print; print "VERSION=\"'"$VERSION"'\""; next} {print}' "$file" > "$tmp_file"
            
            # Replace original file with modified content
            mv "$tmp_file" "$file"
        else
            # Linux version using sed
            sed -i '1 a\
VERSION="'"$VERSION"'"' "$file"
        fi
        echo "  Added version $VERSION to $file"
    fi
done

# Process Markdown files
find "$DIRECTORY" -type f -name "*.md" | while read file; do
    echo "Processing $file..."
    
    # Check if version is already in the title line
    if grep -q "^# .* (v[0-9]" "$file"; then
        echo "  Version already in title of $file, skipping"
    else
        if [ "$OS_TYPE" == "macos" ]; then
            # Create a temporary file
            tmp_file=$(mktemp)
            
            # Check if there's a title line starting with #
            if grep -q "^# " "$file"; then
                # Add version to the title (only the first occurrence)
                modified=0
                while IFS= read -r line; do
                    if [[ $line =~ ^#\s.* ]] && [ $modified -eq 0 ]; then
                        echo "$line (v$VERSION)" >> "$tmp_file"
                        modified=1
                    else
                        echo "$line" >> "$tmp_file"
                    fi
                done < "$file"
                echo "  Added version $VERSION to title in $file"
            else
                # Add a new title with version
                echo "# Block Clock (v$VERSION)" > "$tmp_file"
                echo "" >> "$tmp_file"
                cat "$file" >> "$tmp_file"
                echo "  Added new title with version $VERSION to $file"
            fi
            
            # Replace original file with modified content
            mv "$tmp_file" "$file"
        else
            # Check if there's a title line starting with #
            if grep -q "^# " "$file"; then
                # Add version to the title
                sed -i '0,/^# / s/^# \(.*\)$/# \1 (v'"$VERSION"')/' "$file"
                echo "  Added version $VERSION to title in $file"
            else
                # Add a new title with version
                sed -i '1i\# Block Clock (v'"$VERSION"')\n' "$file"
                echo "  Added new title with version $VERSION to $file"
            fi
        fi
    fi
done

echo "Version addition complete!"
