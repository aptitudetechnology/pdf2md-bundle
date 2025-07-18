// browser-wrapper.js
// This file provides a browser-compatible interface to the pdf2md library (for Webpack UMD build)

import { Buffer } from 'buffer';

// Try loading the core pdf2md logic from possible locations
let pdf2mdModule;

try {
  pdf2mdModule = await import('./src/index.js');
} catch (error1) {
  console.warn('Failed to load ./src/index.js:', error1.message);

  try {
    pdf2mdModule = await import('./index.js');
  } catch (error2) {
    try {
      pdf2mdModule = await import('./lib/index.js');
    } catch (error3) {
      console.error('Could not load pdf2md module from any known path');
      throw new Error('pdf2md module not found');
    }
  }
}

// Normalize default vs named export
const convertFn = pdf2mdModule.convert || pdf2mdModule.default || pdf2mdModule;

// Main browser-facing wrapper
const pdf2md = {
  version: '0.2.1',

  async convert(pdfBuffer, options = {}) {
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

    if (typeof convertFn === 'function') {
      return await convertFn(pdfBuffer, options);
    }

    throw new Error('No valid conversion function found');
  },

  fileToBuffer(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = function (e) {
        resolve(Buffer.from(e.target.result));
      };
      reader.onerror = reject;
      reader.readAsArrayBuffer(file);
    });
  }
};

export default pdf2md;
