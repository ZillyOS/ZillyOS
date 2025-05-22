#!/bin/bash

# ZillyOS Branch Validation Script
# Task 1.14: Branch Structure Tests
#
# This script validates the ZillyOS branch structure:
# - Verify branch existence
# - Check branch protection rules
# - Validate version files across branches
# - Test workflow configurations

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

echo -e "${YELLOW}Running ZillyOS Branch Validation...${NC}"

# ==========================================
# 1. Verify branch existence
# ==========================================
echo -e "\n${YELLOW}Verifying branch existence...${NC}"

REQUIRED_BRANCHES=("main" "develop" "staging" "feature/mission-01")
missing_branches=0

# Get all local branches
LOCAL_BRANCHES=$(git branch --list --format="%(refname:short)")

for branch in "${REQUIRED_BRANCHES[@]}"; do
  if ! echo "$LOCAL_BRANCHES" | grep -q "^$branch$"; then
    echo -e "${RED}Missing required branch: $branch${NC}"
    missing_branches=$((missing_branches + 1))
  else
    echo -e "${GREEN}✓ Branch exists: $branch${NC}"
  fi
done

# Get all remote branches
REMOTE_BRANCHES=$(git branch -r --format="%(refname:short)")

for branch in "${REQUIRED_BRANCHES[@]}"; do
  remote_branch="origin/$branch"
  if ! echo "$REMOTE_BRANCHES" | grep -q "^$remote_branch$"; then
    echo -e "${YELLOW}Warning: Remote branch does not exist: $remote_branch${NC}"
  else
    echo -e "${GREEN}✓ Remote branch exists: $remote_branch${NC}"
  fi
done

if [ $missing_branches -gt 0 ]; then
  echo -e "\n${RED}Branch existence check failed: $missing_branches required branches are missing${NC}"
else
  echo -e "\n${GREEN}All required branches exist!${NC}"
fi

# ==========================================
# 2. Check branch protection rules (requires GitHub CLI)
# ==========================================
echo -e "\n${YELLOW}Checking branch protection rules...${NC}"

if command -v gh &> /dev/null; then
  # Check if user is logged in to GitHub
  if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}Warning: Not logged in to GitHub, skipping branch protection check${NC}"
  else
    # Get repo name from remote URL
    REPO_URL=$(git remote get-url origin)
    REPO_NAME=$(echo "$REPO_URL" | sed -n 's/.*github.com[:/]\(.*\)\.git/\1/p')
    
    for branch in "main" "develop"; do
      echo -e "Checking protection for branch: $branch"
      if ! gh api repos/$REPO_NAME/branches/$branch/protection --silent; then
        echo -e "${RED}Branch protection not enabled for $branch${NC}"
      else
        echo -e "${GREEN}✓ Branch protection enabled for $branch${NC}"
      fi
    done
  fi
else
  echo -e "${YELLOW}Warning: GitHub CLI not installed, skipping branch protection check${NC}"
fi

# ==========================================
# 3. Validate version files across branches
# ==========================================
echo -e "\n${YELLOW}Validating version files across branches...${NC}"

# Store current branch
CURRENT_BRANCH=$(git branch --show-current)

version_inconsistencies=0

# Function to get version from a branch
get_version_from_branch() {
  local branch=$1
  
  # Checkout branch
  git checkout $branch > /dev/null 2>&1
  
  # Check for package.json version
  if [ -f "package.json" ]; then
    jq -r '.version' package.json
  elif [ -f "version.txt" ]; then
    cat version.txt
  else
    echo "unknown"
  fi
}

