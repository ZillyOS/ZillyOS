#!/usr/bin/env node

/**
 * Development watch script for ZillyOS
 * 
 * This script watches for file changes and rebuilds the project incrementally.
 */

const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const chokidar = require('chokidar');

// Configuration
const SRC_DIR = path.resolve(__dirname, '../src');
const MODULES_DIR = path.join(SRC_DIR, 'modules');
const DEBOUNCE_TIME = 300; // milliseconds

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

// Create and start the TypeScript compiler in watch mode
function startTypeScriptWatch() {
  logInfo('Starting TypeScript compiler in watch mode');
  
  const tsc = spawn('npx', ['tsc', '--watch', '--preserveWatchOutput'], {
    cwd: path.resolve(__dirname, '..'),
    shell: true,
    stdio: 'pipe'
  });
  
  tsc.stdout.on('data', (data) => {
    const output = data.toString().trim();
    if (output) {
      if (output.includes('Found 0 errors')) {
        logSuccess('Compilation succeeded');
      } else if (output.includes('error')) {
        console.error(output);
      } else {
        console.log(output);
      }
    }
  });
  
  tsc.stderr.on('data', (data) => {
    logError(data.toString().trim());
  });
  
  tsc.on('close', (code) => {
    if (code !== 0) {
      logError(`TypeScript compiler exited with code ${code}`);
      process.exit(code);
    }
  });
  
  return tsc;
}

// Watch for changes to the configuration files and restart the TypeScript compiler
function watchConfigFiles(tscProcess) {
  let restarting = false;
  let debounceTimer = null;
  
  const restartCompiler = () => {
    if (restarting || debounceTimer) return;
    
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
      restarting = true;
      logInfo('Configuration changed, restarting TypeScript compiler');
      
      tscProcess.kill();
      
      // Give the process a moment to shut down
      setTimeout(() => {
        const newTscProcess = startTypeScriptWatch();
        watchConfigFiles(newTscProcess);
        restarting = false;
        debounceTimer = null;
      }, 500);
    }, DEBOUNCE_TIME);
  };
  
  // Watch for changes to configuration files
  const configWatcher = chokidar.watch([
    path.resolve(__dirname, '../tsconfig.json'),
    path.resolve(__dirname, '../src/**/tsconfig.json')
  ], {
    ignoreInitial: true
  });
  
  configWatcher.on('change', (filePath) => {
    logInfo(`Configuration file changed: ${path.relative(process.cwd(), filePath)}`);
    restartCompiler();
  });
  
  return configWatcher;
}

// Start the development server
function startDevServer() {
  logInfo('Starting development server');
  
  const nodemon = spawn('npx', ['nodemon', '--watch', 'dist', '--exec', 'node dist/index.js'], {
    cwd: path.resolve(__dirname, '..'),
    shell: true,
    stdio: 'inherit'
  });
  
  nodemon.on('close', (code) => {
    if (code !== 0 && code !== null) {
      logError(`Development server exited with code ${code}`);
    }
  });
  
  return nodemon;
}

// Main function
function main() {
  try {
    logInfo('Starting ZillyOS development watch mode');
    
    // Install chokidar if it's not already installed
    if (!fs.existsSync(path.resolve(__dirname, '../node_modules/chokidar'))) {
      logInfo('Installing required dependencies');
      spawn.sync('npm', ['install', 'chokidar', 'nodemon', '--save-dev'], {
        cwd: path.resolve(__dirname, '..'),
        stdio: 'inherit'
      });
    }
    
    // Start TypeScript compiler in watch mode
    const tscProcess = startTypeScriptWatch();
    
    // Watch for changes to configuration files
    const configWatcher = watchConfigFiles(tscProcess);
    
    // Start the development server
    const devServer = startDevServer();
    
    // Handle termination signals
    const cleanup = () => {
      logInfo('Shutting down...');
      configWatcher.close();
      tscProcess.kill();
      devServer.kill();
      process.exit(0);
    };
    
    process.on('SIGINT', cleanup);
    process.on('SIGTERM', cleanup);
    
    logSuccess('Watch mode started successfully');
    logInfo('Press Ctrl+C to stop');
  } catch (error) {
    logError(`Failed to start watch mode: ${error.message}`);
    process.exit(1);
  }
}

// Run the main function
main(); 