"wrapper macro for rollup rule"

load("@aspect_bazel_lib//lib:copy_to_bin.bzl", "COPY_FILE_TO_BIN_TOOLCHAINS")
load("@aspect_bazel_lib//lib:directory_path.bzl", "directory_path")
load("@aspect_rules_js//js:defs.bzl", "js_binary")
load("//rollup/private:rollup.bzl", rollup_lib = "lib")

_rollup = rule(
    implementation = rollup_lib.implementation,
    attrs = rollup_lib.attrs,
    outputs = rollup_lib.outputs,
    toolchains = COPY_FILE_TO_BIN_TOOLCHAINS,
)

def rollup(
        name,
        node_modules,
        entry_point = None,
        entry_points = {},
        srcs = [],
        deps = [],
        args = [],
        config_file = "@aspect_rules_rollup//rollup:rollup.config",
        format = "esm",
        output_dir = False,
        silent = False,
        silent_on_success = False,
        sourcemap = "inline",
        data = [],
        **kwargs):
    """Runs the rollup bundler under Bazel

    For further information about rollup, see https://rollupjs.org/

    Args:
        name: A unique name for this target.

        node_modules: Label pointing to the linked node_modules target where the `rollup` is linked, e.g. `//:node_modules`.

            `rollup` must be linked into the node_modules supplied.

        entry_point: The bundle's entry point (e.g. your main.js or app.js or index.js).

            This is just a shortcut for the `entry_points` attribute with a single output chunk named the same as the rule.

            For example, these are equivalent:

            ```python
            rollup(
                name = "bundle",
                node_modules = "//:node_modules",
                entry_point = "index.js",
            )
            ```

            ```python
            rollup(
                name = "bundle",
                node_modules = "//:node_modules",
                entry_points = {
                    "index.js": "bundle"
                }
            )
            ```

            If `rollup` is used on a `ts_library`, the `rollup` rule handles selecting the correct outputs from `ts_library`.

            In this case, `entry_point` can be specified as the `.ts` file and `rollup` will handle the mapping to the `.mjs` output file.

            For example:

            ```python
            ts_library(
                name = "foo",
                srcs = [
                    "foo.ts",
                    "index.ts",
                ],
            )
            rollup(
                name = "bundle",
                node_modules = "//:node_modules",
                deps = [ "foo" ],
                entry_point = "index.ts",
            )
            ```

        entry_points: The bundle's entry points (e.g. your main.js or app.js or index.js).

            Passed to the [`--input` option](https://github.com/rollup/rollup/blob/master/docs/999-big-list-of-options.md#input) in Rollup.

            Keys in this dictionary are labels pointing to .js entry point files.

            Values are the name to be given to the corresponding output chunk.

            Either this attribute or `entry_point` must be specified, but not both.

        srcs: Non-entry point JavaScript source files from the workspace.

            You must not repeat file(s) passed to entry_point/entry_points.

        deps: Other libraries that are required by the code, or by the rollup.config.js.

        args: Command line arguments to pass to Rollup. Can be used to override config file settings.

            These argument passed on the command line before arguments that are added by the rule.

            Run `bazel` with `--subcommands` to see what Rollup CLI command line was invoked.

            See the <a href="https://rollupjs.org/guide/en/#command-line-flags">Rollup CLI docs</a> for a complete list of supported arguments.

        config_file: A `rollup.config.js` file

            Passed to the `--config` option, see [the config doc](https://rollupjs.org/guide/en/#configuration-files)

            If not set, a default basic Rollup config is used.

        format: Specifies the format of the generated bundle. One of the following:

            - `amd`: Asynchronous Module Definition, used with module loaders like RequireJS
            - `cjs`: CommonJS, suitable for Node and other bundlers
            - `esm`: Keep the bundle as an ES module file, suitable for other bundlers and inclusion as a `<script type=module>` tag in modern browsers
            - `iife`: A self-executing function, suitable for inclusion as a `<script>` tag. (If you want to create a bundle for your application, you probably want to use this.)
            - `umd`: Universal Module Definition, works as amd, cjs and iife all in one
            - `system`: Native format of the SystemJS loader

        output_dir: Whether to produce a directory output.

            We will use the [`--output.dir` option](https://github.com/rollup/rollup/blob/master/docs/999-big-list-of-options.md#outputdir) in rollup rather than `--output.file`.

            If the program produces multiple chunks, you must specify this attribute.

            Otherwise, the outputs are assumed to be a single file.

        silent: Whether to execute the rollup binary with the --silent flag, defaults to False.

            Using --silent can cause rollup to [ignore errors/warnings](https://github.com/rollup/rollup/blob/master/docs/999-big-list-of-options.md#onwarn)
            which are only surfaced via logging.  Since bazel expects printing nothing on success, setting silent to True
            is a more Bazel-idiomatic experience, however could cause rollup to drop important warnings.

        silent_on_success: Even stronger than --silent, defaults to False.

            Since the build still emits some texted, even when passed --silent, this uses the same flag as npm_package_bin to
            supress all output on success.

        sourcemap: Whether to produce sourcemaps.

            Passed to the [`--sourcemap` option](https://github.com/rollup/rollup/blob/master/docs/999-big-list-of-options.md#outputsourcemap") in Rollup

        data: Runtime dependencies to include in binaries/tests that depend on this target.

            The transitive npm dependencies, transitive sources, default outputs and runfiles of targets in the `data` attribute
            are added to the runfiles of this target. They should appear in the '*.runfiles' area of any executable which has
            a runtime dependency on this target.

            If this list contains linked npm packages, npm package store targets or other targets that provide
            `JsInfo`, `NpmPackageStoreInfo` providers are gathered from `JsInfo`. This is done directly from
            the `npm_package_store_deps` field of these. For linked npm package targets, the underlying
            `npm_package_store` target(s) that back the links is used. Gathered `NpmPackageStoreInfo`
            providers are propagated to the direct dependencies of downstream linked `npm_package` targets.

            NB: Linked npm package targets that are "dev" dependencies do not forward their underlying
            `npm_package_store` target(s) through `npm_package_store_deps` and will therefore not be
            propagated to the direct dependencies of downstream linked `npm_package` targets. npm packages
            that come in from `npm_translate_lock` are considered "dev" dependencies if they are have
            `dev: true` set in the pnpm lock file. This should be all packages that are only listed as
            "devDependencies" in all `package.json` files within the pnpm workspace. This behavior is
            intentional to mimic how `devDependencies` work in published npm packages.

        **kwargs: Other common arguments such as `tags` and `visibility`
    """
    rollup_entry_point = "_{}_rollup_entry_point".format(name)
    directory_path(
        name = rollup_entry_point,
        directory = "{}/rollup/dir".format(node_modules),
        path = "dist/bin/rollup",
    )

    rollup = "_{}_rollup_binary".format(name)
    js_binary(
        name = rollup,
        data = ["{}/rollup".format(node_modules)],
        entry_point = rollup_entry_point,
    )

    _rollup(
        name = name,
        rollup = rollup,
        entry_point = entry_point,
        entry_points = entry_points,
        srcs = srcs,
        deps = deps,
        args = args,
        config_file = config_file,
        format = format,
        output_dir = output_dir,
        silent = silent,
        silent_on_success = silent_on_success,
        sourcemap = sourcemap,
        data = data,
        **kwargs
    )
