#!/usr/bin/env bash
set -o errexit -o nounset
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

version="$(curl --silent "https://registry.npmjs.org/rollup/latest" | jq --raw-output ".version")"
out="$SCRIPT_DIR/../rollup/private/v${version}"
mkdir -p "$out"

cd $(mktemp -d)
npx pnpm install rollup --lockfile-only
touch BUILD
cat >WORKSPACE <<EOF
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "aspect_rules_js",
    sha256 = "e5de2d6aa3c6987875085c381847a216b1053b095ec51c11e97b781309406ad4",
    strip_prefix = "rules_js-0.5.0",
    url = "https://github.com/aspect-build/rules_js/archive/refs/tags/v0.5.0.tar.gz",
)
load("@aspect_rules_js//js:repositories.bzl", "rules_js_dependencies")

rules_js_dependencies()

load("@rules_nodejs//nodejs:repositories.bzl", "nodejs_register_toolchains")

nodejs_register_toolchains(
    name = "nodejs",
    node_version = "16.9.0",
)

load("@aspect_bazel_lib//lib:repositories.bzl", "DEFAULT_YQ_VERSION", "register_yq_toolchains")

register_yq_toolchains(
    version = DEFAULT_YQ_VERSION,
)

load("@aspect_rules_js//js:npm_import.bzl", "translate_pnpm_lock")

translate_pnpm_lock(name = "npm", pnpm_lock = "//:pnpm-lock.yaml")
EOF
bazel fetch @npm//:all
cp $(bazel info output_base)/external/npm/{node_modules,repositories}.bzl "$out"
echo "Mirrored rollup versior $version to $out. Now add it to rollup/private/versions.bzl"
