# ZillyOS Scripts

This directory contains scripts for building, testing, validating, and managing the ZillyOS project.

## Validation Scripts

### structure-validation.sh

Comprehensive validation of the ZillyOS project structure:
- Tests for required files and directories
- Verifies configuration file formats
- Checks version consistency across project files
- Validates package.json structure and fields

**Usage:**
```bash
./scripts/structure-validation.sh
```

### branch-validation.sh

Validates the ZillyOS branch structure:
- Verifies branch existence (local and remote)
- Checks branch protection rules (requires GitHub CLI)
- Validates version files across branches
- Tests workflow configurations

**Usage:**
```bash
./scripts/branch-validation.sh
```

### build-validation.sh

Tests the ZillyOS build system:
- Tests build process execution
- Verifies bundle output files
- Checks source map generation
- Tests production builds and minification

**Usage:**
```bash
./scripts/build-validation.sh
```

### dependency-validation.sh

Validates the ZillyOS dependencies:
- Checks for security vulnerabilities
- Verifies dependency compatibility
- Tests peer dependency resolution
- Validates workspace configuration

**Usage:**
```bash
./scripts/dependency-validation.sh
```

## Development Scripts

### build-docs.js

Builds the project documentation using TypeDoc:
- Generates API documentation
- Creates markdown files for project structure
- Configures custom themes and layouts

**Usage:**
```bash
node scripts/build-docs.js
```

### audit-dependencies.sh

Performs a detailed security audit of project dependencies:
- Checks for known vulnerabilities
- Recommends updates or replacements
- Generates security reports

**Usage:**
```bash
./scripts/audit-dependencies.sh
```

### dev-server.js

Runs a development server with hot reloading:
- Serves the application for local development
- Provides real-time updates when files change
- Includes development-specific configurations

**Usage:**
```bash
node scripts/dev-server.js
```

### setup-dev.sh

Sets up the development environment:
- Installs required dependencies
- Configures development tools
- Prepares the workspace for development

**Usage:**
```bash
./scripts/setup-dev.sh
```

## Integration with CI/CD

These scripts are designed to be used in GitHub Actions workflows to ensure consistency across all branches and environments. They can also be run locally to validate changes before pushing to the repository.

## Automated Execution

For convenience, you may want to add these scripts to your PATH or create shell aliases. For example:

```bash
# Add to .bashrc or .zshrc
alias validate-structure='cd /path/to/zillyzoo && ./scripts/structure-validation.sh'
alias validate-dependencies='cd /path/to/zillyzoo && ./scripts/dependency-validation.sh'
``` 