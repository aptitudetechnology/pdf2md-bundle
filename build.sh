#!/bin/bash
# Build script for pdf2md browser bundle
echo "Setting up pdf2md browser bundle..."

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf dist/
rm -rf node_modules/
rm -f test.html

# Install base and bundling dependencies
echo "Installing dependencies..."
npm install
npm install --save-dev webpack webpack-cli babel-loader @babel/core @babel/preset-env @babel/plugin-transform-classes @babel/plugin-transform-runtime
npm install --save-dev assert buffer browserify-zlib crypto-browserify https-browserify os-browserify path-browserify process stream-browserify stream-http url util vm-browserify
npm install enumify unpdf pdfjs-dist

# Create test.html with all 3 buttons
echo "Generating test.html with buttons..."
cat > test.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>PDF2MD Test</title>
  <style>
    body { font-family: sans-serif; margin: 2em; }
    button { margin-right: 1em; margin-bottom: 1em; }
    pre { background: #f4f4f4; padding: 1em; border: 1px solid #ccc; }
  </style>
</head>
<body>
  <h1>PDF2MD Bundle Test</h1>
  
  <input type="file" id="pdfFile" accept=".pdf">
  <button onclick="convertPDF()">Convert PDF</button>
  <button onclick="runRootCause()">Run Root Cause Check</button>
  <button onclick="runTestBundle()">Run Test Bundle</button>

  <pre id="result">Result will appear here...</pre>

  <script src="dist/pdf2md.bundle.js"></script>

  <script>
    async function convertPDF() {
      const fileInput = document.getElementById('pdfFile');
      const resultDiv = document.getElementById('result');

      if (!fileInput.files[0]) {
        resultDiv.textContent = 'Please select a PDF file';
        return;
      }

      try {
        const arrayBuffer = await fileInput.files[0].arrayBuffer();
        const uint8Array = new Uint8Array(arrayBuffer);
        const markdown = await pdf2md.convert(uint8Array);
        resultDiv.textContent = markdown;
      } catch (error) {
        resultDiv.textContent = 'Error: ' + error.message;
        console.error('Conversion error:', error);
      }
    }

    function runRootCause() {
      const script = document.createElement('script');
      script.src = 'root-cause.js';
      script.onload = () => console.log('✅ root-cause.js loaded');
      script.onerror = () => console.error('❌ Failed to load root-cause.js');
      document.body.appendChild(script);
    }

    function runTestBundle() {
      const script = document.createElement('script');
      script.src = 'test-bundle.js';
      script.onload = () => console.log('✅ test-bundle.js loaded');
      script.onerror = () => console.error('❌ Failed to load test-bundle.js');
      document.body.appendChild(script);
    }
  </script>
</body>
</html>
EOF

# Bundle using Webpack
echo "Building bundle..."
npx webpack --config webpack.config.js

if [ -f "dist/pdf2md.bundle.js" ]; then
  echo "✅ Bundle created successfully at dist/pdf2md.bundle.js"
  echo "✅ test.html created with buttons for testing"
else
  echo "❌ Bundle not found. Check Webpack build output."
  exit 1
fi

echo "Done! Open test.html in your browser to test."
