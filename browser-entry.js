// browser-entry.js
// Browser entry point for pdf2md — for bundling with Webpack

// Optional global polyfill for environments that might not define `global`
if (typeof global === 'undefined') {
  globalThis.global = globalThis;
}

// Import the wrapper module (ensure browser-wrapper.js exports properly)
import pdf2md from './browser-wrapper.js';

// Export as default so Webpack exposes it to `window.pdf2md`
export default pdf2md;
