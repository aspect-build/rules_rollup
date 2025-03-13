"Fetch dependencies needed by users."

load("//rollup/private:maybe.bzl", http_archive = "maybe_http_archive")

def rules_rollup_dependencies():
    http_archive(
        name = "bazel_skylib",
        sha256 = "cd55a062e763b9349921f0f5db8c3933288dc8ba4f76dd9416aac68acee3cb94",
        urls = ["https://github.com/bazelbuild/bazel-skylib/releases/download/1.5.0/bazel-skylib-1.5.0.tar.gz"],
    )

    http_archive(
        name = "aspect_bazel_lib",
        sha256 = "c96db69dd2714a37f3298338a1a42b27e3a2696c3b36dd4441b9bf7a1a12bee0",
        strip_prefix = "bazel-lib-2.11.0",
        url = "https://github.com/bazel-contrib/bazel-lib/releases/download/v2.11.0/bazel-lib-v2.11.0.tar.gz",
    )

    http_archive(
        name = "aspect_rules_js",
        sha256 = "6b7e73c35b97615a09281090da3645d9f03b2a09e8caa791377ad9022c88e2e6",
        strip_prefix = "rules_js-2.0.0",
        url = "https://github.com/aspect-build/rules_js/releases/download/v2.0.0/rules_js-v2.0.0.tar.gz",
    )

    http_archive(
        name = "rules_nodejs",
        sha256 = "87c6171c5be7b69538d4695d9ded29ae2626c5ed76a9adeedce37b63c73bef67",
        strip_prefix = "rules_nodejs-6.2.0",
        url = "https://github.com/bazelbuild/rules_nodejs/releases/download/v6.2.0/rules_nodejs-v6.2.0.tar.gz",
    )
