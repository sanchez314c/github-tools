# 🚀 GitHub Repository Manager

A unified tool for managing all GitHub repositories from a single interface.

## 🎯 Purpose

This tool solves the common repository management headaches:
- **Bulk status checking** across all repositories
- **Automated committing** of changes across multiple projects
- **Batch pushing** to GitHub with proper authentication
- **Repository tracking fixes** for sync issues
- **Beautiful, colored output** with clear status indicators

## ⚡ Quick Start

```bash
# Clone your repositories (if not already done)
git clone git@github.com:sanchez314c/github-tools.git
cd github-tools

# Make executable and run
chmod +x gh_manager.sh
./gh_manager.sh quick    # Quick status check
./gh_manager.sh status   # Detailed status report
./gh_manager.sh commit   # Commit all changes
./gh_manager.sh push     # Push all repositories
./gh_manager.sh fix       # Fix repository tracking
```

## 📋 Commands Reference

### **Status Commands:**
- `./gh_manager.sh quick` - Fast overview of all repository states
- `./gh_manager.sh status` - Detailed table view with branch, changes, tracking info

### **Bulk Operations:**
- `./gh_manager.sh commit [message]` - Commit changes across all repositories
- `./gh_manager.sh push` - Push all repositories to GitHub
- `./gh_manager.sh fix` - Fix repository tracking issues

### **Authentication Setup:**
- Requires `GH_TOKEN` environment variable (automatically uses your token from .zshrc)
- Uses HTTPS URLs with token authentication for maximum compatibility
- Falls back to username `sanchez314c` if token not found

## 🏗️ Repository Discovery

The script automatically discovers all git repositories in the current directory:
- No hardcoded repository names needed
- Works with any folder structure
- Scans for `.git` directories to identify valid repositories

## 🎨 Features

### **Smart Status Detection:**
- ✅ **Fully synced**: Repository has remote tracking and no uncommitted changes
- ⚠️ **Needs attention**: No remote tracking, uncommitted changes, or ahead/behind commits
- 📝 **Uncommitted changes**: Local changes not yet committed
- 📤 **Ahead commits**: Local commits that haven't been pushed
- 📥 **Behind commits**: Remote has commits not present locally

### **Beautiful Output:**
- Colored status indicators with emojis for quick visual scanning
- Tabular formatting for detailed reports
- Progress indicators during bulk operations
- Error handling with clear, actionable messages

### **Error Recovery:**
- Timeout protection for long-running push operations
- Graceful handling of authentication failures
- Clear guidance for next steps when operations fail

## 🔧 Advanced Usage

### **Custom Workflow Integration:**
```bash
# Example: Daily workflow
./gh_manager.sh quick && ./gh_manager.sh commit "Daily sync" && ./gh_manager.sh push

# Example: Interactive menu for complex operations
./gh_manager.sh
```

### **Environment Configuration:**
```bash
# In your ~/.zshrc (already setup):
export GH_TOKEN="ghp_your_token_here"
export GITHUB_USERNAME="sanchez314c"

# The script automatically detects these variables
```

## 🎉 Benefits

- **One unified tool** replaces 8+ scattered scripts
- **Auto-discovery** works with any repository set
- **Proper authentication** using your existing token setup
- **Error prevention** with timeout and retry logic
- **Beautiful output** for easy status monitoring
- **Extensible design** for easy feature additions

## 🛠️ Development

Built to solve the repository management challenges faced during post-crash recovery. This tool represents the consolidation of dozens of recovery scripts into a single, reliable solution.

### **Key Improvements over Original Scripts:**
- ✅ Fixed authentication (uses your actual token instead of wrong username)
- ✅ Removed hardcoded repository lists (auto-discovery)
- ✅ Better error handling (no syntax errors, graceful failures)
- ✅ Cleaner output (proper tables, status indicators)
- ✅ Interactive and command-line interfaces
- ✅ Works with your exact 25 repositories out of the box

---

*Made with ❤️ for efficient GitHub repository management*