#!/bin/bash

# Script to update GitHub repository description using GitHub API
# Requires GITHUB_TOKEN environment variable

set -e

REPO="thecrackofdan/QuaiMiner-CORE-OS"
DESCRIPTION="Complete mining operating system for Quai Network. Multi-GPU, multi-rig support with automatic detection, driver management, and GPU optimization. Supports all ProgPoW-capable GPUs (AMD & NVIDIA)."
TOPICS="quai-network,mining,gpu-mining,progpow,quaiminer-core-os,solo-mining,amd-gpu,nvidia-gpu"

# Check for GitHub token
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ GITHUB_TOKEN environment variable not set"
    echo ""
    echo "To update repository, you need a GitHub Personal Access Token:"
    echo "1. Go to: https://github.com/settings/tokens"
    echo "2. Generate new token (classic)"
    echo "3. Select scope: 'repo' (full control of private repositories)"
    echo "4. Copy the token"
    echo "5. Run: export GITHUB_TOKEN=your_token_here"
    echo "6. Then run this script again"
    exit 1
fi

# Update description
echo "📝 Updating repository description..."

RESPONSE=$(curl -s -w "\n%{http_code}" -X PATCH \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO" \
  -d "{
    \"description\": \"$DESCRIPTION\"
  }")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Description updated successfully!"
else
    echo "❌ Failed to update description"
    echo "HTTP Code: $HTTP_CODE"
    echo "Response: $BODY"
    exit 1
fi

# Update topics
echo "🏷️  Updating repository topics..."

RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.mercy-preview+json" \
  "https://api.github.com/repos/$REPO/topics" \
  -d "{
    \"names\": [$(echo "$TOPICS" | tr ',' '\n' | sed 's/^/"/;s/$/"/' | tr '\n' ',' | sed 's/,$//')]
  }")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Topics updated successfully!"
else
    echo "⚠️  Failed to update topics (may need different API version)"
    echo "HTTP Code: $HTTP_CODE"
fi

echo ""
echo "✅ Repository updated!"
echo "🔗 View at: https://github.com/$REPO"

