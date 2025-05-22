#!/bin/bash

# Colors for better output formatting
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Output directory for reports
REPORT_DIR="./reports/dependencies"
mkdir -p $REPORT_DIR

# Timestamp for report files
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Function to print section headers
print_header() {
  echo -e "\n${BLUE}========== $1 ==========${NC}\n"
}

# Function to check if a command is available
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if required tools are installed
check_requirements() {
  print_header "Checking Requirements"
  
  local all_good=true
  
  if ! command_exists npm; then
    echo -e "${RED}npm is not installed. Please install Node.js and npm.${NC}"
    all_good=false
  fi
  
  if ! command_exists jq; then
    echo -e "${YELLOW}jq is not installed. Some reporting features will be limited.${NC}"
    echo "Consider installing jq for better JSON parsing: 'sudo apt install jq' or equivalent"
  fi
  
  if [[ "$all_good" == "false" ]]; then
    echo -e "${RED}Please install the required tools and try again.${NC}"
    exit 1
  fi
}

# Audit dependencies for security vulnerabilities
audit_security() {
  print_header "Security Audit"
  
  echo "Running npm audit..."
  npm audit --json > "$REPORT_DIR/security_audit_$TIMESTAMP.json"
  
  if command_exists jq; then
    # Parse and display summary with jq
    echo -e "\n${BLUE}Security Vulnerability Summary:${NC}"
    
    local total_vulns=$(jq '.metadata.vulnerabilities.total' "$REPORT_DIR/security_audit_$TIMESTAMP.json")
    local critical=$(jq '.metadata.vulnerabilities.critical' "$REPORT_DIR/security_audit_$TIMESTAMP.json")
    local high=$(jq '.metadata.vulnerabilities.high' "$REPORT_DIR/security_audit_$TIMESTAMP.json")
    local moderate=$(jq '.metadata.vulnerabilities.moderate' "$REPORT_DIR/security_audit_$TIMESTAMP.json")
    local low=$(jq '.metadata.vulnerabilities.low' "$REPORT_DIR/security_audit_$TIMESTAMP.json")
    
    if [[ $total_vulns -eq 0 ]]; then
      echo -e "${GREEN}No security vulnerabilities found.${NC}"
    else
      echo -e "${RED}Total vulnerabilities: $total_vulns${NC}"
      echo -e "${RED}Critical: $critical${NC}"
      echo -e "${RED}High: $high${NC}"
      echo -e "${YELLOW}Moderate: $moderate${NC}"
      echo -e "${YELLOW}Low: $low${NC}"
    fi
  else
    # Fallback to npm audit standard output
    npm audit
  fi
  
  echo -e "\nSecurity audit report saved to: $REPORT_DIR/security_audit_$TIMESTAMP.json"
}

# Check for outdated dependencies
check_outdated() {
  print_header "Outdated Dependencies"
  
  echo "Checking for outdated packages..."
  npm outdated --json > "$REPORT_DIR/outdated_$TIMESTAMP.json"
  
  if command_exists jq && [[ -s "$REPORT_DIR/outdated_$TIMESTAMP.json" ]]; then
    # Count number of outdated packages
    local outdated_count=$(jq 'length' "$REPORT_DIR/outdated_$TIMESTAMP.json")
    
    if [[ $outdated_count -eq 0 ]]; then
      echo -e "${GREEN}All packages are up to date.${NC}"
    else
      echo -e "${YELLOW}Found $outdated_count outdated packages:${NC}"
      
      # Format and display outdated packages
      jq -r 'to_entries | .[] | "\(.key): current \(.value.current) -> latest \(.value.latest)"' \
        "$REPORT_DIR/outdated_$TIMESTAMP.json" | while read -r line; do
        echo -e "${YELLOW}► ${NC}$line"
      done
    fi
  else
    # Fallback to npm outdated standard output
    npm outdated
  fi
  
  echo -e "\nOutdated packages report saved to: $REPORT_DIR/outdated_$TIMESTAMP.json"
}

# Analyze dependency tree
analyze_dependency_tree() {
  print_header "Dependency Tree Analysis"
  
  echo "Generating dependency tree..."
  npm ls --json > "$REPORT_DIR/dependency_tree_$TIMESTAMP.json"
  
  # Generate human-readable tree
  npm ls --all > "$REPORT_DIR/dependency_tree_readable_$TIMESTAMP.txt"
  
  if command_exists jq; then
    # Count direct dependencies
    local direct_deps=$(jq '.dependencies | length' "$REPORT_DIR/dependency_tree_$TIMESTAMP.json")
    echo -e "Direct dependencies: ${BLUE}$direct_deps${NC}"
    
    # Try to estimate total dependencies
    local total_deps=$(grep -c "node_modules" "$REPORT_DIR/dependency_tree_readable_$TIMESTAMP.txt")
    echo -e "Total dependencies (estimate): ${BLUE}$total_deps${NC}"
  fi
  
  echo -e "\nDependency tree reports saved to:"
  echo -e "$REPORT_DIR/dependency_tree_$TIMESTAMP.json"
  echo -e "$REPORT_DIR/dependency_tree_readable_$TIMESTAMP.txt"
}

