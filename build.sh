#!/bin/bash
# Build script for pdf2md browser bundle
echo "Setting up pdf2md browser bundle..."

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf dist/
rm -rf node_modules/

# First, install the original package dependencies
echo "Installing original package dependencies..."
npm install

# Install additional bundling dependencies
echo "Installing bundling dependencies..."
npm install --save-dev webpack webpack-cli babel-loader @babel/core @babel/preset-env @babel/plugin-transform-classes @babel/plugin-transform-runtime
npm install --save-dev assert buffer browserify-zlib crypto-browserify https-browserify os-browserify path-browserify process stream-browserify stream-http url util vm-browserify

# Install missing dependencies that the library needs
echo "Installing missing library dependencies..."
npm install enumify unpdf

# Check if pdfjs-dist is needed (common dependency for PDF processing)
echo "Installing PDF.js dependencies..."
npm install pdfjs-dist

# Create the browser wrapper entry point if it doesn't exist
if [ ! -f "browser-entry.js" ]; then
    echo "Creating browser entry point..."
    cat > browser-entry.js << 'EOF'
// Browser entry point for pdf2md
// This is the main entry point for the webpack bundle

// Polyfill for global if needed
if (typeof global === 'undefined') {
  global = globalThis;
}

// Load the browser wrapper
const pdf2md = require('./browser-wrapper');

// Export the module
module.exports = pdf2md;
EOF
fi

# Create browser wrapper if it doesn't exist
if [ ! -f "browser-wrapper.js" ]; then
    echo "Creating browser wrapper..."
    cat > browser-wrapper.js << 'EOF'
// Browser wrapper for pdf2md
let pdf2mdModule;

try {
  pdf2mdModule = require('./src/index.js');
} catch (error) {
  console.warn('Failed to load main module, trying alternative paths:', error.message);
  try {
    pdf2mdModule = require('./index.js');
  } catch (error2) {
    try {
      pdf2mdModule = require('./lib/index.js');
    } catch (error3) {
      console.error('Could not load pdf2md module from any known path');
      throw new Error('pdf2md module not found');
    }
  }
}

const pdf2md = {
  convert: async function(pdfBuffer, options = {}) {
    try {
      if (!pdfBuffer) {
        throw new Error('PDF buffer is required');
      }
      
      if (!(pdfBuffer instanceof Buffer)) {
        if (pdfBuffer instanceof Uint8Array) {
          pdfBuffer = Buffer.from(pdfBuffer);
        } else if (typeof pdfBuffer === 'string') {
          pdfBuffer = Buffer.from(pdfBuffer, 'base64');
        } else {
          throw new Error('Invalid PDF data format');
        }
      }
      
      if (pdf2mdModule && typeof pdf2mdModule.convert === 'function') {
        return await pdf2mdModule.convert(pdfBuffer, options);
      } else if (pdf2mdModule && typeof pdf2mdModule === 'function') {
        return await pdf2mdModule(pdfBuffer, options);
      } else {
        throw new Error('No valid conversion function found');
      }
    } catch (error) {
      console.error('PDF conversion error:', error);
      throw error;
    }
  },

  fileToBuffer: function(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = function(e) {
        resolve(Buffer.from(e.target.result));
      };
      reader.onerror = reject;
      reader.readAsArrayBuffer(file);
    });
  },

  version: '0.2.1'
};

if (typeof module !== 'undefined' && module.exports) {
  module.exports = pdf2md;
} else if (typeof window !== 'undefined') {
  window.pdf2md = pdf2md;
}

export default pdf2md;
EOF
fi

# Create .babelrc for more specific babel configuration
echo "Creating .babelrc..."
cat > .babelrc << 'EOF'
{
  "presets": [
    ["@babel/preset-env", {
      "targets": {
        "browsers": ["> 1%", "last 2 versions"]
      },
      "modules": false,
      "loose": true
    }]
  ],
  "plugins": [
    ["@babel/plugin-transform-classes", { "loose": true }],
    ["@babel/plugin-transform-runtime", {
      "helpers": false,
      "regenerator": true
    }]
  ]
}
EOF

# Build the bundle
echo "Building bundle..."
npm run build

# Check if build was successful
if [ -f "dist/pdf2md.bundle.js" ]; then
    echo "✅ Bundle created successfully at dist/pdf2md.bundle.js"
    echo "Bundle size: $(du -h dist/pdf2md.bundle.js | cut -f1)"
    
    # Create a simple test HTML file
    echo "Creating test HTML file..."
    cat > test.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>PDF2MD Test</title>
</head>
<body>
    <h1>PDF2MD Bundle Test</h1>
    <input type="file" id="pdfFile" accept=".pdf">
    <button onclick="convertPDF()">Convert PDF</button>
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
                console.log('pdf2md object:', pdf2md);
                const arrayBuffer = await fileInput.files[0].arrayBuffer();
                const uint8Array = new Uint8Array(arrayBuffer);
                const markdown = await pdf2md.convert(uint8Array);

                resultDiv.textContent = markdown;
            } catch (error) {
                resultDiv.textContent = 'Error: ' + error.message;
                console.error('Conversion error:', error);
            }
        }
    </script>
</body>
</html>
EOF
    echo "✅ Test HTML file created at test.html"
else
    echo "❌ Build failed - bundle not created"
    exit 1
fi

echo "Done! You can now use the bundle in your browser."
echo "Open test.html in your browser to test the bundle."