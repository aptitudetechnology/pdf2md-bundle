// Browser wrapper for pdf2md
// This file provides a browser-compatible interface to the pdf2md library

let pdf2mdModule;

// Try to load the main module with error handling
try {
  // First try to load the main module
  pdf2mdModule = require('./src/index.js');
} catch (error) {
  console.warn('Failed to load main module, trying alternative paths:', error.message);
  
  // Try alternative paths
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

// Create a browser-compatible wrapper
const pdf2md = {
  // Main conversion function
  convert: async function(pdfBuffer, options = {}) {
    try {
      if (!pdfBuffer) {
        throw new Error('PDF buffer is required');
      }
      
      // Ensure we have a Buffer
      if (!(pdfBuffer instanceof Buffer)) {
        if (pdfBuffer instanceof Uint8Array) {
          pdfBuffer = Buffer.from(pdfBuffer);
        } else if (typeof pdfBuffer === 'string') {
          pdfBuffer = Buffer.from(pdfBuffer, 'base64');
        } else {
          throw new Error('Invalid PDF data format');
        }
      }
      
      // Call the main conversion function
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

  // Utility function to convert file to buffer
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

  // Version info
  version: '0.2.1'
};

// Export for different module systems
if (typeof module !== 'undefined' && module.exports) {
  module.exports = pdf2md;
} else if (typeof window !== 'undefined') {
  window.pdf2md = pdf2md;
}

// Also export as default for ES6 modules
export default pdf2md;