# Generate comprehensive report
generate_report() {
  print_header "Generating Comprehensive Report"
  
  local report_file="$REPORT_DIR/dependency_report_$TIMESTAMP.md"
  
  # Create report header
  cat << EOF > "$report_file"
# ZillyOS Dependency Report
Generated: $(date)

## Summary

EOF
  
  # Add security section
  if command_exists jq && [[ -f "$REPORT_DIR/security_audit_$TIMESTAMP.json" ]]; then
    local total_vulns=$(jq '.metadata.vulnerabilities.total' "$REPORT_DIR/security_audit_$TIMESTAMP.json")
    local critical=$(jq '.metadata.vulnerabilities.critical' "$REPORT_DIR/security_audit_$TIMESTAMP.json")
    local high=$(jq '.metadata.vulnerabilities.high' "$REPORT_DIR/security_audit_$TIMESTAMP.json")
    
    cat << EOF >> "$report_file"
### Security
- Total vulnerabilities: $total_vulns
- Critical: $critical
- High: $high

EOF
  fi
  
  # Add outdated section
  if command_exists jq && [[ -f "$REPORT_DIR/outdated_$TIMESTAMP.json" ]]; then
    local outdated_count=$(jq 'length' "$REPORT_DIR/outdated_$TIMESTAMP.json")
    
    cat << EOF >> "$report_file"
### Outdated Packages
- Outdated packages: $outdated_count

EOF
    
    if [[ $outdated_count -gt 0 ]]; then
      cat << EOF >> "$report_file"
| Package | Current | Wanted | Latest |
|---------|---------|--------|--------|
EOF
      
      jq -r 'to_entries | .[] | "| \(.key) | \(.value.current) | \(.value.wanted) | \(.value.latest) |"' \
        "$REPORT_DIR/outdated_$TIMESTAMP.json" >> "$report_file"
      
      cat << EOF >> "$report_file"

EOF
    fi
  fi
  
  # Add dependency tree section
  if command_exists jq && [[ -f "$REPORT_DIR/dependency_tree_$TIMESTAMP.json" ]]; then
    local direct_deps=$(jq '.dependencies | length' "$REPORT_DIR/dependency_tree_$TIMESTAMP.json")
    local total_deps=$(grep -c "node_modules" "$REPORT_DIR/dependency_tree_readable_$TIMESTAMP.txt")
    
    cat << EOF >> "$report_file"
### Dependency Tree
- Direct dependencies: $direct_deps
- Total dependencies (estimate): $total_deps

EOF
  fi
  
  # Add recommendations section
  cat << EOF >> "$report_file"
## Recommendations

EOF
  
  # Add security recommendations
  if [[ -f "$REPORT_DIR/security_audit_$TIMESTAMP.json" ]]; then
    if command_exists jq; then
      local critical=$(jq '.metadata.vulnerabilities.critical' "$REPORT_DIR/security_audit_$TIMESTAMP.json")
      local high=$(jq '.metadata.vulnerabilities.high' "$REPORT_DIR/security_audit_$TIMESTAMP.json")
      
      if [[ $critical -gt 0 || $high -gt 0 ]]; then
        cat << EOF >> "$report_file"
### Security Actions
- **URGENT**: Address the critical and high severity vulnerabilities as soon as possible
- Run \`npm audit fix\` to automatically fix issues where possible
- For remaining issues, evaluate each package for update or replacement

EOF
      fi
    fi
  fi
  
  # Add outdated recommendations
  if [[ -f "$REPORT_DIR/outdated_$TIMESTAMP.json" ]]; then
    if command_exists jq; then
      local outdated_count=$(jq 'length' "$REPORT_DIR/outdated_$TIMESTAMP.json")
      
      if [[ $outdated_count -gt 0 ]]; then
        cat << EOF >> "$report_file"
### Update Strategy
- Update packages with security patches immediately
- Schedule updates for minor version changes
- Test thoroughly before updating major versions
- Consider using Dependabot for automated updates

EOF
      fi
    fi
  fi
  
  echo -e "Comprehensive report generated: ${GREEN}$report_file${NC}"
}

# Main execution
main() {
  check_requirements
  audit_security
  check_outdated
  analyze_dependency_tree
  generate_report
  
  print_header "Dependency Audit Complete"
  echo -e "${GREEN}All reports have been saved to: $REPORT_DIR${NC}"
}

# Run the main function
main 