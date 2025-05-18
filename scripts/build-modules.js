#!/usr/bin/env node

/**
 * Module build script for ZillyOS
 * 
 * This script compiles each module separately to ensure proper build order and dependencies.
 */

const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

// Configuration
const MODULES_DIR = path.resolve(__dirname, '../src/modules');
const BUILD_ORDER = [
  'feed',
  'storage',
  'analysis',
  'action',
  'output'
];

// Utility functions
function logInfo(message) {
  console.log(`\x1b[36m[INFO]\x1b[0m ${message}`);
}

function logSuccess(message) {
  console.log(`\x1b[32m[SUCCESS]\x1b[0m ${message}`);
}

function logError(message) {
  console.error(`\x1b[31m[ERROR]\x1b[0m ${message}`);
}

// Check if a directory exists
function directoryExists(dirPath) {
  try {
    return fs.statSync(dirPath).isDirectory();
  } catch (err) {
    return false;
  }
}

// Build a specific module
function buildModule(moduleName) {
  const modulePath = path.join(MODULES_DIR, moduleName);
  
  if (!directoryExists(modulePath)) {
    logInfo(`Skipping ${moduleName} (directory not found)`);
    return;
  }
  
  logInfo(`Building module: ${moduleName}`);
  
  try {
    // First run tsc in the module directory if it has its own tsconfig.json
    const moduleConfigPath = path.join(modulePath, 'tsconfig.json');
    if (fs.existsSync(moduleConfigPath)) {
      execSync('npx tsc', { 
        cwd: modulePath, 
        stdio: 'inherit'
      });
    } else {
      // Otherwise build using the root tsconfig with correct path
      // Fix the path issue by using the root directory path
      const rootTsConfigPath = path.resolve(__dirname, '../tsconfig.json');
      const outDir = path.resolve(__dirname, `../dist/modules/${moduleName}`);
      
      execSync(`npx tsc --project ${rootTsConfigPath} --outDir ${outDir}`, {
        cwd: modulePath,
        stdio: 'inherit'
      });
    }
    
    logSuccess(`Successfully built module: ${moduleName}`);
  } catch (error) {
    logError(`Failed to build module ${moduleName}`);
    throw error;
  }
}

// Build the shared utilities first
function buildShared() {
  const sharedPath = path.resolve(__dirname, '../src/shared');
  
  if (!directoryExists(sharedPath)) {
    logInfo('Skipping shared (directory not found)');
    return;
  }
  
  logInfo('Building shared utilities');
  
  try {
    // Fix the path issue by using the root directory path
    const rootTsConfigPath = path.resolve(__dirname, '../tsconfig.json');
    const outDir = path.resolve(__dirname, '../dist/shared');
    
    execSync(`npx tsc --project ${rootTsConfigPath} --outDir ${outDir}`, {
      cwd: sharedPath,
      stdio: 'inherit'
    });
    
    logSuccess('Successfully built shared utilities');
  } catch (error) {
    logError('Failed to build shared utilities');
    throw error;
  }
}

// Build the runtime
function buildRuntime() {
  const runtimePath = path.resolve(__dirname, '../src/runtime');
  
  if (!directoryExists(runtimePath)) {
    logInfo('Skipping runtime (directory not found)');
    return;
  }
  
  logInfo('Building runtime');
  
  try {
    // Fix the path issue by using the root directory path
    const rootTsConfigPath = path.resolve(__dirname, '../tsconfig.json');
    const outDir = path.resolve(__dirname, '../dist/runtime');
    
    execSync(`npx tsc --project ${rootTsConfigPath} --outDir ${outDir}`, {
      cwd: runtimePath,
      stdio: 'inherit'
    });
    
    logSuccess('Successfully built runtime');
  } catch (error) {
    logError('Failed to build runtime');
    throw error;
  }
}

// Main function to orchestrate the build process
async function main() {
  try {
    logInfo('Starting ZillyOS build process');
    
    // Clean the dist directory first
    logInfo('Cleaning dist directory');
    execSync('npm run clean', { stdio: 'inherit' });
    
    // Build shared utilities first since modules may depend on them
    buildShared();
    
    // Build runtime next
    buildRuntime();
    
    // Build each module in order
    for (const moduleName of BUILD_ORDER) {
      buildModule(moduleName);
    }
    
    logSuccess('Build completed successfully!');
  } catch (error) {
    logError('Build failed!');
    process.exit(1);
  }
}

// Run the main function
main(); 