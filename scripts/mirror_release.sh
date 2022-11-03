#!/usr/bin/env bash
set -o errexit -o nounset
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

version="${1:-$(curl --silent "https://registry.npmjs.org/rollup/latest" | jq --raw-output ".version")}"

out="$SCRIPT_DIR/../rollup/private/v${version}"
mkdir -p "$out"

cd $(mktemp -d)
npx pnpm install "rollup@$version" --lockfile-only
cp pnpm-lock.yaml "$out"
echo "Mirrored rollup version $version to $out. Now add it to rollup/private/versions.bzl"
