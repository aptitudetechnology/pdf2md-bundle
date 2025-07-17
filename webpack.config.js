const path = require('path');
const webpack = require('webpack');

module.exports = {
  mode: 'production',
  entry: './lib/pdf2md.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'pdf2md.bundle.js',
    library: 'pdf2md',
    libraryTarget: 'umd',
    globalObject: 'this'
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
      "vm": require.resolve("vm-browserify")
    }
  },
  plugins: [
    new webpack.ProvidePlugin({
      Buffer: ['buffer', 'Buffer'],
      process: 'process/browser',
    }),
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify('production')
    })
  ],
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env']
          }
        }
      }
    ]
  },
  externals: {
    // If pdf.js is used externally, you might want to externalize it
    // 'pdfjs-dist': 'pdfjsLib'
  }
};