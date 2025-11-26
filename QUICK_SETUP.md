# ⚡ Quick GitHub Setup (2 Minutes)

## 🎯 Easiest Method: Run the PowerShell Script

I've created a simple script that does everything for you!

### Step 1: Get a GitHub Token (1 minute)

1. **Open**: https://github.com/settings/tokens/new
2. **Name**: `QuaiMiner Release` (or anything)
3. **Expiration**: `90 days` or `No expiration`
4. **Check**: ✅ **`repo`** (Full control of private repositories)
5. **Click**: "Generate token"
6. **Copy the token** (starts with `ghp_...`)

### Step 2: Run the Script (30 seconds)

**In PowerShell:**
```powershell
.\setup-github-release.ps1
```

When prompted, paste your token. The script will:
- ✅ Create the release
- ✅ Update repository description
- ✅ Add topics
- ✅ Done!

## 🔄 Alternative: One-Time Token Setup

If you want to set the token once and reuse it:

```powershell
# Set token (one time)
$env:GITHUB_TOKEN = "ghp_your_token_here"

# Run scripts
bash create-github-release.sh
bash update-repo-description.sh
```

## 📋 What Gets Created

- **Release v2.0.0** with full release notes
- **Repository description** updated
- **Topics** added (quai-network, mining, etc.)

## ✅ That's It!

The script handles everything automatically. Just get a token and run it!

---

**Need the token URL?**: https://github.com/settings/tokens/new

