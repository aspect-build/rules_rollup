"wrapper macro for rollup_bundle rule"

load("//rollup/private:rollup_bundle.bzl", rollup_lib = "lib")

_rollup_bundle = rule(
    implementation = rollup_lib.implementation,
    attrs = rollup_lib.attrs,
    outputs = rollup_lib.outputs,
)

def rollup_bundle(**kwargs):
    _rollup_bundle(
        is_windows = select({
            "@bazel_tools//src/conditions:host_windows": True,
            "//conditions:default": False,
        }),
        **kwargs
    )
