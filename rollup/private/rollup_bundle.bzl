"rollup_bundle"
load("@aspect_bazel_lib//lib:copy_to_bin.bzl", "copy_file_to_bin_action", "copy_files_to_bin_actions")

_ATTRS = {
    "args": attr.string_list(
        doc = """Command line arguments to pass to Rollup. Can be used to override config file settings.
These argument passed on the command line before arguments that are added by the rule.
Run `bazel` with `--subcommands` to see what Rollup CLI command line was invoked.
See the <a href="https://rollupjs.org/guide/en/#command-line-flags">Rollup CLI docs</a> for a complete list of supported arguments.""",
        default = [],
    ),
    "config_file": attr.label(
        doc = """A `rollup.config.js` file
Passed to the `--config` option, see [the config doc](https://rollupjs.org/guide/en/#configuration-files)
If not set, a default basic Rollup config is used.
""",
        allow_single_file = True,
        default = "//packages/rollup:rollup.config.js",
    ),
    "deps": attr.label_list(
        doc = """Other libraries that are required by the code, or by the rollup.config.js""",
    ),
    "entry_point": attr.label(
        doc = """The bundle's entry point (e.g. your main.js or app.js or index.js).
This is just a shortcut for the `entry_points` attribute with a single output chunk named the same as the rule.
For example, these are equivalent:
```python
rollup_bundle(
    name = "bundle",
    entry_point = "index.js",
)
```
```python
rollup_bundle(
    name = "bundle",
    entry_points = {
        "index.js": "bundle"
    }
)
```
If `rollup_bundle` is used on a `ts_library`, the `rollup_bundle` rule handles selecting the correct outputs from `ts_library`.
In this case, `entry_point` can be specified as the `.ts` file and `rollup_bundle` will handle the mapping to the `.mjs` output file.
For example:
```python
ts_library(
    name = "foo",
    srcs = [
        "foo.ts",
        "index.ts",
    ],
)
rollup_bundle(
    name = "bundle",
    deps = [ "foo" ],
    entry_point = "index.ts",
)
```
""",
        allow_single_file = True,
    ),
    "entry_points": attr.label_keyed_string_dict(
        doc = """The bundle's entry points (e.g. your main.js or app.js or index.js).
Passed to the [`--input` option](https://github.com/rollup/rollup/blob/master/docs/999-big-list-of-options.md#input) in Rollup.
Keys in this dictionary are labels pointing to .js entry point files.
Values are the name to be given to the corresponding output chunk.
Either this attribute or `entry_point` must be specified, but not both.
""",
        allow_files = True,
    ),
    "format": attr.string(
        doc = """Specifies the format of the generated bundle. One of the following:
- `amd`: Asynchronous Module Definition, used with module loaders like RequireJS
- `cjs`: CommonJS, suitable for Node and other bundlers
- `esm`: Keep the bundle as an ES module file, suitable for other bundlers and inclusion as a `<script type=module>` tag in modern browsers
- `iife`: A self-executing function, suitable for inclusion as a `<script>` tag. (If you want to create a bundle for your application, you probably want to use this.)
- `umd`: Universal Module Definition, works as amd, cjs and iife all in one
- `system`: Native format of the SystemJS loader
""",
        values = ["amd", "cjs", "esm", "iife", "umd", "system"],
        default = "esm",
    ),
    "output_dir": attr.bool(
        doc = """Whether to produce a directory output.
We will use the [`--output.dir` option](https://github.com/rollup/rollup/blob/master/docs/999-big-list-of-options.md#outputdir) in rollup
rather than `--output.file`.
If the program produces multiple chunks, you must specify this attribute.
Otherwise, the outputs are assumed to be a single file.
""",
    ),
    "rollup": attr.label(
        doc = "Target that executes the rollup binary",
        executable = True,
        cfg = "exec",
        default = "@rollup"
    ),
    "is_windows": attr.bool(
        doc = "Internal use only."
    ),
    "silent": attr.bool(
        doc = """Whether to execute the rollup binary with the --silent flag, defaults to False.
Using --silent can cause rollup to [ignore errors/warnings](https://github.com/rollup/rollup/blob/master/docs/999-big-list-of-options.md#onwarn) 
which are only surfaced via logging.  Since bazel expects printing nothing on success, setting silent to True
is a more Bazel-idiomatic experience, however could cause rollup to drop important warnings.
""",
    ),
    "silent_on_success": attr.bool(
        doc = """Even stronger than --silent, defaults to False.
Since the build still emits some texted, even when passed --silent, this uses the same flag as npm_package_bin to
supress all output on sucess.
""",
    ),
    "sourcemap": attr.string(
        doc = """Whether to produce sourcemaps.
Passed to the [`--sourcemap` option](https://github.com/rollup/rollup/blob/master/docs/999-big-list-of-options.md#outputsourcemap") in Rollup
""",
        default = "inline",
        values = ["inline", "hidden", "true", "false"],
    ),
    "srcs": attr.label_list(
        doc = """Non-entry point JavaScript source files from the workspace.
You must not repeat file(s) passed to entry_point/entry_points.
""",
        # Don't try to constrain the filenames, could be json, svg, whatever
        allow_files = True,
    ),
}

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
            fail("keys in rollup_bundle#entry_points must provide one file, but %s has %s" % (entry_point.label, len(f)))
        result[_resolve_js_input(f[0], inputs)] = name
    return result

