<!-- Generated with Stardoc: http://skydoc.bazel.build -->

wrapper macro for rollup rule

<a id="rollup"></a>

## rollup

<pre>
rollup(<a href="#rollup-name">name</a>, <a href="#rollup-node_modules">node_modules</a>, <a href="#rollup-entry_point">entry_point</a>, <a href="#rollup-entry_points">entry_points</a>, <a href="#rollup-srcs">srcs</a>, <a href="#rollup-deps">deps</a>, <a href="#rollup-args">args</a>, <a href="#rollup-config_file">config_file</a>, <a href="#rollup-format">format</a>,
       <a href="#rollup-output_dir">output_dir</a>, <a href="#rollup-silent">silent</a>, <a href="#rollup-silent_on_success">silent_on_success</a>, <a href="#rollup-sourcemap">sourcemap</a>, <a href="#rollup-data">data</a>, <a href="#rollup-kwargs">kwargs</a>)
</pre>

Runs the rollup bundler under Bazel

For further information about rollup, see https://rollupjs.org/


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="rollup-name"></a>name |  A unique name for this target.   |  none |
| <a id="rollup-node_modules"></a>node_modules |  Label pointing to the linked node_modules target where the `rollup` is linked, e.g. `//:node_modules`.<br><br>`rollup` must be linked into the node_modules supplied.   |  none |
| <a id="rollup-entry_point"></a>entry_point |  The bundle's entry point (e.g. your main.js or app.js or index.js).<br><br>This is just a shortcut for the `entry_points` attribute with a single output chunk named the same as the rule.<br><br>For example, these are equivalent:<br><br><pre><code class="language-python">rollup(&#10;    name = "bundle",&#10;    node_modules = "//:node_modules",&#10;    entry_point = "index.js",&#10;)</code></pre><br><br><pre><code class="language-python">rollup(&#10;    name = "bundle",&#10;    node_modules = "//:node_modules",&#10;    entry_points = {&#10;        "index.js": "bundle"&#10;    }&#10;)</code></pre><br><br>If `rollup` is used on a `ts_library`, the `rollup` rule handles selecting the correct outputs from `ts_library`.<br><br>In this case, `entry_point` can be specified as the `.ts` file and `rollup` will handle the mapping to the `.mjs` output file.<br><br>For example:<br><br><pre><code class="language-python">ts_library(&#10;    name = "foo",&#10;    srcs = [&#10;        "foo.ts",&#10;        "index.ts",&#10;    ],&#10;)&#10;rollup(&#10;    name = "bundle",&#10;    node_modules = "//:node_modules",&#10;    deps = [ "foo" ],&#10;    entry_point = "index.ts",&#10;)</code></pre>   |  `None` |
| <a id="rollup-entry_points"></a>entry_points |  The bundle's entry points (e.g. your main.js or app.js or index.js).<br><br>Passed to the [`--input` option](https://github.com/rollup/rollup/blob/master/docs/999-big-list-of-options.md#input) in Rollup.<br><br>Keys in this dictionary are labels pointing to .js entry point files.<br><br>Values are the name to be given to the corresponding output chunk.<br><br>Either this attribute or `entry_point` must be specified, but not both.   |  `{}` |
| <a id="rollup-srcs"></a>srcs |  Non-entry point JavaScript source files from the workspace.<br><br>You must not repeat file(s) passed to entry_point/entry_points.   |  `[]` |
| <a id="rollup-deps"></a>deps |  Other libraries that are required by the code, or by the rollup.config.js.   |  `[]` |
| <a id="rollup-args"></a>args |  Command line arguments to pass to Rollup. Can be used to override config file settings.<br><br>These argument passed on the command line before arguments that are added by the rule.<br><br>Run `bazel` with `--subcommands` to see what Rollup CLI command line was invoked.<br><br>See the <a href="https://rollupjs.org/guide/en/#command-line-flags">Rollup CLI docs</a> for a complete list of supported arguments.   |  `[]` |
| <a id="rollup-config_file"></a>config_file |  A `rollup.config.js` file<br><br>Passed to the `--config` option, see [the config doc](https://rollupjs.org/guide/en/#configuration-files)<br><br>If not set, a default basic Rollup config is used.   |  `"@aspect_rules_rollup//rollup:rollup.config"` |
| <a id="rollup-format"></a>format |  Specifies the format of the generated bundle. One of the following:<br><br>- `amd`: Asynchronous Module Definition, used with module loaders like RequireJS - `cjs`: CommonJS, suitable for Node and other bundlers - `esm`: Keep the bundle as an ES module file, suitable for other bundlers and inclusion as a `<script type=module>` tag in modern browsers - `iife`: A self-executing function, suitable for inclusion as a `<script>` tag. (If you want to create a bundle for your application, you probably want to use this.) - `umd`: Universal Module Definition, works as amd, cjs and iife all in one - `system`: Native format of the SystemJS loader   |  `"esm"` |
| <a id="rollup-output_dir"></a>output_dir |  Whether to produce a directory output.<br><br>We will use the [`--output.dir` option](https://github.com/rollup/rollup/blob/master/docs/999-big-list-of-options.md#outputdir) in rollup rather than `--output.file`.<br><br>If the program produces multiple chunks, you must specify this attribute.<br><br>Otherwise, the outputs are assumed to be a single file.   |  `False` |
| <a id="rollup-silent"></a>silent |  Whether to execute the rollup binary with the --silent flag, defaults to False.<br><br>Using --silent can cause rollup to [ignore errors/warnings](https://github.com/rollup/rollup/blob/master/docs/999-big-list-of-options.md#onwarn) which are only surfaced via logging.  Since bazel expects printing nothing on success, setting silent to True is a more Bazel-idiomatic experience, however could cause rollup to drop important warnings.   |  `False` |
| <a id="rollup-silent_on_success"></a>silent_on_success |  Even stronger than --silent, defaults to False.<br><br>Since the build still emits some texted, even when passed --silent, this uses the same flag as npm_package_bin to supress all output on success.   |  `False` |
| <a id="rollup-sourcemap"></a>sourcemap |  Whether to produce sourcemaps.<br><br>Passed to the [`--sourcemap` option](https://github.com/rollup/rollup/blob/master/docs/999-big-list-of-options.md#outputsourcemap") in Rollup   |  `"inline"` |
| <a id="rollup-data"></a>data |  Runtime dependencies to include in binaries/tests that depend on this target.<br><br>The transitive npm dependencies, transitive sources, default outputs and runfiles of targets in the `data` attribute are added to the runfiles of this target. They should appear in the '*.runfiles' area of any executable which has a runtime dependency on this target.<br><br>If this list contains linked npm packages, npm package store targets or other targets that provide `JsInfo`, `NpmPackageStoreInfo` providers are gathered from `JsInfo`. This is done directly from the `npm_package_store_deps` field of these. For linked npm package targets, the underlying `npm_package_store` target(s) that back the links is used. Gathered `NpmPackageStoreInfo` providers are propagated to the direct dependencies of downstream linked `npm_package` targets.<br><br>NB: Linked npm package targets that are "dev" dependencies do not forward their underlying `npm_package_store` target(s) through `npm_package_store_deps` and will therefore not be propagated to the direct dependencies of downstream linked `npm_package` targets. npm packages that come in from `npm_translate_lock` are considered "dev" dependencies if they are have `dev: true` set in the pnpm lock file. This should be all packages that are only listed as "devDependencies" in all `package.json` files within the pnpm workspace. This behavior is intentional to mimic how `devDependencies` work in published npm packages.   |  `[]` |
| <a id="rollup-kwargs"></a>kwargs |  Other common arguments such as `tags` and `visibility`   |  none |


