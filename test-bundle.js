// test-bundle.js - Simple test script to identify the issue

console.log('Starting bundle test...');

// Try to load the bundle and see what happens
try {
  console.log('Loading bundle...');
  const pdf2md = require('./dist/pdf2md.bundle.js');
  console.log('Bundle loaded successfully:', pdf2md);
  console.log('Available methods:', Object.keys(pdf2md));
} catch (error) {
  console.error('Failed to load bundle:', error);
  console.error('Error stack:', error.stack);
}

// Also try to test the raw modules
console.log('\nTesting raw modules...');
try {
  const originalModule = require('./src/index.js');
  console.log('Original module loaded:', originalModule);
} catch (error) {
  console.error('Failed to load original module:', error);
  
  // Try alternative paths
  try {
    const altModule = require('./index.js');
    console.log('Alternative module loaded:', altModule);
  } catch (error2) {
    console.error('Failed to load alternative module:', error2);
  }
}

// Test individual dependencies
console.log('\nTesting dependencies...');
try {
  const enumify = require('enumify');
  console.log('Enumify loaded:', enumify);
} catch (error) {
  console.error('Failed to load enumify:', error);
}

try {
  const unpdf = require('unpdf');
  console.log('unpdf loaded:', unpdf);
} catch (error) {
  console.error('Failed to load unpdf:', error);
}