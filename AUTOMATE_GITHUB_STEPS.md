# Automate GitHub Steps with API

I can automate the GitHub steps using the GitHub API, but it requires a **GitHub Personal Access Token**.

## 🔑 Get a GitHub Token

1. Go to: https://github.com/settings/tokens
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Give it a name: `QuaiMiner CORE OS Release`
4. Select scope: **`repo`** (full control of private repositories)
5. Click **"Generate token"**
6. **Copy the token** (you won't see it again!)

## 🚀 Run the Automation Scripts

### Option 1: Using the Scripts (Linux/Mac/Git Bash)

```bash
# Set your token
export GITHUB_TOKEN=your_token_here

# Create release
bash create-github-release.sh

# Update repository description
bash update-repo-description.sh
```

### Option 2: Manual API Calls

If you prefer to run the commands directly:

```bash
# Set token
export GITHUB_TOKEN=your_token_here

# Create release
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/thecrackofdan/QuaiMiner-CORE-OS/releases \
  -d '{
    "tag_name": "v2.0.0",
    "name": "QuaiMiner CORE OS v2.0.0 - Complete Mining OS Release",
    "body": "See RELEASE_NOTES.md for details",
    "draft": false,
    "prerelease": false
  }'

# Update description
curl -X PATCH \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/thecrackofdan/QuaiMiner-CORE-OS \
  -d '{
    "description": "Complete mining operating system for Quai Network. Multi-GPU, multi-rig support with automatic detection, driver management, and GPU optimization. Supports all ProgPoW-capable GPUs (AMD & NVIDIA)."
  }'
```

## ⚠️ Why Browser Automation Doesn't Work

GitHub requires authentication for:
- Creating releases
- Updating repository settings
- Modifying repository metadata

Browser automation tools can navigate to pages, but **cannot authenticate** or interact with authenticated forms. The GitHub API is the proper way to automate these tasks.

## ✅ Alternative: Quick Manual Steps

If you prefer not to use the API, the manual steps only take 2-3 minutes:

1. **Create Release**: https://github.com/thecrackofdan/QuaiMiner-CORE-OS/releases/new
2. **Update Description**: https://github.com/thecrackofdan/QuaiMiner-CORE-OS/settings

See `MANUAL_GITHUB_STEPS.md` for detailed instructions.

