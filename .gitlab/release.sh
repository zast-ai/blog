#!/bin/bash

set -e

# Configuration
GITHUB_REPO="zast-ai/zast-blog"
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
    if [[ $current_index -gt 0 ]]; then
        prev_tag="${tag_array[$((current_index + 1))]}"
    fi

    echo "$prev_tag"
}

# Function to generate commit message from tag annotation
generate_commit_message() {
    local tag="$1"
    local annotation=$(git tag -l --format='%(contents)' "$tag" 2>/dev/null)

    if [[ -n "$annotation" ]]; then
        echo "$annotation"
    else
        echo "Release $tag"
    fi
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

# Get previous tag
PREVIOUS_TAG=$(get_previous_tag)
echo "Previous tag: ${PREVIOUS_TAG:-None}"

# Generate commit message from tag annotation
COMMIT_MESSAGE=$(generate_commit_message "$CURRENT_TAG")

# Generate changelog
CHANGELOG=$(generate_changelog "$PREVIOUS_TAG" "$CURRENT_TAG")

# Create full commit message
FULL_COMMIT_MESSAGE="$COMMIT_MESSAGE

Changes since ${PREVIOUS_TAG:-initial commit}:
$CHANGELOG"

# Create temporary branch for the release
RELEASE_BRANCH="release-$CURRENT_TAG"
git checkout -b "$RELEASE_BRANCH"

# Reset to create a clean commit
if [[ -n "$PREVIOUS_TAG" ]]; then
    git reset --hard "$PREVIOUS_TAG"
else
    # First release - start from empty commit
    git rm -rf . || true
    git clean -fdx
    echo "Initial release" > README.md
    git add README.md
    git commit -m "Initial commit" || true
fi

# Merge all changes since previous tag (or all changes for first release)
if [[ -n "$PREVIOUS_TAG" ]]; then
    git merge --squash "$CURRENT_TAG"
else
    git merge --squash "$CURRENT_TAG"
fi

# Commit with unified author information
git add .
git commit -m "$FULL_COMMIT_MESSAGE" --author="$GIT_AUTHOR_NAME <$GIT_AUTHOR_EMAIL>"

# Add GitHub remote
git remote add github "https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$GITHUB_REPO.git"

# Force push to GitHub main branch
echo "📤 Pushing to GitHub $GITHUB_BRANCH branch..."
git push --force github "$RELEASE_BRANCH:$GITHUB_BRANCH"

# Clean up
git remote remove github

echo "✅ Release completed successfully!"
echo "📝 Commit message:"
echo "$FULL_COMMIT_MESSAGE"