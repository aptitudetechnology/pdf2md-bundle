// browser-wrapper.js
// This is the only wrapper you need for pdf2md in the browser

import { convert } from 'unpdf';
import { Buffer } from 'buffer';

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

    return await convert(pdfBuffer, options);
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
