#!/bin/bash

set -e

# Configuration
GITHUB_REPO="zast-ai/blog"
GITHUB_BRANCH="main"
CURRENT_TAG="$CI_COMMIT_TAG"

# Function to get previous tag
get_previous_tag() {
    local tags=$(git tag --sort=-v:refname)
    local current_index=0
    local prev_tag=""

    # Convert to array
    IFS=$'\n' read -d '' -r -a tag_array <<< "$tags"

    # Find current tag index
    for i in "${!tag_array[@]}"; do
        if [[ "${tag_array[$i]}" == "$CURRENT_TAG" ]]; then
            current_index=$i
            break
        fi
    done

    # Get previous tag (if exists)
    # Previous tag is the next item in the reverse sorted array
    # Only the oldest tag (last in array) should not have a previous tag
    if [[ $current_index -lt $((${#tag_array[@]} - 1)) ]]; then
        prev_tag="${tag_array[$((current_index + 1))]}"
    fi

    echo "$prev_tag"
}

# Function to generate commit message from tag annotation
generate_commit_message() {
    local tag="$1"
    # local annotation=$(git tag -l --format='%(contents)' "$tag" 2>/dev/null)

    # if [[ -n "$annotation" ]]; then
    #     echo "$annotation"
    # else
        echo "Release $tag"
    # fi
}

# Function to generate changelog
generate_changelog() {
    local prev_tag="$1"
    local current_tag="$2"

    if [[ -n "$prev_tag" ]]; then
        git log --pretty=format:"- %s (%h)" "$prev_tag..$current_tag"
    else
        git log --pretty=format:"- %s (%h)" "$current_tag"
    fi
}

# Main release process
echo "🚀 Starting release process for tag: $CURRENT_TAG"

# Validate current tag exists
if ! git rev-parse "$CURRENT_TAG" >/dev/null 2>&1; then
    echo "❌ Error: Tag '$CURRENT_TAG' does not exist"
    exit 1
fi

# Get previous tag
PREVIOUS_TAG=$(get_previous_tag)
echo "Previous tag: ${PREVIOUS_TAG:-None}"

# Check if previous tag and current tag are the same
if [[ -n "$PREVIOUS_TAG" && "$PREVIOUS_TAG" == "$CURRENT_TAG" ]]; then
    echo "⚠️  Previous tag and current tag are the same. Nothing to release."
    exit 0
fi

# Validate required environment variables for commit author
if [[ -z "$GIT_AUTHOR_NAME" || -z "$GIT_AUTHOR_EMAIL" ]]; then
    echo "❌ Error: GIT_AUTHOR_NAME and GIT_AUTHOR_EMAIL must be set"
    echo "Current values:"
    echo "  GIT_AUTHOR_NAME: ${GIT_AUTHOR_NAME:-<not set>}"
    echo "  GIT_AUTHOR_EMAIL: ${GIT_AUTHOR_EMAIL:-<not set>}"
    exit 1
fi

# Generate commit message from tag annotation
COMMIT_MESSAGE=$(generate_commit_message "$CURRENT_TAG")

# Generate changelog
CHANGELOG=$(generate_changelog "$PREVIOUS_TAG" "$CURRENT_TAG")

# Create full commit message
FULL_COMMIT_MESSAGE="$COMMIT_MESSAGE"

# Ensure we have all tags and branches
echo "Fetching all tags and references..."
git fetch --all --tags || echo "Warning: Could not fetch from remote (may be running locally)"

# Switch to main branch (even if it might be outdated)
echo "Switching to main branch..."
git checkout main

# Create a temporary branch based on current tag commit
TEMP_BRANCH="temp-merge-$(date +%s)"
echo "Creating temporary branch based on $CURRENT_TAG: $TEMP_BRANCH"
git checkout -b "$TEMP_BRANCH" "$CURRENT_TAG"

# Apply changes from previous tag to current tag
if [[ -n "$PREVIOUS_TAG" ]]; then
    echo "Applying changes from $PREVIOUS_TAG to $CURRENT_TAG..."

    # Reset to previous tag state to get a clean base
    git reset --hard "$PREVIOUS_TAG"

    # Get all files that changed between previous tag and current tag
    echo "Extracting file changes between tags..."
    git checkout "$CURRENT_TAG" -- .

else
    # First release - use all files from current tag
    echo "First release - applying all files from $CURRENT_TAG"
    git reset --hard "$CURRENT_TAG"
fi

# Stage all changes
git add .

# Check if there are any changes to commit
if git diff --cached --quiet; then
    echo "No changes to commit between ${PREVIOUS_TAG:-initial} and $CURRENT_TAG"
    exit 0
fi

# Commit with unified author information
echo "Creating release commit with unified author"
git commit -m "$FULL_COMMIT_MESSAGE" --author="$GIT_AUTHOR_NAME <$GIT_AUTHOR_EMAIL>"

# Cherry-pick the new commit to main branch
RELEASE_COMMIT=$(git rev-parse HEAD)
echo "Release commit created: $RELEASE_COMMIT"

git checkout main
echo "Cherry-picking release commit to main branch..."
git cherry-pick "$RELEASE_COMMIT" || git commit -m "$FULL_COMMIT_MESSAGE" --author="$GIT_AUTHOR_NAME <$GIT_AUTHOR_EMAIL>"

# Clean up temporary branch
git branch -D "$TEMP_BRANCH"

# Step 1: Push to GitHub first (if GITHUB_TOKEN is available)
GITHUB_PUSH_SUCCESS=false

if [[ -n "$GITHUB_TOKEN" ]]; then
    echo "📤 Step 1: Pushing main branch to GitHub $GITHUB_BRANCH branch..."

    # Debug GitHub configuration
    echo "🔍 GitHub Configuration Debug:"
    echo "  GITHUB_REPO: $GITHUB_REPO"
    echo "  GITHUB_BRANCH: $GITHUB_BRANCH"
    echo "  GITHUB_USERNAME: ${GITHUB_USERNAME:-<not set>}"
    echo "  GITHUB_TOKEN: ${GITHUB_TOKEN:0:8}... (${#GITHUB_TOKEN} chars total)"

    # Validate required variables
    if [[ -z "$GITHUB_USERNAME" ]]; then
        echo "❌ Error: GITHUB_USERNAME is not set"
        echo "💡 Add GITHUB_USERNAME to GitLab CI/CD variables"
        exit 1
    fi

    if [[ ${#GITHUB_TOKEN} -lt 10 ]]; then
        echo "❌ Error: GITHUB_TOKEN appears to be invalid (too short)"
        echo "💡 Check GITHUB_TOKEN in GitLab CI/CD variables"
        exit 1
    fi

    # Add GitHub remote
    GITHUB_URL="https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$GITHUB_REPO.git"
    echo "🔗 Adding GitHub remote: https://$GITHUB_USERNAME:***@github.com/$GITHUB_REPO.git"
    git remote add github "$GITHUB_URL" 2>/dev/null || true

    # Test GitHub connectivity
    echo "🧪 Testing GitHub connectivity..."
    if git ls-remote github >/dev/null 2>&1; then
        echo "✅ GitHub remote access verified"
    else
        echo "❌ Failed to access GitHub remote"
        echo "💡 Possible issues:"
        echo "  1. GITHUB_TOKEN has expired or lacks repository access"
        echo "  2. Repository $GITHUB_REPO doesn't exist or is private"
        echo "  3. GITHUB_USERNAME is incorrect"
        exit 1
    fi

    if git push --force github "main:$GITHUB_BRANCH"; then
        echo "✅ Successfully pushed to GitHub"
        GITHUB_PUSH_SUCCESS=true
    else
        echo "❌ Failed to push to GitHub"
        echo "🔍 Troubleshooting steps:"
        echo "  1. Verify GITHUB_TOKEN has 'repo' or 'public_repo' scope"
        echo "  2. Check if token belongs to user with write access to $GITHUB_REPO"
        echo "  3. Ensure repository exists: https://github.com/$GITHUB_REPO"
        echo "Aborting GitLab sync due to GitHub failure"
        exit 1
    fi
else
    echo "⚠️  GITHUB_TOKEN is not set. Skipping GitHub sync."
    echo "⚠️  GitLab sync will also be skipped as it depends on GitHub success."
    echo "✅ Release completed locally! Release commit added to main branch."
    echo "📝 Commit message:"
    echo "$FULL_COMMIT_MESSAGE"
    exit 0
fi

# Step 2: Push to GitLab origin (only if GitHub was successful)
if [[ "$GITHUB_PUSH_SUCCESS" == "true" ]]; then
    echo "📤 Step 2: Pushing main branch to GitLab origin..."

    # Try using CI_JOB_TOKEN if available (GitLab CI environment)
    if [[ -n "$CI_JOB_TOKEN" ]]; then
        echo "Using CI_JOB_TOKEN for GitLab authentication"
        # Set up authentication using CI_JOB_TOKEN
        git remote set-url origin "https://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.tailf2fef.ts.net/eng/zast-blog.git" 2>/dev/null || true
    fi

    if git push origin main --force; then
        echo "✅ Successfully pushed to GitLab origin"
    else
        echo "⚠️  Failed to push to GitLab origin"
        echo "This might be due to insufficient permissions."
        echo ""
        echo "💡 To fix GitLab push permissions:"
        echo "  1. Ensure CI/CD job token has write access in project settings"
        echo "  2. Or add a deploy key with write permissions"
        echo "  3. Or use a personal access token with write_repository scope"
        echo ""
        echo "✅ GitHub sync was successful, manual GitLab sync may be needed"
    fi
else
    echo "❌ Skipping GitLab sync due to GitHub failure"
    exit 1
fi

echo "✅ Release completed successfully!"
echo "🎯 Summary:"
echo "  - Release commit created on main branch"
echo "  - ✅ Synced to GitHub repository (Step 1)"
echo "  - ✅ Pushed to GitLab origin (Step 2)"
echo "📝 Commit message:"
echo "$FULL_COMMIT_MESSAGE"