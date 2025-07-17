// browser-wrapper.js
// This file creates a browser-compatible wrapper for the pdf2md library

// Import the main pdf2md function
const pdf2md = require('./lib/pdf2md');

// Browser-compatible version that works with File objects or ArrayBuffers
function browserPdf2md(pdfInput, callbacks = {}) {
  return new Promise((resolve, reject) => {
    try {
      let pdfBuffer;
      
      // Handle different input types
      if (pdfInput instanceof File) {
        // Convert File to ArrayBuffer then to Buffer
        const reader = new FileReader();
        reader.onload = function(e) {
          pdfBuffer = Buffer.from(e.target.result);
          processPdf(pdfBuffer, callbacks, resolve, reject);
        };
        reader.onerror = reject;
        reader.readAsArrayBuffer(pdfInput);
        return;
      } else if (pdfInput instanceof ArrayBuffer) {
        pdfBuffer = Buffer.from(pdfInput);
      } else if (pdfInput instanceof Uint8Array) {
        pdfBuffer = Buffer.from(pdfInput);
      } else if (Buffer.isBuffer(pdfInput)) {
        pdfBuffer = pdfInput;
      } else {
        throw new Error('Invalid input type. Expected File, ArrayBuffer, Uint8Array, or Buffer');
      }
      
      processPdf(pdfBuffer, callbacks, resolve, reject);
    } catch (error) {
      reject(error);
    }
  });
}

function processPdf(pdfBuffer, callbacks, resolve, reject) {
  // Call the original pdf2md function
  pdf2md(pdfBuffer, callbacks)
    .then(resolve)
    .catch(reject);
}

// Export for browser use
if (typeof window !== 'undefined') {
  window.pdf2md = browserPdf2md;
}

// Export for module systems
module.exports = browserPdf2md;