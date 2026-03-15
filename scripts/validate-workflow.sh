#!/bin/bash

# Validate workflow configuration
# Usage: ./scripts/validate-workflow.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

CONFIG_FILE="workflow-config.json"
ERRORS=0

echo "🔍 Validating workflow configuration..."
echo ""

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}❌ Config file not found: $CONFIG_FILE${NC}"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠️  Warning: jq not installed. Installing...${NC}"
    # Try to install jq
    if command -v apt-get &> /dev/null; then
        sudo apt-get update &> /dev/null && sudo apt-get install -y jq &> /dev/null
    elif command -v brew &> /dev/null; then
        brew install jq &> /dev/null
    else
        echo -e "${RED}❌ Please install jq manually${NC}"
        exit 1
    fi
fi

# Validate JSON syntax
echo "1️⃣  Checking JSON syntax..."
if jq empty "$CONFIG_FILE" 2>/dev/null; then
    echo -e "${GREEN}✅ Valid JSON${NC}"
else
    echo -e "${RED}❌ Invalid JSON${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check required fields
echo ""
echo "2️⃣  Checking required fields..."

REQUIRED_FIELDS=(
    "project.name"
    "project.type"
    "project.repository"
    "workflow.template"
)

for field in "${REQUIRED_FIELDS[@]}"; do
    value=$(jq -r ".$field" "$CONFIG_FILE")
    if [ -z "$value" ] || [ "$value" == "null" ]; then
        echo -e "${RED}❌ Missing: $field${NC}"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "${GREEN}✅ $field: $value${NC}"
    fi
done

# Check if template file exists
echo ""
echo "3️⃣  Checking template file..."
TEMPLATE=$(jq -r '.workflow.template' "$CONFIG_FILE")
TEMPLATE_PATH="templates/$TEMPLATE"

if [ -f "$TEMPLATE_PATH" ]; then
    echo -e "${GREEN}✅ Template exists: $TEMPLATE_PATH${NC}"
else
    echo -e "${RED}❌ Template not found: $TEMPLATE_PATH${NC}"
    echo "Available templates:"
    ls -1 templates/ | sed 's/^/   - /'
    ERRORS=$((ERRORS + 1))
fi

# Validate repository format
echo ""
echo "4️⃣  Checking repository format..."
REPO=$(jq -r '.project.repository' "$CONFIG_FILE")
if [[ "$REPO" =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+$ ]]; then
    echo -e "${GREEN}✅ Repository format valid: $REPO${NC}"
else
    echo -e "${RED}❌ Invalid repository format: $REPO${NC}"
    echo "   Expected format: owner/repo"
    ERRORS=$((ERRORS + 1))
fi

# Check project type
echo ""
echo "5️⃣  Checking project type..."
TYPE=$(jq -r '.project.type' "$CONFIG_FILE")
VALID_TYPES=("node" "python" "docker" "base")

if [[ " ${VALID_TYPES[@]} " =~ " ${TYPE} " ]]; then
    echo -e "${GREEN}✅ Valid project type: $TYPE${NC}"
else
    echo -e "${RED}❌ Invalid project type: $TYPE${NC}"
    echo "   Valid types: ${VALID_TYPES[*]}"
    ERRORS=$((ERRORS + 1))
fi

# Check SSH connection (optional)
echo ""
echo "6️⃣  Checking SSH connection (optional)..."
SSH_HOST=$(jq -r '.runner.host' "$CONFIG_FILE")
if [ -n "$SSH_HOST" ] && [ "$SSH_HOST" != "null" ]; then
    if timeout 5 ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$SSH_HOST" echo "OK" 2>/dev/null; then
        echo -e "${GREEN}✅ SSH connection to $SSH_HOST successful${NC}"
    else
        echo -e "${YELLOW}⚠️  SSH connection to $SSH_HOST failed (this is OK if server is not yet set up)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  No SSH host configured${NC}"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Import template into n8n: templates/$TEMPLATE"
    echo "  2. Configure webhook URL in n8n"
    echo "  3. Update workflow-config.json with webhook URL"
    echo "  4. Run: ./scripts/setup-webhook.sh"
    exit 0
else
    echo -e "${RED}❌ $ERRORS error(s) found${NC}"
    echo "Please fix the issues above."
    exit 1
fi
