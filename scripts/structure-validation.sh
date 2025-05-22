#!/bin/bash

# ZillyOS Structure Validation Script
# Task 1.13: Structure Validation Tests
#
# This script validates the ZillyOS project structure:
# - Tests for required files and directories
# - Verifies configuration file formats
# - Checks version consistency
# - Validates package.json structure

# Exit on any error
set -e

# Set text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Navigate to the project root
cd "$(dirname "$0")/.."
PROJECT_ROOT=$(pwd)

echo -e "${YELLOW}Running ZillyOS Structure Validation...${NC}"

# ==========================================
# 1. Check for required files and directories
# ==========================================
echo -e "\n${YELLOW}Checking for required files and directories...${NC}"

REQUIRED_DIRS=(
  "src"
  "docs"
  "scripts"
  "test"
  ".github"
  "build"
  "config"
)

REQUIRED_FILES=(
  "README.md"
  "LICENSE"
  "package.json"
  "tsconfig.json"
  ".eslintrc.json"
  ".prettierrc"
  ".gitignore"
  "jest.config.js"
)

missing_dirs=0
missing_files=0

# Check directories
for dir in "${REQUIRED_DIRS[@]}"; do
  if [ ! -d "$PROJECT_ROOT/$dir" ]; then
    echo -e "${RED}Missing required directory: $dir${NC}"
    missing_dirs=$((missing_dirs + 1))
  else
    echo -e "${GREEN}✓ Directory exists: $dir${NC}"
  fi
done

# Check files
for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$PROJECT_ROOT/$file" ]; then
    echo -e "${RED}Missing required file: $file${NC}"
    missing_files=$((missing_files + 1))
  else
    echo -e "${GREEN}✓ File exists: $file${NC}"
  fi
done

if [ $missing_dirs -gt 0 ] || [ $missing_files -gt 0 ]; then
  echo -e "\n${RED}Structure check failed: $missing_dirs directories and $missing_files files are missing${NC}"
else
  echo -e "\n${GREEN}All required directories and files exist!${NC}"
fi

# ==========================================
# 2. Verify configuration file formats
# ==========================================
echo -e "\n${YELLOW}Verifying configuration file formats...${NC}"

# Check if JSON files are valid
json_files=(
  "package.json"
  "tsconfig.json"
  ".eslintrc.json"
  ".prettierrc"
)

json_errors=0

for json_file in "${json_files[@]}"; do
  if [ -f "$PROJECT_ROOT/$json_file" ]; then
    if ! jq . "$PROJECT_ROOT/$json_file" > /dev/null 2>&1; then
      echo -e "${RED}Invalid JSON format in $json_file${NC}"
      json_errors=$((json_errors + 1))
    else
      echo -e "${GREEN}✓ Valid JSON format: $json_file${NC}"
    fi
  fi
done

# Check if YAML files are valid - basic check
yaml_files=(
  ".github/workflows/ci.yml"
  ".github/workflows/release.yml"
)

yaml_errors=0

for yaml_file in "${yaml_files[@]}"; do
  if [ -f "$PROJECT_ROOT/$yaml_file" ]; then
    # Try a basic structure check for YAML - look for common patterns
    if ! grep -q "^name:" "$PROJECT_ROOT/$yaml_file" || \
       ! grep -q "^on:" "$PROJECT_ROOT/$yaml_file" || \
       ! grep -q "^jobs:" "$PROJECT_ROOT/$yaml_file"; then
      echo -e "${RED}YAML file missing required sections: $yaml_file${NC}"
      yaml_errors=$((yaml_errors + 1))
    else
      echo -e "${GREEN}✓ YAML file has required sections: $yaml_file${NC}"
    fi
  fi
done

if [ $json_errors -gt 0 ] || [ $yaml_errors -gt 0 ]; then
  echo -e "\n${RED}Configuration format check failed: $json_errors JSON files and $yaml_errors YAML files have invalid format${NC}"
else
  echo -e "\n${GREEN}All configuration files have valid format!${NC}"
fi

# ==========================================
# 3. Check version consistency
# ==========================================
echo -e "\n${YELLOW}Checking version consistency...${NC}"

