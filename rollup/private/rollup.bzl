"rollup"

load("@aspect_bazel_lib//lib:copy_to_bin.bzl", "COPY_FILE_TO_BIN_TOOLCHAINS", "copy_file_to_bin_action", "copy_files_to_bin_actions")
load("@aspect_rules_js//js:libs.bzl", "js_lib_helpers")
load("@aspect_rules_js//js:providers.bzl", "JsInfo", "js_info")

_ATTRS = {
    "args": attr.string_list(),
    "config_file": attr.label(
        allow_single_file = True,
    ),
    "deps": attr.label_list(
        doc = """""",
        providers = [JsInfo],
    ),
    "data": attr.label_list(
        allow_files = True,
    ),
    "entry_point": attr.label(
        allow_single_file = True,
    ),
    "entry_points": attr.label_keyed_string_dict(
        allow_files = True,
    ),
    "format": attr.string(
        values = ["amd", "cjs", "esm", "iife", "umd", "system"],
    ),
    "output_dir": attr.bool(),
    "silent": attr.bool(),
    "silent_on_success": attr.bool(),
    "sourcemap": attr.string(
        default = "inline",
        values = ["inline", "hidden", "true", "false"],
    ),
    "srcs": attr.label_list(
        # Don't try to constrain the filenames, could be json, svg, whatever
        allow_files = True,
    ),
    "rollup": attr.label(
        executable = True,
        cfg = "exec",
        mandatory = True,
    ),
}

def _output_relative_path(f):
    "Give the path from bazel-out/[arch]/bin to the given File object"
    if f.short_path.startswith("../"):
        return "external/" + f.short_path[3:]
    return f.short_path

def _desugar_entry_point_names(name, entry_point, entry_points):
    """Users can specify entry_point (sugar) or entry_points (long form).

    This function allows our code to treat it like they always used the long form.
    It also performs validation:
    - exactly one of these attributes should be specified
    """
    if entry_point and entry_points:
        fail("Cannot specify both entry_point and entry_points")
    if not entry_point and not entry_points:
        fail("One of entry_point or entry_points must be specified")
    if entry_point:
        return [name]
    return entry_points.values()

def _desugar_entry_points(name, entry_point, entry_points, inputs):
    """Like above, but used by the implementation function, where the types differ.

    It also performs validation:
    - attr.label_keyed_string_dict doesn't accept allow_single_file
      so we have to do validation now to be sure each key is a label resulting in one file
    It converts from dict[target: string] to dict[file: string]
    """
    names = _desugar_entry_point_names(name, entry_point.label if entry_point else None, entry_points)

    if entry_point:
        return {_resolve_js_input(entry_point.files.to_list()[0], inputs): names[0]}

    result = {}
    for ep in entry_points.items():
        entry_point = ep[0]
        name = ep[1]
        f = entry_point.files.to_list()
        if len(f) != 1:
            fail("keys in rollup#entry_points must provide one file, but %s has %s" % (entry_point.label, len(f)))
        result[_resolve_js_input(f[0], inputs)] = name
    return result

def _resolve_js_input(f, inputs):
    if f.extension == "js" or f.extension == "mjs":
        return f.short_path

    # look for corresponding js file in inputs
    no_ext = _no_ext(f)
    for i in inputs:
        if i.extension == "js" or i.extension == "mjs":
            if _no_ext(i) == no_ext:
                return i
    fail("Could not find corresponding javascript entry point for %s. Add the %s.js to your deps." % (f.path, no_ext))

def _rollup_outs(sourcemap, name, entry_point, entry_points, output_dir):
    """Supply some labelled outputs in the common case of a single entry point"""
    result = {}
    entry_point_outs = _desugar_entry_point_names(name, entry_point, entry_points)
    if output_dir:
        # We can't declare a directory output here, because RBE will be confused, like
        # com.google.devtools.build.lib.remote.ExecutionStatusException:
        # INTERNAL: failed to upload outputs: failed to construct CAS files:
        # failed to calculate file hash:
        # read /b/f/w/bazel-out/k8-fastbuild/bin/packages/rollup/test/multiple_entry_points/chunks: is a directory
        #result["chunks"] = output_dir
        return {}
    else:
        if len(entry_point_outs) > 1:
            fail("Multiple entry points require that output_dir be set")
        out = entry_point_outs[0]
        result[out] = out + ".js"
        if sourcemap == "true":
            result[out + "_map"] = "%s.map" % result[out]
    return result

def _no_ext(f):
    return f.short_path[:-len(f.extension) - 1]

