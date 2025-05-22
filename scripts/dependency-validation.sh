#!/bin/bash

# ZillyOS Dependency Validation Script
# Task 1.16: Dependency Validation
#
# This script validates the ZillyOS dependencies:
# - Check for security vulnerabilities
# - Verify dependency compatibility
# - Test peer dependency resolution
# - Validate workspace configuration

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

echo -e "${YELLOW}Running ZillyOS Dependency Validation...${NC}"

# ==========================================
# 1. Check for security vulnerabilities
# ==========================================
echo -e "\n${YELLOW}Checking for security vulnerabilities...${NC}"

cd "$PROJECT_ROOT"

# Run npm audit if package.json exists
if [ -f "package.json" ]; then
  echo -e "Running npm audit..."
  
  # Capture the output and error code
  AUDIT_OUTPUT=$(npm audit --json 2>/dev/null || true)
  AUDIT_RESULT=$?
  
  # Parse the JSON output to get vulnerability counts
  if [ -n "$AUDIT_OUTPUT" ]; then
    # Check if output is valid JSON
    if echo "$AUDIT_OUTPUT" | jq . >/dev/null 2>&1; then
      # Get vulnerability counts by severity
      LOW=$(echo "$AUDIT_OUTPUT" | jq '.metadata.vulnerabilities.low // 0')
      MODERATE=$(echo "$AUDIT_OUTPUT" | jq '.metadata.vulnerabilities.moderate // 0')
      HIGH=$(echo "$AUDIT_OUTPUT" | jq '.metadata.vulnerabilities.high // 0')
      CRITICAL=$(echo "$AUDIT_OUTPUT" | jq '.metadata.vulnerabilities.critical // 0')
      
      TOTAL=$((LOW + MODERATE + HIGH + CRITICAL))
      
      if [ $TOTAL -eq 0 ]; then
        echo -e "${GREEN}✓ No vulnerabilities found${NC}"
      else
        echo -e "${RED}Vulnerabilities found:${NC}"
        echo -e "  Critical: $CRITICAL"
        echo -e "  High: $HIGH"
        echo -e "  Moderate: $MODERATE"
        echo -e "  Low: $LOW"
        echo -e "${RED}Total: $TOTAL vulnerabilities${NC}"
      fi
    else
      echo -e "${YELLOW}Warning: Unable to parse npm audit output${NC}"
    fi
  else
    echo -e "${YELLOW}Warning: npm audit did not produce any output${NC}"
  fi
else
  echo -e "${RED}package.json not found, cannot check for vulnerabilities${NC}"
fi

# ==========================================
# 2. Verify dependency compatibility
# ==========================================
echo -e "\n${YELLOW}Verifying dependency compatibility...${NC}"

# Check for Node.js engines compatibility
if [ -f "package.json" ]; then
  # Get Node.js engines requirement
  NODE_ENGINES=$(jq -r '.engines.node // "not specified"' package.json)
  
  if [ "$NODE_ENGINES" != "not specified" ]; then
    echo -e "Node.js version requirement: $NODE_ENGINES"
    
    # Get current Node.js version
    CURRENT_NODE_VERSION=$(node -v)
    echo -e "Current Node.js version: $CURRENT_NODE_VERSION"
    
    # Simple version check using semver (if available)
    if command -v npx >/dev/null 2>&1; then
      if npx semver "$CURRENT_NODE_VERSION" --range "$NODE_ENGINES" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Current Node.js version is compatible${NC}"
      else
        echo -e "${RED}Current Node.js version is not compatible with required range: $NODE_ENGINES${NC}"
      fi
    else
      echo -e "${YELLOW}Warning: semver not available, skipping version compatibility check${NC}"
    fi
  else
    echo -e "${YELLOW}No Node.js version requirement specified in package.json${NC}"
  fi
  
  # Check dependencies for potential conflicts
  DEPS_JSON=$(jq -r '.dependencies // {}' package.json)
  DEV_DEPS_JSON=$(jq -r '.devDependencies // {}' package.json)
  
  # Check for duplicate dependencies (same package in both deps and devDeps)
  DEPS_KEYS=$(echo "$DEPS_JSON" | jq -r 'keys[]')
  DEV_DEPS_KEYS=$(echo "$DEV_DEPS_JSON" | jq -r 'keys[]')
  
  DUPLICATE_DEPS=0
  for dep in $DEPS_KEYS; do
    if echo "$DEV_DEPS_KEYS" | grep -q "^$dep$"; then
      echo -e "${YELLOW}Warning: Duplicate dependency found in both dependencies and devDependencies: $dep${NC}"
      DUPLICATE_DEPS=$((DUPLICATE_DEPS + 1))
    fi
  done
  
  if [ $DUPLICATE_DEPS -eq 0 ]; then
    echo -e "${GREEN}✓ No duplicate dependencies found${NC}"
  else
    echo -e "${YELLOW}Found $DUPLICATE_DEPS duplicate dependencies${NC}"
  fi
