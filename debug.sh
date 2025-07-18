#!/bin/bash
# Step-by-step debugging and fix script

echo "=== PDF2MD Bundle Debugging Script ==="
echo "This script will help identify and fix the 'Super expression' error"

# Step 1: Check the original module structure
echo "Step 1: Checking original module structure..."
if [ -f "src/index.js" ]; then
    echo "✅ Found src/index.js"
    echo "First few lines of src/index.js:"
    head -20 src/index.js
elif [ -f "index.js" ]; then
    echo "✅ Found index.js"
    echo "First few lines of index.js:"
    head -20 index.js
else
    echo "❌ No main entry point found"
    echo "Available files:"
    ls -la
fi

echo ""

# Step 2: Check for problematic class inheritance
echo "Step 2: Checking for class inheritance issues..."
echo "Searching for 'class' and 'extends' in source files:"
find . -name "*.js" -not -path "./node_modules/*" -not -path "./dist/*" | xargs grep -l "class\|extends" | head -10

echo ""

# Step 3: Check dependencies
echo "Step 3: Checking dependencies..."
echo "Current dependencies:"
if [ -f "package.json" ]; then
    grep -A 20 '"dependencies"' package.json
else
    echo "❌ No package.json found"
fi

echo ""

# Step 4: Create a minimal test
echo "Step 4: Creating minimal test..."
cat > minimal-test.js << 'EOF'
// Minimal test to identify the issue
console.log('Testing module loading...');

// Test 1: Try to load main module
try {
  console.log('Test 1: Loading main module...');
  const main = require('./src/index.js');
  console.log('✅ Main module loaded:', typeof main);
} catch (error) {
  console.log('❌ Main module failed:', error.message);
  
  // Try alternative
  try {
    const alt = require('./index.js');
    console.log('✅ Alternative module loaded:', typeof alt);
  } catch (error2) {
    console.log('❌ Alternative module failed:', error2.message);
  }
}

// Test 2: Try to load dependencies
console.log('\nTest 2: Loading dependencies...');
try {
  const enumify = require('enumify');
  console.log('✅ Enumify loaded:', typeof enumify);
} catch (error) {
  console.log('❌ Enumify failed:', error.message);
}

try {
  const unpdf = require('unpdf');
  console.log('✅ unpdf loaded:', typeof unpdf);
} catch (error) {
  console.log('❌ unpdf failed:', error.message);
}

// Test 3: