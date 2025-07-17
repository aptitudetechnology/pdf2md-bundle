#!/bin/bash

# Build script for pdf2md browser bundle

echo "Setting up pdf2md browser bundle..."

# Install dependencies
echo "Installing dependencies..."
npm install

# Create the browser wrapper entry point
echo "Creating browser entry point..."
cat > browser-entry.js << 'EOF'
// Browser entry point for pdf2md
const pdf2md = require('./browser-wrapper');
module.exports = pdf2md;
EOF

# Update webpack config to use browser entry
echo "Updating webpack configuration..."
sed -i "s|entry: './lib/pdf2md.js'|entry: './browser-entry.js'|g" webpack.config.js

# Build the bundle
echo "Building bundle..."
npm run build

# Check if build was successful
if [ -f "dist/pdf2md.bundle.js" ]; then
    echo "✅ Bundle created successfully at dist/pdf2md.bundle.js"
    echo "Bundle size: $(du -h dist/pdf2md.bundle.js | cut -f1)"
else
    echo "❌ Build failed - bundle not created"
    exit 1
fi

echo "Done! You can now use the bundle in your browser."