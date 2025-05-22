#!/usr/bin/env node

/**
 * Development server with hot reloading for ZillyOS
 */

const nodemon = require('nodemon');
const path = require('path');
const fs = require('fs');
const chalk = require('chalk');

// Check if .env file exists, create from example if not
const envPath = path.resolve(__dirname, '../.env');
const envExamplePath = path.resolve(__dirname, '../.env.example');

if (!fs.existsSync(envPath) && fs.existsSync(envExamplePath)) {
  console.log(chalk.yellow('No .env file found, creating from .env.example'));
  fs.copyFileSync(envExamplePath, envPath);
  console.log(chalk.green('.env file created. Please review and update as needed.'));
}

console.log(chalk.blue('🚀 Starting ZillyOS development server...'));

// Configure nodemon for development
nodemon({
  script: path.resolve(__dirname, '../src/index.ts'),
  ext: 'ts,json',
  exec: 'ts-node',
  watch: [path.resolve(__dirname, '../src')],
  env: { 'NODE_ENV': 'development' },
  delay: 500
});

// Log events
nodemon
  .on('start', () => {
    console.log(chalk.green('🔥 Development server started'));
  })
  .on('restart', (files) => {
    console.log(chalk.yellow('🔄 Server restarted due to changes in:'));
    console.log(chalk.yellow(files));
  })
  .on('quit', () => {
    console.log(chalk.red('👋 Development server stopped'));
    process.exit();
  })
  .on('error', (err) => {
    console.error(chalk.red('❌ Error during development server execution:'));
    console.error(err);
  });

// Listen for termination signals
process.once('SIGTERM', () => {
  nodemon.emit('quit');
});

process.once('SIGINT', () => {
  nodemon.emit('quit');
}); 