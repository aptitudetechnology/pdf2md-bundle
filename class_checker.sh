#!/bin/bash

echo "=== PDF2MD Class Inheritance Analysis ==="
echo "Checking for class inheritance issues..."
echo

# Function to check a single file
check_file() {
    local file="$1"
    local basename=$(basename "$file")
    
    echo "--- Checking $basename ---"
    
    # Check for class definitions and extends
    if grep -q "class.*extends" "$file"; then
        echo "✓ Has class inheritance:"
        grep -n "class.*extends" "$file"
        
        # Check what it's extending
        local extends_what=$(grep "class.*extends" "$file" | sed 's/.*extends \([A-Za-z0-9_]*\).*/\1/')
        echo "  Extends: $extends_what"
        
        # Check if the parent class is imported
        if grep -q "require.*$extends_what" "$file"; then
            echo "  ✓ Parent class is imported"
            grep -n "require.*$extends_what" "$file"
        else
            echo "  ❌ Parent class NOT imported in this file"
        fi
    elif grep -q "^module.exports = class" "$file"; then
        echo "✓ Has class definition (no inheritance):"
        grep -n "^module.exports = class" "$file"
    else
        echo "  No class definitions found"
    fi
    
    # Check all requires
    echo "  Imports:"
    grep -n "require(" "$file" | head -5
    
    echo
}

# Check all model files
echo "=== CHECKING MODEL FILES ==="
for file in lib/models/*.js; do
    if [ -f "$file" ]; then
        check_file "$file"
    fi
done

# Check transformations directory
echo "=== CHECKING TRANSFORMATIONS ==="
find lib/models/transformations -name "*.js" 2>/dev/null | while read file; do
    if [ -f "$file" ]; then
        check_file "$file"
    fi
done

# Check main files
echo "=== CHECKING MAIN FILES ==="
for file in lib/util/*.js; do
    if [ -f "$file" ]; then
        check_file "$file"
    fi
done

echo "=== SUMMARY ==="
echo "All files with class inheritance:"
find lib/ -name "*.js" -exec grep -l "class.*extends" {} \; | while read file; do
    echo "  $file"
done

echo
echo "=== DEPENDENCY CHAIN ==="
echo "Checking require dependencies that might cause issues:"
find lib/ -name "*.js" -exec grep -H "require(" {} \; | grep -v node_modules | sort