def _resolve_js_input(f, inputs):
    if f.extension == "js" or f.extension == "mjs":
        return f

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

    srcs = copy_files_to_bin_actions(ctx, ctx.files.srcs, is_windows = ctx.attr.is_windows)
    entry_point = copy_files_to_bin_actions(ctx, _filter_js(ctx.files.entry_point), is_windows = ctx.attr.is_windows)
    entry_points =  copy_files_to_bin_actions(ctx, _filter_js(ctx.files.entry_points), is_windows = ctx.attr.is_windows)
    inputs =  entry_point + entry_points + srcs + ctx.files.deps
    outputs = [getattr(ctx.outputs, o) for o in dir(ctx.outputs)]

    args = ctx.actions.args()

    # Add user specified arguments *before* rule supplied arguments
    args.add_all(ctx.attr.args)


    # List entry point argument first to save some argv space
    # Rollup doc says
    # When provided as the first options, it is equivalent to not prefix them with --input
    entry_points = _desugar_entry_points(ctx.label.name, ctx.attr.entry_point, ctx.attr.entry_points, inputs).items()


    # If user requests an output_dir, then use output.dir rather than output.file
    if ctx.attr.output_dir:
        outputs.append(ctx.actions.declare_directory(ctx.label.name))
        for entry_point in entry_points:
            args.add_joined([entry_point[1], entry_point[0]], join_with = "=")
        args.add_all(["--output.dir", outputs[0].short_path])
    else:
        args.add(entry_points[0][0])
        args.add_all(["--output.file", outputs[0].short_path])

    args.add_all(["--format", ctx.attr.format])


    if ctx.attr.silent:
        # Run the rollup binary with the --silent flag
        args.add("--silent")


    if ctx.attr.config_file:
        config_file = copy_file_to_bin_action(ctx, ctx.file.config_file, is_windows = ctx.attr.is_windows)
        args.add_all(["--config", config_file.short_path])
        inputs.append(config_file)

    if (ctx.attr.sourcemap and ctx.attr.sourcemap != "false"):
        args.add_all(["--sourcemap", ctx.attr.sourcemap])

    ctx.actions.run(
        executable = ctx.executable.rollup,
        arguments = [args],
        inputs = inputs,
        outputs = outputs,
        mnemonic = "Rollup",
        env = {
            "BAZEL_BINDIR": ctx.bin_dir.path,
            "COMPILATION_MODE": ctx.var["COMPILATION_MODE"]
        }
    )
    return DefaultInfo(files = depset(outputs))


lib = struct(    
    implementation = _impl,
    attrs = _ATTRS,
    outputs = _rollup_outs
)