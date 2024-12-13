#!/bin/sh

set -e

RANCHER_REPO_DIR=$1

DEPS_TO_SYNC="
  github.com/rancher/dynamiclistener
  github.com/rancher/lasso
  github.com/rancher/wrangler
  github.com/rancher/wrangler/v2
  github.com/rancher/wrangler/v3
"

rancher_deps=$(cd "$RANCHER_REPO_DIR" && go mod graph)
webhook_deps=$(go mod graph)

rancher_ref=$(cd "$RANCHER_REPO_DIR" && git rev-parse HEAD)
rancher_ref_version=$(go mod download -json "github.com/rancher/rancher/pkg/apis@$rancher_ref" | jq -r '.Version')
echo "Syncing github.com/rancher/rancher/pkg/apis"
go mod edit "-require=github.com/rancher/rancher/pkg/apis@$rancher_ref_version"

for dep in $DEPS_TO_SYNC; do
  echo "Rancher Dep $dep $(echo "$rancher_deps" | grep "^$dep@\w*\S")"
  echo "Webhook Dep $dep $(echo "$webhook_deps" | grep "^$dep@\w*\S")"
  rancher_version=$(echo "$rancher_deps" | grep "^$dep@\w*\S" | head -n 1 | cut -d' ' -f1 | cut -d@ -f2)
  webhook_version=$(echo "$webhook_deps" | grep "^$dep@\w*\S" | head -n 1 | cut -d' ' -f1 | cut -d@ -f2)
  if [ -z "$webhook_version" ] || [ -z "$rancher_version" ] || [ "$rancher_version" = "$webhook_version" ]; then
    continue
  fi

  echo "Version mismatch for $dep (rancher=$rancher_version, webhook=$webhook_version) detected"
  go mod edit -require=$dep@$rancher_version
done

echo "Running go mod tidy"
go mod tidy