# Extract version from package.json
if [ -f "$PROJECT_ROOT/package.json" ]; then
  PACKAGE_VERSION=$(jq -r '.version' "$PROJECT_ROOT/package.json")
  echo "Version in package.json: $PACKAGE_VERSION"
  
  # Check if version is mentioned in README.md
  if [ -f "$PROJECT_ROOT/README.md" ]; then
    if grep -q "$PACKAGE_VERSION" "$PROJECT_ROOT/README.md"; then
      echo -e "${GREEN}✓ README.md contains the current version ($PACKAGE_VERSION)${NC}"
    else
      echo -e "${RED}README.md does not contain the current version ($PACKAGE_VERSION)${NC}"
    fi
  fi
  
  # Check if version.txt exists and contains the same version
  if [ -f "$PROJECT_ROOT/version.txt" ]; then
    VERSION_TXT=$(cat "$PROJECT_ROOT/version.txt")
    if [ "$VERSION_TXT" = "$PACKAGE_VERSION" ]; then
      echo -e "${GREEN}✓ version.txt matches package.json version ($PACKAGE_VERSION)${NC}"
    else
      echo -e "${RED}version.txt ($VERSION_TXT) does not match package.json version ($PACKAGE_VERSION)${NC}"
    fi
  fi
  
  # Check if CHANGELOG.md mentions the current version
  if [ -f "$PROJECT_ROOT/CHANGELOG.md" ]; then
    if grep -q "\[$PACKAGE_VERSION\]" "$PROJECT_ROOT/CHANGELOG.md"; then
      echo -e "${GREEN}✓ CHANGELOG.md contains the current version ($PACKAGE_VERSION)${NC}"
    else
      echo -e "${RED}CHANGELOG.md does not contain the current version ($PACKAGE_VERSION)${NC}"
    fi
  fi
else
  echo -e "${RED}Cannot check version consistency: package.json not found${NC}"
fi

# ==========================================
# 4. Validate package.json structure
# ==========================================
echo -e "\n${YELLOW}Validating package.json structure...${NC}"

if [ -f "$PROJECT_ROOT/package.json" ]; then
  # Check for required fields
  required_fields=("name" "version" "description" "main" "scripts" "author" "license" "dependencies" "devDependencies")
  missing_fields=0
  
  for field in "${required_fields[@]}"; do
    if ! jq -e ".$field" "$PROJECT_ROOT/package.json" > /dev/null 2>&1; then
      echo -e "${RED}Missing required field in package.json: $field${NC}"
      missing_fields=$((missing_fields + 1))
    else
      echo -e "${GREEN}✓ package.json contains required field: $field${NC}"
    fi
  done
  
  # Check for scripts
  required_scripts=("build" "test" "lint" "start")
  missing_scripts=0
  
  for script in "${required_scripts[@]}"; do
    if ! jq -e ".scripts.$script" "$PROJECT_ROOT/package.json" > /dev/null 2>&1; then
      echo -e "${RED}Missing required script in package.json: $script${NC}"
      missing_scripts=$((missing_scripts + 1))
    else
      echo -e "${GREEN}✓ package.json contains required script: $script${NC}"
    fi
  done
  
  if [ $missing_fields -gt 0 ] || [ $missing_scripts -gt 0 ]; then
    echo -e "\n${RED}package.json validation failed: $missing_fields required fields and $missing_scripts required scripts are missing${NC}"
  else
    echo -e "\n${GREEN}package.json structure is valid!${NC}"
  fi
else
  echo -e "${RED}Cannot validate package.json structure: file not found${NC}"
fi

# ==========================================
# Final summary
# ==========================================
echo -e "\n${YELLOW}Structure Validation Summary:${NC}"

total_errors=$((missing_dirs + missing_files + json_errors + yaml_errors))

# Add version consistency errors
version_errors=0
if [ -f "$PROJECT_ROOT/package.json" ]; then
  if [ -f "$PROJECT_ROOT/README.md" ] && ! grep -q "$PACKAGE_VERSION" "$PROJECT_ROOT/README.md"; then
    version_errors=$((version_errors + 1))
  fi
  if [ -f "$PROJECT_ROOT/version.txt" ] && [ "$VERSION_TXT" != "$PACKAGE_VERSION" ]; then
    version_errors=$((version_errors + 1))
  fi
  if [ -f "$PROJECT_ROOT/CHANGELOG.md" ] && ! grep -q "\[$PACKAGE_VERSION\]" "$PROJECT_ROOT/CHANGELOG.md"; then
    version_errors=$((version_errors + 1))
  fi
  total_errors=$((total_errors + version_errors))
fi

# Add package.json structure errors
if [ -f "$PROJECT_ROOT/package.json" ]; then
  total_errors=$((total_errors + missing_fields + missing_scripts))
fi

if [ $total_errors -gt 0 ]; then
  echo -e "${RED}Validation completed with $total_errors errors${NC}"
  exit 1
else
  echo -e "${GREEN}All structure validation tests passed successfully!${NC}"
  exit 0
fi 