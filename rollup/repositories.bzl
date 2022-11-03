"""Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies
"""

load("//rollup/private:versions.bzl", "TOOL_VERSIONS")
load("@aspect_rules_js//npm:npm_import.bzl", _npm_translate_lock = "npm_translate_lock")

LATEST_VERSION = TOOL_VERSIONS[0]

def rollup_repositories(name, rollup_version = LATEST_VERSION):
    """Fetch external tools needed for rollup

    Args:
        name: Unique name for this rollup tools repository
        rollup_version: The rollup version to fetch.

            See /rollup/private/versions.bzl for available versions.
    """
    if rollup_version not in TOOL_VERSIONS:
        fail("""
rollup version {} is not currently mirrored into rules_rollup.
Please instead choose one of these available versions: {}""".format(rollup_version, TOOL_VERSIONS))

    _npm_translate_lock(
        name = name,
        pnpm_lock = "@aspect_rules_rollup//rollup/private:{version}/pnpm-lock.yaml".format(version = rollup_version),
        # fsevents is an optional dependency and is broken on macos
        # with a duplicate action.
        # We think this isn't even a useful feature under Bazel which
        # has its own file watching.
        no_optional = True,
        # We'll be linking in the @foo repository and not the repository where the pnpm-lock file is located
        link_workspace = name,
        # Override the Bazel package where pnpm-lock.yaml is located and link to the specified package instead
        root_package = "",
        defs_bzl_filename = "npm_link_all_packages.bzl",
        repositories_bzl_filename = "npm_repositories.bzl",
        additional_file_contents = {
            "BUILD.bazel": [
                """load("@aspect_bazel_lib//lib:directory_path.bzl", "directory_path")""",
                """load("@aspect_rules_js//js:defs.bzl", "js_binary")""",
                """load("//:npm_link_all_packages.bzl", "npm_link_all_packages")""",
                """npm_link_all_packages(name = "node_modules")""",
                """directory_path(
    name = "rollup_entrypoint",
    directory = ":node_modules/rollup/dir",
    path = "dist/bin/rollup",
)""",
                """js_binary(
    name = "{name}",
    data = [":node_modules/rollup"],
    entry_point = ":rollup_entrypoint",
    visibility = ["//visibility:public"],
)""".format(name = name),
            ],
        },
    )
