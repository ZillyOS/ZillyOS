#!/usr/bin/env node

/**
 * Build script for ZillyOS
 * Handles production builds with optimizations
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Define build configuration
const BUILD_DIR = path.resolve(__dirname, '../../dist');
const SRC_DIR = path.resolve(__dirname, '..');
const BUNDLE_OPTIONS = {
  minify: true,
  sourceMaps: true
};

console.log('🚀 Starting ZillyOS build process...');

// Ensure build directory exists
if (!fs.existsSync(BUILD_DIR)) {
  fs.mkdirSync(BUILD_DIR, { recursive: true });
  console.log(`📁 Created build directory: ${BUILD_DIR}`);
}

try {
  // Clean previous build
  console.log('🧹 Cleaning previous build...');
  if (fs.existsSync(BUILD_DIR)) {
    fs.rmSync(BUILD_DIR, { recursive: true, force: true });
    fs.mkdirSync(BUILD_DIR, { recursive: true });
  }

  // Run TypeScript compiler
  console.log('⚙️ Compiling TypeScript...');
  execSync('npx tsc', { stdio: 'inherit' });

  // Copy necessary non-TypeScript files
  console.log('📋 Copying additional files...');
  const filesToCopy = [
    { source: 'package.json', dest: 'package.json' },
    { source: 'README.md', dest: 'README.md' },
    { source: '.env.example', dest: '.env.example' }
  ];

  filesToCopy.forEach(file => {
    const sourcePath = path.resolve(__dirname, '../../', file.source);
    const destPath = path.resolve(BUILD_DIR, file.dest);
    
    if (fs.existsSync(sourcePath)) {
      fs.copyFileSync(sourcePath, destPath);
      console.log(`📄 Copied ${file.source} to build directory`);
    }
  });

  console.log('✅ Build completed successfully!');
  console.log(`📦 Output directory: ${BUILD_DIR}`);
} catch (error) {
  console.error('❌ Build failed:', error);
  process.exit(1);
} 