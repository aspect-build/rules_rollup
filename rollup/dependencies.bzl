"Fetch dependencies needed by users."

load("//rollup/private:maybe.bzl", http_archive = "maybe_http_archive")

def rules_rollup_dependencies():
    http_archive(
        name = "bazel_skylib",
        sha256 = "74d544d96f4a5bb630d465ca8bbcfe231e3594e5aae57e1edbf17a6eb3ca2506",
        urls = ["https://github.com/bazelbuild/bazel-skylib/releases/download/1.3.0/bazel-skylib-1.3.0.tar.gz"],
    )

    http_archive(
        name = "aspect_bazel_lib",
        sha256 = "a7bfc7aed7b86a4caaba382116e0214ebbaa623f393a9e716d87a3e1bab29d78",
        strip_prefix = "bazel-lib-1.19.0",
        url = "https://github.com/aspect-build/bazel-lib/archive/refs/tags/v1.19.0.tar.gz",
    )

    http_archive(
        name = "aspect_rules_js",
        sha256 = "66ecc9f56300dd63fb86f11cfa1e8affcaa42d5300e2746dba08541916e913fd",
        strip_prefix = "rules_js-1.13.0",
        url = "https://github.com/aspect-build/rules_js/archive/refs/tags/v1.13.0.tar.gz",
    )

    http_archive(
        name = "rules_nodejs",
        sha256 = "08337d4fffc78f7fe648a93be12ea2fc4e8eb9795a4e6aa48595b66b34555626",
        urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/5.8.0/rules_nodejs-core-5.8.0.tar.gz"],
    )
