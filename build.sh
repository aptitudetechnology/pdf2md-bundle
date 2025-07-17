#!/bin/bash

# Build script for pdf2md browser bundle

echo "Setting up pdf2md browser bundle..."

# First, install the original package dependencies
echo "Installing original package dependencies..."
npm install

# Install additional bundling dependencies
echo "Installing bundling dependencies..."
npm install --save-dev webpack webpack-cli babel-loader @babel/core @babel/preset-env
npm install --save-dev assert buffer browserify-zlib crypto-browserify https-browserify os-browserify path-browserify process stream-browserify stream-http url util vm-browserify

# Install missing dependencies that the library needs
echo "Installing missing library dependencies..."
npm install enumify unpdf

# Check if pdfjs-dist is needed (common dependency for PDF processing)
echo "Installing PDF.js dependencies..."
npm install pdfjs-dist

# Create the browser wrapper entry point
echo "Creating browser entry point..."
cat > browser-entry.js << 'EOF'
// Browser entry point for pdf2md
const pdf2md = require('./browser-wrapper');
module.exports = pdf2md;
EOF

# The webpack config is already set to use browser-entry.js
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