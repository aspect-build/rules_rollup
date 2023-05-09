load("@aspect_rules_rollup//rollup:defs.bzl", "rollup")
load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@npm//:defs.bzl", "npm_link_all_packages")

npm_link_all_packages(name = "node_modules")

rollup(
    name = "bundle",
    entry_point = "main.js",
    node_modules = "//:node_modules",
)

build_test(
    name = "test",
    targets = [":bundle"],
)
