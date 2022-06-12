load("@aspect_rules_rollup//rollup:defs.bzl", "rollup_bundle")
load("@bazel_skylib//rules:build_test.bzl", "build_test")

rollup_bundle(
    name = "bundle",
    config_file = "config.js",
    entry_point = "main.js",
)

build_test(
    name = "test",
    targets = [":bundle"],
)
