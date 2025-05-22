#!/usr/bin/env node

/**
 * Documentation build script for ZillyOS
 * This script compiles and organizes documentation from various sources
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Configuration
const config = {
  sourceDir: path.resolve(__dirname, '../docs'),
  apiDocsDir: path.resolve(__dirname, '../docs/api'),
  outputDir: path.resolve(__dirname, '../docs/dist'),
  sidebarFile: path.resolve(__dirname, '../docs/_sidebar.md'),
  templatesDir: path.resolve(__dirname, '../docs/templates'),
  docsifyConfigFile: path.resolve(__dirname, '../docs/index.html'),
  homepageFile: path.resolve(__dirname, '../docs/home.md'),
  readmeFile: path.resolve(__dirname, '../README.md'),
  copyStaticFiles: [
    'index.html',
    '_sidebar.md',
    '_coverpage.md',
    'favicon.ico',
    '.nojekyll'
  ]
};

// Ensure output directory exists
if (!fs.existsSync(config.outputDir)) {
  fs.mkdirSync(config.outputDir, { recursive: true });
}

/**
 * Generate sidebar navigation from the docs directory structure
 */
function generateSidebar() {
  console.log('Generating sidebar navigation...');
  
  // Start with heading
  let sidebarContent = '# ZillyOS Documentation\n\n';
  
  // Add home link
  sidebarContent += '* [Home](home.md)\n';
  
  // Add links to main documentation sections
  const sections = [
    { path: 'guides', title: 'User Guides' },
    { path: 'api', title: 'API Reference' },
    { path: 'tutorials', title: 'Tutorials' },
    { path: 'development', title: 'Development' }
  ];
  
  sections.forEach(section => {
    const sectionPath = path.join(config.sourceDir, section.path);
    
    if (fs.existsSync(sectionPath) && fs.statSync(sectionPath).isDirectory()) {
      sidebarContent += `* ${section.title}\n`;
      
      // Add files in this section
      const files = fs.readdirSync(sectionPath)
        .filter(file => file.endsWith('.md'))
        .sort();
      
      files.forEach(file => {
        const filePath = path.join(section.path, file);
        const title = getDocumentTitle(path.join(sectionPath, file));
        sidebarContent += `  * [${title}](${filePath})\n`;
      });
    }
  });
  
  // Write sidebar content to file
  fs.writeFileSync(config.sidebarFile, sidebarContent);
  console.log(`Sidebar navigation generated: ${config.sidebarFile}`);
}

/**
 * Extract the title from a markdown document
 */
function getDocumentTitle(filePath) {
  if (!fs.existsSync(filePath)) {
    return path.basename(filePath, '.md');
  }
  
  const content = fs.readFileSync(filePath, 'utf8');
  const titleMatch = content.match(/^#\s+(.+)$/m);
  
  if (titleMatch && titleMatch[1]) {
    return titleMatch[1];
  }
  
  return path.basename(filePath, '.md');
}

/**
 * Create the home page from README if it doesn't exist
 */
function createHomePage() {
  if (!fs.existsSync(config.homepageFile) && fs.existsSync(config.readmeFile)) {
    console.log('Creating homepage from README...');
    fs.copyFileSync(config.readmeFile, config.homepageFile);
  }
}

/**
 * Create .nojekyll file for GitHub Pages
 */
function createNoJekyllFile() {
  const noJekyllFile = path.join(config.sourceDir, '.nojekyll');
  if (!fs.existsSync(noJekyllFile)) {
    fs.writeFileSync(noJekyllFile, '');
    console.log('Created .nojekyll file for GitHub Pages');
  }
}

/**
 * Create cover page if it doesn't exist
 */
function createCoverPage() {
  const coverPageFile = path.join(config.sourceDir, '_coverpage.md');
  
  if (!fs.existsSync(coverPageFile)) {
    const coverContent = `
# ZillyOS

> A modern and lightweight operating system runtime

- Simple and intuitive API
- Highly extensible architecture
- Cross-platform support

[GitHub](https://github.com/zillyzoo/ZillyOS)
[Get Started](home.md)

<!-- background color -->
![color](#f0f0f0)
`;
    
    fs.writeFileSync(coverPageFile, coverContent.trim());
    console.log('Created cover page');
  }
}

/**
 * Ensure required documentation directories exist
 */
function createDirectoryStructure() {
  const directories = [
    path.join(config.sourceDir, 'guides'),
    path.join(config.sourceDir, 'api'),
    path.join(config.sourceDir, 'tutorials'),
    path.join(config.sourceDir, 'development')
  ];
  
  directories.forEach(dir => {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
      
      // Add a placeholder file
      const placeholder = path.join(dir, 'index.md');
      const sectionName = path.basename(dir);
      
      fs.writeFileSync(placeholder, `# ${sectionName.charAt(0).toUpperCase() + sectionName.slice(1)}\n\nDocumentation for this section is coming soon.`);
      
      console.log(`Created directory: ${dir}`);
    }
  });
}

/**
 * Copy static files to output directory
 */
function copyStaticFiles() {
  config.copyStaticFiles.forEach(file => {
    const sourcePath = path.join(config.sourceDir, file);
    const destPath = path.join(config.outputDir, file);
    
    if (fs.existsSync(sourcePath)) {
      // Ensure destination directory exists
      const destDir = path.dirname(destPath);
      if (!fs.existsSync(destDir)) {
        fs.mkdirSync(destDir, { recursive: true });
      }
      
      fs.copyFileSync(sourcePath, destPath);
      console.log(`Copied: ${file}`);
    }
  });
}

/**
 * Main execution function
 */
function buildDocumentation() {
  console.log('🚀 Building ZillyOS documentation...');
  
  // Create directory structure
  createDirectoryStructure();
  
  // Create required files
  createNoJekyllFile();
  createHomePage();
  createCoverPage();
  
  // Generate sidebar
  generateSidebar();
  
  // Copy static files
  copyStaticFiles();
  
  console.log('✅ Documentation build complete!');
}

// Execute the build
buildDocumentation(); 