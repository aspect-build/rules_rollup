"wrapper macro for rollup_bundle rule"

load("//rollup/private:rollup_bundle.bzl", rollup_lib = "lib")

rollup_bundle = rule(
    implementation = rollup_lib.implementation,
    attrs = rollup_lib.attrs,
    outputs = rollup_lib.outputs,
)