# Check develop branch (baseline for comparison)
if echo "$LOCAL_BRANCHES" | grep -q "^develop$"; then
  DEVELOP_VERSION=$(get_version_from_branch "develop")
  echo "Develop branch version: $DEVELOP_VERSION"
  
  # Check staging branch
  if echo "$LOCAL_BRANCHES" | grep -q "^staging$"; then
    STAGING_VERSION=$(get_version_from_branch "staging")
    echo "Staging branch version: $STAGING_VERSION"
    
    if [ "$STAGING_VERSION" != "$DEVELOP_VERSION" ]; then
      echo -e "${RED}Version mismatch between develop ($DEVELOP_VERSION) and staging ($STAGING_VERSION)${NC}"
      version_inconsistencies=$((version_inconsistencies + 1))
    else
      echo -e "${GREEN}✓ Versions match between develop and staging${NC}"
    fi
  fi
  
  # Check feature branch
  if echo "$LOCAL_BRANCHES" | grep -q "^feature/mission-01$"; then
    FEATURE_VERSION=$(get_version_from_branch "feature/mission-01")
    echo "Feature branch version: $FEATURE_VERSION"
    
    # Feature branch might have a newer version
    if [ "$FEATURE_VERSION" != "$DEVELOP_VERSION" ]; then
      echo -e "${YELLOW}Note: Version difference between develop ($DEVELOP_VERSION) and feature/mission-01 ($FEATURE_VERSION)${NC}"
    else
      echo -e "${GREEN}✓ Versions match between develop and feature/mission-01${NC}"
    fi
  fi
fi

# Return to original branch
git checkout $CURRENT_BRANCH > /dev/null 2>&1

if [ $version_inconsistencies -gt 0 ]; then
  echo -e "\n${RED}Version consistency check failed: $version_inconsistencies inconsistencies found${NC}"
else
  echo -e "\n${GREEN}Version consistency check passed!${NC}"
fi

# ==========================================
# 4. Test workflow configurations
# ==========================================
echo -e "\n${YELLOW}Testing workflow configurations...${NC}"

WORKFLOW_FILES=(
  ".github/workflows/ci.yml"
  ".github/workflows/release.yml"
)

workflow_errors=0

for workflow in "${WORKFLOW_FILES[@]}"; do
  if [ -f "$PROJECT_ROOT/$workflow" ]; then
    # Validate YAML syntax
    if command -v yamllint &> /dev/null; then
      if ! yamllint -d relaxed "$PROJECT_ROOT/$workflow" > /dev/null 2>&1; then
        echo -e "${RED}Invalid YAML syntax in $workflow${NC}"
        workflow_errors=$((workflow_errors + 1))
      else
        echo -e "${GREEN}✓ Valid YAML syntax: $workflow${NC}"
      fi
    else
      echo -e "${YELLOW}Warning: yamllint not installed, skipping YAML syntax check for $workflow${NC}"
    fi
    
    # Check for required sections in workflow files
    if grep -q "name:" "$PROJECT_ROOT/$workflow" && 
       grep -q "on:" "$PROJECT_ROOT/$workflow" && 
       grep -q "jobs:" "$PROJECT_ROOT/$workflow"; then
      echo -e "${GREEN}✓ Workflow file has required sections: $workflow${NC}"
    else
      echo -e "${RED}Workflow file missing required sections: $workflow${NC}"
      workflow_errors=$((workflow_errors + 1))
    fi
  else
    echo -e "${RED}Missing workflow file: $workflow${NC}"
    workflow_errors=$((workflow_errors + 1))
  fi
done

if [ $workflow_errors -gt 0 ]; then
  echo -e "\n${RED}Workflow configuration check failed: $workflow_errors errors found${NC}"
else
  echo -e "\n${GREEN}Workflow configuration check passed!${NC}"
fi

# ==========================================
# Final summary
# ==========================================
echo -e "\n${YELLOW}Branch Validation Summary:${NC}"

total_errors=$((missing_branches + version_inconsistencies + workflow_errors))

if [ $total_errors -gt 0 ]; then
  echo -e "${RED}Validation completed with $total_errors errors${NC}"
  exit 1
else
  echo -e "${GREEN}All branch validation tests passed successfully!${NC}"
  exit 0
fi 