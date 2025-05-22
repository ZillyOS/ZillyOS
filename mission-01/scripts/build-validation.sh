#!/bin/bash

# ZillyOS Build System Validation Script
# Task 1.15: Build System Tests
#
# This script validates the ZillyOS build system:
# - Test build process
# - Verify bundle output
# - Check source map generation
# - Test production builds

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

echo -e "${YELLOW}Running ZillyOS Build System Validation...${NC}"

# ==========================================
# 1. Test build process
# ==========================================
echo -e "\n${YELLOW}Testing build process...${NC}"

# Check if package.json exists and has a build script
if [ -f "$PROJECT_ROOT/package.json" ]; then
  if jq -e '.scripts.build' "$PROJECT_ROOT/package.json" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Build script exists in package.json${NC}"
    
    # Navigate to project root directory to run npm commands
    cd "$PROJECT_ROOT"
    
    # Run the build process
    echo -e "Running build process..."
    
    if npm run build --silent; then
      echo -e "${GREEN}✓ Build process completed successfully${NC}"
    else
      echo -e "${RED}Build process failed${NC}"
      exit 1
    fi
  else
    echo -e "${RED}Build script does not exist in package.json${NC}"
  fi
else
  echo -e "${RED}package.json not found, cannot test build process${NC}"
  exit 1
fi

# ==========================================
# 2. Verify bundle output
# ==========================================
echo -e "\n${YELLOW}Verifying bundle output...${NC}"

# Common build output directories
BUILD_DIRS=(
  "dist"
  "build"
  "out"
)

# Find the build directory
BUILD_DIR=""
for dir in "${BUILD_DIRS[@]}"; do
  if [ -d "$PROJECT_ROOT/$dir" ]; then
    BUILD_DIR="$PROJECT_ROOT/$dir"
    break
  fi
done

if [ -z "$BUILD_DIR" ]; then
  echo -e "${RED}Build output directory not found${NC}"
  exit 1
else
  echo -e "${GREEN}✓ Build output directory found: $BUILD_DIR${NC}"
  
  # Check if the build directory contains files
  if [ "$(ls -A "$BUILD_DIR")" ]; then
    echo -e "${GREEN}✓ Build output directory contains files${NC}"
    
    # Check for JavaScript files
    if find "$BUILD_DIR" -name "*.js" | grep -q .; then
      echo -e "${GREEN}✓ JavaScript files found in build output${NC}"
      
      # Count files
      JS_FILES=$(find "$BUILD_DIR" -name "*.js" | wc -l)
      echo -e "JavaScript files found: $JS_FILES"
    else
      echo -e "${RED}No JavaScript files found in build output${NC}"
    fi
  else
    echo -e "${RED}Build output directory is empty${NC}"
  fi
fi

# ==========================================
# 3. Check source map generation
# ==========================================
echo -e "\n${YELLOW}Checking source map generation...${NC}"

if [ -n "$BUILD_DIR" ]; then
  # Check for source map files
  if find "$BUILD_DIR" -name "*.js.map" | grep -q .; then
    echo -e "${GREEN}✓ Source map files found${NC}"
    
    # Count source map files
    MAP_FILES=$(find "$BUILD_DIR" -name "*.js.map" | wc -l)
    echo -e "Source map files found: $MAP_FILES"
    
    # Check if source maps are valid JSON
    MAP_ERRORS=0
    for map_file in $(find "$BUILD_DIR" -name "*.js.map"); do
      if ! jq . "$map_file" > /dev/null 2>&1; then
        echo -e "${RED}Invalid source map file: $map_file${NC}"
        MAP_ERRORS=$((MAP_ERRORS + 1))
      fi
    done
    
    if [ $MAP_ERRORS -eq 0 ]; then
      echo -e "${GREEN}✓ All source map files are valid JSON${NC}"
    else
      echo -e "${RED}$MAP_ERRORS source map files are invalid${NC}"
    fi
  else
    echo -e "${YELLOW}No source map files found${NC}"
    echo -e "This might be intentional if source maps are disabled for production builds."
  fi
