#!/bin/sh

set -e

PULL_REQUEST=$1
TARGET_BRANCH=$2
CHERRY_PICK=$3
REPO=$4
REPO_OWNER=$(echo "$REPO" | cut -d/ -f1)

TARGET_SLUG=$(echo "$TARGET_BRANCH" | sed "s|/|-|")
BRANCH_NAME="backport-$PULL_REQUEST-$TARGET_SLUG-$$"

PR_LINK=https://github.com/$REPO/pull/$PULL_REQUEST
PR_NUMBER=$PULL_REQUEST

echo $PULL_REQUEST
echo $TARGET_BRANCH
echo $CHERRY_PICK
echo $BRANCH_NAME
echo $PR_LINK
echo $REPO
echo $REPO_OWNER

git checkout -b "$BRANCH_NAME" "$TARGET_BRANCH"

committed_something=""

if [ "$CHERRY_PICK" = "true" ]; then
	git fetch origin "pull/$PR_NUMBER/head:to-cherry-pick"
	commit=$(git rev-parse to-cherry-pick)
	if git cherry-pick --allow-empty "$commit"; then
		committed_something="true"
	else
		echo "Cherry-pick failed, skipping"
		git cherry-pick --abort
	fi
fi

if [ -z "$committed_something" ]; then
	# Github won't allow us to create a PR without any changes so we're making an empty commit here
	git commit --allow-empty -m "Please amend this commit"
fi

git push -u origin "$BRANCH_NAME"

old_title=$(gh pr view "$PR_NUMBER" --json title --jq '.title')
old_body=$(gh pr view "$PR_NUMBER" --json body --jq '.body')

title=$(echo "[$TARGET_BRANCH] $old_title")
body=$(cat <<EOF
# Backport

Backport of $PR_LINK

$old_body

EOF
)

echo "$body"

gh pr create \
  --title "$title" \
  --body "$body" \
  --repo "$REPO" \
  --head "$REPO_OWNER:$BRANCH_NAME" \
  --base "$TARGET_BRANCH" \
  --draft