else
  echo -e "${RED}package.json not found, cannot verify dependency compatibility${NC}"
fi

# ==========================================
# 3. Test peer dependency resolution
# ==========================================
echo -e "\n${YELLOW}Testing peer dependency resolution...${NC}"

if [ -f "package.json" ]; then
  # Check if npm list shows any peer dependency issues
  echo -e "Running npm list to check for peer dependency issues..."
  
  # Run npm list and check for unmet peer dependency warnings
  NPM_LIST_OUTPUT=$(npm list --json 2>/dev/null || true)
  
  # Check if there are any peer dependency warnings
  if npm list 2>&1 | grep -i "peer dep missing" >/dev/null; then
    echo -e "${YELLOW}Warning: Unmet peer dependencies found${NC}"
    
    # Extract and display peer dependency warnings
    npm list 2>&1 | grep -i "peer dep missing" | while read -r line; do
      echo -e "  ${YELLOW}$line${NC}"
    done
  else
    echo -e "${GREEN}✓ All peer dependencies are properly resolved${NC}"
  fi
  
  # Check for optional peer dependencies (npm 7+ feature)
  PEER_DEPS=$(jq -r '.peerDependencies // {}' package.json)
  PEER_DEPS_OPTIONAL=$(jq -r '.peerDependenciesMeta // {}' package.json)
  
  if [ "$(echo "$PEER_DEPS" | jq 'keys | length')" -gt 0 ]; then
    echo -e "Peer dependencies found: $(echo "$PEER_DEPS" | jq -r 'keys | join(", ")')"
    
    if [ "$(echo "$PEER_DEPS_OPTIONAL" | jq 'keys | length')" -gt 0 ]; then
      echo -e "Optional peer dependencies: $(echo "$PEER_DEPS_OPTIONAL" | jq -r 'keys | join(", ")')"
    fi
  else
    echo -e "${GREEN}✓ No peer dependencies specified${NC}"
  fi
else
  echo -e "${RED}package.json not found, cannot test peer dependency resolution${NC}"
fi

# ==========================================
# 4. Validate workspace configuration
# ==========================================
echo -e "\n${YELLOW}Validating workspace configuration...${NC}"

