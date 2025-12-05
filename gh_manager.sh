#!/bin/bash

# 🚀 Simple GitHub Repository Manager
# A unified tool for managing all GitHub repositories

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
GITHUB_USERNAME="${GITHUB_USERNAME:-sanchez314c}"
GITHUB_TOKEN="${GH_TOKEN:-}"

# Working directory
cd "$(dirname "${BASH_SOURCE[0]}")"

# Utility functions
print_header() {
    echo -e "${BLUE}================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Discover repositories
discover_repos() {
    local repos=()
    for dir in */; do
        if [[ -d "$dir" && -d "$dir/.git" ]]; then
            repos+=("${dir%/}")
        fi
    done
    echo "${repos[@]}"
}

# Check authentication
check_auth() {
    if [[ -z "$GITHUB_TOKEN" ]]; then
        print_error "GitHub token not found!"
        print_info "Set GH_TOKEN environment variable"
        return 1
    fi
    return 0
}

# Get repository status
get_repo_status() {
    local repo="$1"
    cd "$repo" 2>/dev/null || return 1

    # Get basic info
    local branch
    branch=$(git branch --show-current 2>/dev/null || echo "unknown")

    local changes
    changes=$(git status --porcelain 2>/dev/null | wc -l | xargs)

    local tracking="no"
    local ahead=0
    local behind=0

    # Check tracking
    if git branch -vv 2>/dev/null | grep -q '\[origin'; then
        tracking="yes"
        local ahead_behind
        ahead_behind=$(git rev-list --left-right --count "origin/$branch..HEAD" 2>/dev/null || echo "0 0")
        behind=$(echo "$ahead_behind" | cut -d' ' -f1)
        ahead=$(echo "$ahead_behind" | cut -d' ' -f2)
    fi

    cd ..
    echo "$branch|$tracking|$changes|$ahead|$behind"
}

# Quick status check
quick_status() {
    print_header "📊 Quick Repository Status"
    check_auth || return 1

    local repos
    repos=($(discover_repos))

    print_info "Found ${#repos[@]} repositories"
    echo ""

    for repo in "${repos[@]}"; do
        local status_info
        status_info=$(get_repo_status "$repo")

        IFS='|' read -r branch tracking changes ahead behind <<< "$status_info"

        # Simple status logic
        if [[ "$tracking" == "no" ]]; then
            print_warning "$repo: Needs attention"
        elif [[ "$changes" -gt 0 ]]; then
            print_warning "$repo: Needs attention"
        elif [[ "$ahead" -gt 0 ]]; then
            print_warning "$repo: Needs attention"
        elif [[ "$behind" -gt 0 ]]; then
            print_warning "$repo: Behind remote"
        else
            print_success "$repo: OK"
        fi
    done
    echo ""
}

# Detailed status
detailed_status() {
    print_header "📊 Detailed Repository Status"
    check_auth || return 1

    local repos
    repos=($(discover_repos))

    local synced=0
    local needs_attention=0

    print_info "Found ${#repos[@]} repositories"
    echo ""

    printf "${CYAN}%-20s %-15s %-10s %-10s %s${NC}\n" \
        "Repository" "Branch" "Changes" "Status"
    echo "$(printf '%.0s-' {1..60})"

    for repo in "${repos[@]}"; do
        local status_info
        status_info=$(get_repo_status "$repo")

        IFS='|' read -r branch tracking changes ahead behind <<< "$status_info"

        local status_text=""
        if [[ "$tracking" == "no" ]]; then
            status_text="🔗 No remote"
        elif [[ "$changes" -gt 0 ]]; then
            status_text="📝 $changes changes"
        elif [[ "$ahead" -gt 0 ]]; then
            status_text="📤 $ahead ahead"
        elif [[ "$behind" -gt 0 ]]; then
            status_text="📥 $behind behind"
        else
            status_text="✅ Fully synced"
        fi

        printf "%-20s %-15s %-10d %s\n" "$repo" "$branch" "$changes" "$status_text"

        # Count statistics
        if [[ "$status_text" == *"✅ Fully synced"* ]]; then
            ((synced++))
        else
            ((needs_attention++))
        fi
    done

    echo ""
    print_info "Summary: $synced synced, $needs_attention need attention"
}

# Commit all changes
commit_all() {
    local msg="${1:-Bulk update $(date '+%Y-%m-%d %H:%M:%S')}"

    print_header "📝 Commit All Changes"
    print_info "Message: $msg"
    echo ""

    local repos
    repos=($(discover_repos))

    local committed=0

    for repo in "${repos[@]}"; do
        cd "$repo" 2>/dev/null || continue

        local changes
        changes=$(git status --porcelain 2>/dev/null | wc -l | xargs)

        if [[ "$changes" -gt 0 ]]; then
            print_info "Committing in $repo..."
            git add .
            git commit -m "$msg"
            print_success "Committed $repo"
            ((committed++))
        else
            print_info "No changes in $repo"
        fi

        cd ..
    done

    print_success "Committed changes in $committed repositories"
}

# Push all repositories
push_all() {
    print_header "🚀 Push All Repositories"
    check_auth || return 1

    local repos
    repos=($(discover_repos()))

    local success=0
    local failed=0

    for repo in "${repos[@]}"; do
        print_info "Processing $repo..."

        cd "$repo" 2>/dev/null || continue

        # Ensure remote
        if ! git remote get-url origin >/dev/null 2>&1; then
            git remote add origin "https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$repo.git"
        fi

        # Get branch and push
        local branch
        branch=$(git branch --show-current 2>/dev/null || echo "main")

        if timeout 30 git push -u origin "$branch" 2>/dev/null; then
            print_success "Pushed $repo"
            ((success++))
        else
            print_error "Failed to push $repo"
            ((failed++))
        fi

        cd ..
    done

    print_info "Results: $success pushed, $failed failed"
}

# Fix tracking
fix_tracking() {
    print_header "🔧 Fix Repository Tracking"
    check_auth || return 1

    local repos
    repos=($(discover_repos()))

    for repo in "${repos[@]}"; do
        print_info "Fixing $repo..."

        cd "$repo" 2>/dev/null || continue

        # Set up proper remote
        if ! git remote get-url origin >/dev/null 2>&1; then
            git remote add origin "https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$repo.git"
        else
            git remote set-url origin "https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$repo.git"
        fi

        # Set up tracking
        local branch
        branch=$(git branch --show-current 2>/dev/null || echo "main")

        git fetch origin 2>/dev/null || true
        git branch --set-upstream-to="origin/$branch" "$branch" 2>/dev/null || true

        print_success "Fixed $repo"
        cd ..
    done
}

# Show help
show_help() {
    echo "GitHub Repository Manager"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  quick      Quick status check"
    echo "  status     Detailed status"
    echo "  commit     Commit all changes"
    echo "  push       Push all repositories"
    echo "  fix        Fix repository tracking"
    echo "  help       Show this help"
    echo ""
    echo "Run without arguments for interactive menu"
}

# Interactive menu
show_menu() {
    clear
    print_header "🚀 GitHub Repository Manager"
    echo -e "${CYAN}Choose an operation:${NC}"
    echo ""
    echo "1) 📊 Quick status"
    echo "2) 📋 Detailed status"
    echo "3) 📝 Commit all changes"
    echo "4) 🚀 Push all repositories"
    echo "5) 🔧 Fix repository tracking"
    echo "6) ❓ Help"
    echo "q) 🚪 Quit"
    echo ""
    echo -n "Select option [1-6,q]: "
}

# Main execution
main() {
    case "${1:-menu}" in
        "quick"|"q")
            quick_status
            ;;
        "status"|"s")
            detailed_status
            ;;
        "commit"|"c")
            commit_all "$2"
            ;;
        "push"|"p")
            push_all
            ;;
        "fix"|"f")
            fix_tracking
            ;;
        "help"|"h"|"-h"|"--help")
            show_help
            ;;
        "menu"|"")
            while true; do
                show_menu
                read -r choice
                echo ""

                case $choice in
                    1)
                        quick_status
                        ;;
                    2)
                        detailed_status
                        ;;
                    3)
                        commit_all
                        ;;
                    4)
                        push_all
                        ;;
                    5)
                        fix_tracking
                        ;;
                    6)
                        show_help
                        ;;
                    q|Q)
                        print_success "Goodbye! 👋"
                        exit 0
                        ;;
                    *)
                        print_error "Invalid option: $choice"
                        ;;
                esac

                echo ""
                echo -n "Press Enter to continue..."
                read -r
            done
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"