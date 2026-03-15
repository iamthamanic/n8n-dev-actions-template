#!/bin/bash

# Setup GitHub Webhook for n8n CI
# Usage: ./setup-webhook.sh [optional: webhook-url]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Load config
CONFIG_FILE="workflow-config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Error: $CONFIG_FILE not found${NC}"
    echo "Run this script from the repository root"
    exit 1
fi

# Parse config
REPO=$(jq -r '.project.repository' "$CONFIG_FILE")
WEBHOOK_URL=$(jq -r '.workflow.webhook.url' "$CONFIG_FILE")

# Override with argument if provided
if [ -n "$1" ]; then
    WEBHOOK_URL="$1"
fi

if [ -z "$WEBHOOK_URL" ] || [ "$WEBHOOK_URL" == "null" ]; then
    echo -e "${RED}Error: Webhook URL not configured${NC}"
    echo "Please set workflow.webhook.url in $CONFIG_FILE"
    echo "Or provide as argument: ./setup-webhook.sh https://..."
    exit 1
fi

echo -e "${YELLOW}Setting up GitHub webhook...${NC}"
echo "Repository: $REPO"
echo "Webhook URL: $WEBHOOK_URL"

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) not installed${NC}"
    echo "Install from: https://cli.github.com/"
    exit 1
fi

# Check authentication
if ! gh auth status &> /dev/null; then
    echo -e "${RED}Error: Not authenticated with GitHub${NC}"
    echo "Run: gh auth login"
    exit 1
fi

# Create webhook
gh api "repos/$REPO/hooks" \
    --method POST \
    --field "config[url]=$WEBHOOK_URL" \
    --field "config[content_type]=json" \
    --field "events[]=push" \
    --field "events[]=pull_request" \
    --field "active=true" \
    --silent

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Webhook created successfully!${NC}"
    echo ""
    echo "Events: push, pull_request"
    echo "Content-Type: application/json"
    echo ""
    echo "To verify:"
    echo "  gh api repos/$REPO/hooks"
else
    echo -e "${RED}❌ Failed to create webhook${NC}"
    echo "Check if you have admin access to the repository"
    exit 1
fi