else
  echo -e "${RED}Build output directory not found, cannot check source maps${NC}"
fi

# ==========================================
# 4. Test production builds
# ==========================================
echo -e "\n${YELLOW}Testing production builds...${NC}"

# Check if package.json has a production build script
if [ -f "$PROJECT_ROOT/package.json" ]; then
  PROD_BUILD_SCRIPT=""
  
  # Check common production build script names
  for script in "build:prod" "prod" "production" "build-prod"; do
    if jq -e ".scripts.\"$script\"" "$PROJECT_ROOT/package.json" > /dev/null 2>&1; then
      PROD_BUILD_SCRIPT="$script"
      break
    fi
  done
  
  if [ -n "$PROD_BUILD_SCRIPT" ]; then
    echo -e "${GREEN}✓ Production build script found: $PROD_BUILD_SCRIPT${NC}"
    
    # Navigate to project root directory to run npm commands
    cd "$PROJECT_ROOT"
    
    # Run the production build process
    echo -e "Running production build process..."
    
    if npm run "$PROD_BUILD_SCRIPT" --silent; then
      echo -e "${GREEN}✓ Production build process completed successfully${NC}"
    else
      echo -e "${RED}Production build process failed${NC}"
      exit 1
    fi
    
    # Check for minified JavaScript files
    if [ -n "$BUILD_DIR" ]; then
      # Check for .min.js files or assume all .js files in production build are minified
      MINIFIED_FILES=$(find "$BUILD_DIR" -name "*.min.js" | wc -l)
      if [ $MINIFIED_FILES -gt 0 ]; then
        echo -e "${GREEN}✓ Minified JavaScript files found: $MINIFIED_FILES${NC}"
      else
        # Check if regular JS files are minified (no line breaks or minimal line breaks)
        POTENTIALLY_MINIFIED=0
        for js_file in $(find "$BUILD_DIR" -name "*.js"); do
          # Count lines in file, if very few lines compared to file size, it's likely minified
          FILE_SIZE=$(wc -c < "$js_file")
          LINE_COUNT=$(wc -l < "$js_file")
          
          # Heuristic: if average line length is > 500 characters, consider it minified
          if [ $LINE_COUNT -gt 0 ] && [ $FILE_SIZE -gt 0 ]; then
            AVG_LINE_LENGTH=$((FILE_SIZE / LINE_COUNT))
            if [ $AVG_LINE_LENGTH -gt 500 ]; then
              POTENTIALLY_MINIFIED=$((POTENTIALLY_MINIFIED + 1))
            fi
          fi
        done
        
        if [ $POTENTIALLY_MINIFIED -gt 0 ]; then
          echo -e "${GREEN}✓ Potentially minified JavaScript files found: $POTENTIALLY_MINIFIED${NC}"
        else
          echo -e "${YELLOW}Warning: No minified JavaScript files detected${NC}"
        fi
      fi
    fi
  else
    echo -e "${YELLOW}No specific production build script found, using regular build script${NC}"
  fi
else
  echo -e "${RED}package.json not found, cannot test production builds${NC}"
fi

# ==========================================
# Final summary
# ==========================================
echo -e "\n${YELLOW}Build System Validation Summary:${NC}"

if [ -n "$BUILD_DIR" ] && [ "$(ls -A "$BUILD_DIR")" ]; then
  echo -e "${GREEN}Build system validation completed successfully!${NC}"
  echo -e "Build output directory: $BUILD_DIR"
  echo -e "JavaScript files: $(find "$BUILD_DIR" -name "*.js" | wc -l)"
  if find "$BUILD_DIR" -name "*.js.map" | grep -q .; then
    echo -e "Source map files: $(find "$BUILD_DIR" -name "*.js.map" | wc -l)"
  fi
  exit 0
else
  echo -e "${RED}Build system validation failed!${NC}"
  exit 1
fi 