def _filter_js(files):
    return [f for f in files if f.extension == "js" or f.extension == "mjs"]

def _impl(ctx):
    input_sources = copy_files_to_bin_actions(ctx, ctx.files.srcs)
    entry_point = copy_files_to_bin_actions(ctx, _filter_js(ctx.files.entry_point))
    entry_points = copy_files_to_bin_actions(ctx, _filter_js(ctx.files.entry_points))
    inputs = entry_point + entry_points + input_sources + ctx.files.deps

    args = ctx.actions.args()

    # Add user specified arguments *before* rule supplied arguments
    args.add_all(ctx.attr.args)

    # List entry point argument first to save some argv space
    # Rollup doc says
    # When provided as the first options, it is equivalent to not prefix them with --input
    entry_points = _desugar_entry_points(ctx.label.name, ctx.attr.entry_point, ctx.attr.entry_points, inputs).items()

    output_sources = [getattr(ctx.outputs, o) for o in dir(ctx.outputs)]

    # If user requests an output_dir, then use output.dir rather than output.file
    if ctx.attr.output_dir:
        output_sources.append(ctx.actions.declare_directory(ctx.label.name))
        for entry_point in entry_points:
            args.add_joined([entry_point[1], entry_point[0]], join_with = "=")
        args.add_all(["--output.dir", output_sources[0].short_path])
    else:
        args.add(entry_points[0][0])
        args.add_all(["--output.file", output_sources[0].short_path])

    args.add_all(["--format", ctx.attr.format])

    if ctx.attr.silent:
        # Run the rollup binary with the --silent flag
        args.add("--silent")

    if ctx.attr.config_file:
        config_file = copy_file_to_bin_action(ctx, ctx.file.config_file)
        args.add_all(["--config", _output_relative_path(config_file)])
        inputs.append(config_file)

    if (ctx.attr.sourcemap and ctx.attr.sourcemap != "false"):
        args.add_all(["--sourcemap", ctx.attr.sourcemap])

    ctx.actions.run(
        executable = ctx.executable.rollup,
        arguments = [args],
        inputs = depset(
            inputs,
            transitive = [js_lib_helpers.gather_files_from_js_providers(
                targets = ctx.attr.srcs + ctx.attr.deps,
                include_transitive_sources = True,
                include_declarations = False,
                include_npm_linked_packages = True,
            )],
        ),
        outputs = output_sources,
        mnemonic = "Rollup",
        env = {
            "BAZEL_BINDIR": ctx.bin_dir.path,
            "COMPILATION_MODE": ctx.var["COMPILATION_MODE"],
        },
    )

    npm_linked_packages = js_lib_helpers.gather_npm_linked_packages(
        srcs = ctx.attr.srcs,
        deps = [],
    )

    npm_package_store_deps = js_lib_helpers.gather_npm_package_store_deps(
        # Since we're bundling, only propagate `data` npm packages to the direct dependencies of
        # downstream linked `npm_package` targets instead of the common `data` and `deps` pattern.
        targets = ctx.attr.data,
    )

    output_sources_depset = depset(output_sources)

    runfiles = js_lib_helpers.gather_runfiles(
        ctx = ctx,
        sources = output_sources_depset,
        data = ctx.attr.data,
        # Since we're bundling, we don't propogate any transitive runfiles from dependencies
        deps = [],
    )

    return [
        DefaultInfo(
            files = output_sources_depset,
            runfiles = runfiles,
        ),
        js_info(
            npm_linked_package_files = npm_linked_packages.direct_files,
            npm_linked_packages = npm_linked_packages.direct,
            npm_package_store_deps = npm_package_store_deps,
            sources = output_sources_depset,
            # Since we're bundling, we don't propogate linked npm packages from dependencies since
            # they are bundled and the dependencies are dropped. If a subset of linked npm
            # dependencies are not bundled it is up the the user to re-specify these in `data` if
            # they are runtime dependencies to progagate to binary rules or `srcs` if they are to be
            # propagated to downstream build targets.
            transitive_npm_linked_package_files = npm_linked_packages.direct_files,
            transitive_npm_linked_packages = npm_linked_packages.direct,
            # Since we're bundling, we don't propogate any transitive sources from dependencies
            transitive_sources = output_sources_depset,
        ),
    ]

lib = struct(
    implementation = _impl,
    attrs = _ATTRS,
    outputs = _rollup_outs,
)

# for stardoc
rollup = rule(
    implementation = lib.implementation,
    attrs = lib.attrs,
    outputs = lib.outputs,
    toolchains = COPY_FILE_TO_BIN_TOOLCHAINS,
)
