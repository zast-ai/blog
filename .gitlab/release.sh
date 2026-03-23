#!/bin/bash

set -e

# Configuration
GITHUB_REPO="zast-ai/blog"
GITHUB_BRANCH="release"
CURRENT_TAG="${RELEASE_TAG:-$CI_COMMIT_TAG}"
GITHUB_REMOTE="github"
TEMP_DIR=""

cleanup() {
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

generate_commit_message() {
    local tag="$1"
    echo "Release $tag"
}

resolve_gitlab_auth_header() {
    if [[ -n "$GITLAB_API_TOKEN" ]]; then
        echo "PRIVATE-TOKEN: $GITLAB_API_TOKEN"
    else
        echo ""
    fi
}

resolve_latest_verified_tag() {
    local auth_header
    local pipelines_url
    local response
    local resolved_tag

    auth_header=$(resolve_gitlab_auth_header)

    if [[ -z "$auth_header" || -z "$CI_API_V4_URL" || -z "$CI_PROJECT_ID" ]]; then
        echo "❌ Error: RELEASE_TAG/CI_COMMIT_TAG is not set and GitLab API credentials are unavailable"
        echo "💡 Set RELEASE_TAG for manual publish, or configure GITLAB_API_TOKEN with read_api scope for scheduled publish"
        exit 1
    fi

    pipelines_url="${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/pipelines?scope=tags&status=success&order_by=updated_at&sort=desc&per_page=20"

    echo "🔎 Resolving latest verified tag from GitLab..."
    response=$(curl --silent --show-error --fail --header "$auth_header" "$pipelines_url") || {
        echo "❌ Error: Failed to query GitLab pipelines API"
        echo "💡 GITLAB_API_TOKEN must be a project/group/personal access token with read_api scope"
        echo "💡 CI_JOB_TOKEN is not sufficient here on many GitLab installations and often returns 404 for private projects"
        exit 1
    }
    resolved_tag=$(printf '%s' "$response" | jq -r 'map(select(.ref != null)) | .[0].ref // empty')

    if [[ -z "$resolved_tag" ]]; then
        echo "❌ Error: Could not find a successful tag pipeline to publish"
        exit 1
    fi

    CURRENT_TAG="$resolved_tag"
}

prepare_github_remote() {
    echo "🔍 GitHub Configuration Debug:"
    echo "  GITHUB_REPO: $GITHUB_REPO"
    echo "  GITHUB_BRANCH: $GITHUB_BRANCH"
    echo "  GITHUB_USERNAME: ${GITHUB_USERNAME:-<not set>}"
    echo "  GITHUB_TOKEN: ${GITHUB_TOKEN:0:8}... (${#GITHUB_TOKEN} chars total)"

    if [[ -z "$GITHUB_USERNAME" ]]; then
        echo "❌ Error: GITHUB_USERNAME is not set"
        echo "💡 Add GITHUB_USERNAME to GitLab CI/CD variables"
        exit 1
    fi

    if [[ -z "$GITHUB_TOKEN" || ${#GITHUB_TOKEN} -lt 10 ]]; then
        echo "❌ Error: GITHUB_TOKEN is missing or appears invalid"
        echo "💡 Check GITHUB_TOKEN in GitLab CI/CD variables"
        exit 1
    fi

    GITHUB_URL="https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$GITHUB_REPO.git"
    git remote add "$GITHUB_REMOTE" "$GITHUB_URL" 2>/dev/null || git remote set-url "$GITHUB_REMOTE" "$GITHUB_URL"

    echo "🧪 Testing GitHub connectivity..."
    if ! git ls-remote "$GITHUB_REMOTE" >/dev/null 2>&1; then
        echo "❌ Failed to access GitHub remote"
        echo "💡 Possible issues:"
        echo "  1. GITHUB_TOKEN has expired or lacks repository access"
        echo "  2. Repository $GITHUB_REPO doesn't exist or is private"
        echo "  3. GITHUB_USERNAME is incorrect"
        exit 1
    fi
}

create_release_repo() {
    TEMP_DIR=$(mktemp -d)
    RELEASE_REPO="$TEMP_DIR/release-repo"

    if git ls-remote --exit-code --heads "$GITHUB_REMOTE" "$GITHUB_BRANCH" >/dev/null 2>&1; then
        echo "📥 Cloning existing GitHub release branch..."
        git clone --branch "$GITHUB_BRANCH" --single-branch "$GITHUB_URL" "$RELEASE_REPO" >/dev/null 2>&1
    else
        echo "🆕 Initializing new GitHub release branch..."
        git init -b "$GITHUB_BRANCH" "$RELEASE_REPO" >/dev/null 2>&1
        git -C "$RELEASE_REPO" remote add origin "$GITHUB_URL"
    fi

    git -C "$RELEASE_REPO" config user.name "$GIT_AUTHOR_NAME"
    git -C "$RELEASE_REPO" config user.email "$GIT_AUTHOR_EMAIL"
}

sync_tag_snapshot() {
    echo "🧹 Rebuilding release branch from tag snapshot..."
    find "$RELEASE_REPO" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
    git archive "$CURRENT_TAG" | tar -x -C "$RELEASE_REPO"
}

commit_release_snapshot() {
    local commit_message="$1"

    git -C "$RELEASE_REPO" add --all

    if git -C "$RELEASE_REPO" diff --cached --quiet; then
        echo "ℹ️  Release branch already matches tag $CURRENT_TAG. Nothing to publish."
        exit 0
    fi

    echo "📝 Creating release commit on $GITHUB_BRANCH..."
    GIT_AUTHOR_NAME="$GIT_AUTHOR_NAME" \
    GIT_AUTHOR_EMAIL="$GIT_AUTHOR_EMAIL" \
    GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME" \
    GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL" \
    git -C "$RELEASE_REPO" commit -m "$commit_message" --author="$GIT_AUTHOR_NAME <$GIT_AUTHOR_EMAIL>"
}

push_release_branch() {
    echo "📤 Pushing release branch to GitHub..."
    if git -C "$RELEASE_REPO" push origin "HEAD:$GITHUB_BRANCH"; then
        echo "✅ Successfully pushed to GitHub"
    else
        echo "❌ Failed to push to GitHub"
        echo "🔍 Troubleshooting steps:"
        echo "  1. Verify GITHUB_TOKEN has repository write access"
        echo "  2. Check if token belongs to a user with write access to $GITHUB_REPO"
        echo "  3. Ensure repository exists: https://github.com/$GITHUB_REPO"
        exit 1
    fi
}

echo "🚀 Starting release process"

if [[ -z "$CURRENT_TAG" ]]; then
    resolve_latest_verified_tag
fi

echo "📌 Selected tag for publish: $CURRENT_TAG"

echo "Fetching all tags and references..."
git fetch --all --tags || echo "Warning: Could not fetch from remote (may be running locally)"

if ! git rev-parse "$CURRENT_TAG" >/dev/null 2>&1; then
    echo "❌ Error: Tag '$CURRENT_TAG' does not exist"
    exit 1
fi

if [[ -z "$GIT_AUTHOR_NAME" || -z "$GIT_AUTHOR_EMAIL" ]]; then
    echo "❌ Error: GIT_AUTHOR_NAME and GIT_AUTHOR_EMAIL must be set"
    echo "Current values:"
    echo "  GIT_AUTHOR_NAME: ${GIT_AUTHOR_NAME:-<not set>}"
    echo "  GIT_AUTHOR_EMAIL: ${GIT_AUTHOR_EMAIL:-<not set>}"
    exit 1
fi

if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "❌ Error: GITHUB_TOKEN must be set for release publishing"
    exit 1
fi

FULL_COMMIT_MESSAGE=$(generate_commit_message "$CURRENT_TAG")

prepare_github_remote
create_release_repo
sync_tag_snapshot
commit_release_snapshot "$FULL_COMMIT_MESSAGE"
push_release_branch

echo "✅ Release completed successfully!"
echo "🎯 Summary:"
echo "  - Release commit created on $GITHUB_BRANCH"
echo "  - ✅ Synced to GitHub repository"
echo "📝 Commit message:"
echo "$FULL_COMMIT_MESSAGE"
