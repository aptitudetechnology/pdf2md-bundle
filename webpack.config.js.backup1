const path = require('path');
const webpack = require('webpack');

module.exports = {
  mode: 'production',
  entry: './browser-entry.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'pdf2md.bundle.js',
    library: 'pdf2md',
    libraryTarget: 'umd',
    globalObject: "window"
  },
  resolve: {
    fallback: {
      // Node.js core modules that need polyfills for browser
      "fs": false,
      "path": require.resolve("path-browserify"),
      "stream": require.resolve("stream-browserify"),
      "buffer": require.resolve("buffer"),
      "util": require.resolve("util"),
      "assert": require.resolve("assert"),
      "crypto": require.resolve("crypto-browserify"),
      "os": require.resolve("os-browserify/browser"),
      "url": require.resolve("url"),
      "zlib": require.resolve("browserify-zlib"),
      "https": require.resolve("https-browserify"),
      "http": require.resolve("stream-http"),
      "vm": require.resolve("vm-browserify"),
      "canvas": false, // Canvas is not available in browser
      "worker_threads": false,
      "child_process": false,
      "process/browser": require.resolve("process/browser")
    },
    alias: {
      'process': 'process/browser'
    }
  },
  plugins: [
    new webpack.ProvidePlugin({
      Buffer: ['buffer', 'Buffer'],
      process: 'process/browser',
    }),
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify('production'),
      'global': 'globalThis'
    })
  ],
  module: {
    rules: [
      {
        test: /\.js$/,
        // MODIFIED LINE HERE:
        // Transpile all .js files EXCEPT those in node_modules that are NOT unpdf or enumify
        // This regex means: "match node_modules/ followed by anything that IS NOT (unpdf or enumify)"
        // So it EXCLUDES everything *else* in node_modules, effectively including unpdf and enumify.
        exclude: /node_modules\/(?!(unpdf|enumify)\/).*/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env']
          }
        }
      },
      {
        test: /\.wasm$/,
        type: 'webassembly/async'
      }
    ]
  },
  experiments: {
    asyncWebAssembly: true
  },
  externals: {
    // If you're using pdf.js externally, uncomment this
    // 'pdfjs-dist': 'pdfjsLib'
  }
};