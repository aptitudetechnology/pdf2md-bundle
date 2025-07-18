#!/bin/bash
# Build script for pdf2md browser bundle

echo "🛠 Setting up pdf2md browser bundle..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf dist/
rm -rf node_modules/

# Install dependencies
echo "📦 Installing dependencies..."
npm install
npm install --save-dev webpack webpack-cli babel-loader @babel/core @babel/preset-env @babel/plugin-transform-classes @babel/plugin-transform-runtime
npm install --save-dev assert buffer browserify-zlib crypto-browserify https-browserify os-browserify path-browserify process stream-browserify stream-http url util vm-browserify
npm install enumify unpdf pdfjs-dist

# Babel config
echo "🧾 Creating .babelrc..."
cat > .babelrc << 'EOF'
{
  "presets": [["@babel/preset-env", {
    "targets": { "browsers": ["> 1%", "last 2 versions"] },
    "modules": false,
    "loose": true
  }]],
  "plugins": [
    ["@babel/plugin-transform-classes", { "loose": true }],
    ["@babel/plugin-transform-runtime", { "helpers": false, "regenerator": true }]
  ]
}
EOF

# Build bundle
echo "🔧 Building bundle..."
npm run build

# Check if build succeeded
if [ -f "dist/pdf2md.bundle.js" ]; then
  echo "✅ Bundle created at dist/pdf2md.bundle.js"
  echo "📄 Generating test.html..."

  cat > test.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>PDF2MD Test</title>
  <style>
    body { font-family: sans-serif; padding: 1rem; }
    button { margin: 0.5rem 0.25rem; padding: 0.5rem 1rem; }
    #result { white-space: pre-wrap; background: #f4f4f4; padding: 1rem; margin-top: 1rem; border: 1px solid #ccc; }
  </style>
</head>
<body>
  <h1>PDF2MD Bundle Test</h1>

  <input type="file" id="pdfFile" accept=".pdf"><br>
  <button onclick="convertPDF()">Convert PDF</button>
  <button onclick="runRootCause()">Run Root Cause Check</button>
  <button onclick="runTestBundle()">Run Test Bundle</button>

  <pre id="result"></pre>

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

  echo "✅ test.html created with visible buttons!"
else
  echo "❌ Build failed — bundle not found"
  exit 1
fi

echo "🎉 Done! Open test.html in your browser to test."
