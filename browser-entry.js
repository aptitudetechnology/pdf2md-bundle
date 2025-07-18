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