if [ -f "package.json" ]; then
  # Check for workspaces configuration
  WORKSPACES=$(jq -r '.workspaces // []' package.json)
  
  if [ "$(echo "$WORKSPACES" | jq 'length')" -gt 0 ]; then
    echo -e "Workspaces configuration found: $(echo "$WORKSPACES" | jq -r '. | join(", ")')"
    
    # Check if workspaces actually exist
    MISSING_WORKSPACES=0
    
    # Check if workspaces is an array of strings or an object with packages
    if echo "$WORKSPACES" | jq -e 'type == "array"' >/dev/null 2>&1; then
      for workspace in $(echo "$WORKSPACES" | jq -r '.[]'); do
        # Handle glob patterns by listing matching directories
        for ws_dir in $workspace; do
          if [ ! -d "$ws_dir" ] && [ ! -d "$(dirname "$ws_dir")" ]; then
            echo -e "${YELLOW}Warning: Workspace directory not found: $ws_dir${NC}"
            MISSING_WORKSPACES=$((MISSING_WORKSPACES + 1))
          else
            echo -e "${GREEN}✓ Workspace directory exists: $ws_dir${NC}"
            
            # Check if each workspace has its own package.json
            if [ -d "$ws_dir" ] && [ ! -f "$ws_dir/package.json" ]; then
              echo -e "${YELLOW}Warning: Workspace directory exists but doesn't have package.json: $ws_dir${NC}"
            elif [ -d "$(dirname "$ws_dir")" ]; then
              # For glob patterns, we can't check every possible match
              echo -e "${YELLOW}Glob pattern detected, can't validate all workspace package.json files${NC}"
            fi
          fi
        done
      done
    elif echo "$WORKSPACES" | jq -e '.packages' >/dev/null 2>&1; then
      for workspace in $(echo "$WORKSPACES" | jq -r '.packages[]'); do
        # Handle glob patterns by listing matching directories
        for ws_dir in $workspace; do
          if [ ! -d "$ws_dir" ] && [ ! -d "$(dirname "$ws_dir")" ]; then
            echo -e "${YELLOW}Warning: Workspace directory not found: $ws_dir${NC}"
            MISSING_WORKSPACES=$((MISSING_WORKSPACES + 1))
          else
            echo -e "${GREEN}✓ Workspace directory exists: $ws_dir${NC}"
          fi
        done
      done
    fi
    
    if [ $MISSING_WORKSPACES -eq 0 ]; then
      echo -e "${GREEN}✓ All workspace directories exist${NC}"
    else
      echo -e "${YELLOW}$MISSING_WORKSPACES workspace directories are missing${NC}"
    fi
  else
    echo -e "${YELLOW}No workspaces configuration found in package.json${NC}"
  fi
  
  # Check if there's a lerna.json for Lerna-based monorepos
  if [ -f "lerna.json" ]; then
    echo -e "${GREEN}✓ Lerna configuration found${NC}"
    
    # Validate lerna.json
    if jq . "lerna.json" >/dev/null 2>&1; then
      echo -e "${GREEN}✓ lerna.json is valid JSON${NC}"
      
      # Check packages configuration
      LERNA_PACKAGES=$(jq -r '.packages // []' lerna.json)
      
      if [ "$(echo "$LERNA_PACKAGES" | jq 'length')" -gt 0 ]; then
        echo -e "Lerna packages: $(echo "$LERNA_PACKAGES" | jq -r '. | join(", ")')"
        
        # Check for version in lerna.json
        LERNA_VERSION=$(jq -r '.version // "not specified"' lerna.json)
        if [ "$LERNA_VERSION" != "not specified" ]; then
          echo -e "Lerna version: $LERNA_VERSION"
        else
          echo -e "${YELLOW}Warning: No version specified in lerna.json${NC}"
        fi
      else
        echo -e "${YELLOW}Warning: No packages specified in lerna.json${NC}"
      fi
    else
      echo -e "${RED}lerna.json is not valid JSON${NC}"
    fi
  fi
else
  echo -e "${RED}package.json not found, cannot validate workspace configuration${NC}"
fi

# ==========================================
# Final summary
# ==========================================
echo -e "\n${YELLOW}Dependency Validation Summary:${NC}"

# Check npm list for problems
cd "$PROJECT_ROOT"
if [ -f "package.json" ]; then
  # Use --prod flag to check only production dependencies
  if npm list --prod --depth=0 2>&1 | grep -i "UNMET DEPENDENCY\|missing:" >/dev/null; then
    echo -e "${RED}Problems found with production dependencies${NC}"
    npm list --prod --depth=0 2>&1 | grep -i "UNMET DEPENDENCY\|missing:"
    exit 1
  else
    echo -e "${GREEN}All production dependencies are properly installed!${NC}"
  fi
  
  echo -e "\nDependency validation completed."
  exit 0
else
  echo -e "${RED}package.json not found, dependency validation incomplete${NC}"
  exit 1
fi 