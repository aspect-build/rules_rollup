<!-- Generated with Stardoc: http://skydoc.bazel.build -->

rollup_bundle

<a id="#rollup_bundle"></a>

## rollup_bundle

<pre>
rollup_bundle(<a href="#rollup_bundle-name">name</a>, <a href="#rollup_bundle-args">args</a>, <a href="#rollup_bundle-config_file">config_file</a>, <a href="#rollup_bundle-deps">deps</a>, <a href="#rollup_bundle-entry_point">entry_point</a>, <a href="#rollup_bundle-entry_points">entry_points</a>, <a href="#rollup_bundle-format">format</a>, <a href="#rollup_bundle-is_windows">is_windows</a>,
              <a href="#rollup_bundle-output_dir">output_dir</a>, <a href="#rollup_bundle-rollup">rollup</a>, <a href="#rollup_bundle-silent">silent</a>, <a href="#rollup_bundle-silent_on_success">silent_on_success</a>, <a href="#rollup_bundle-sourcemap">sourcemap</a>, <a href="#rollup_bundle-srcs">srcs</a>)
</pre>

FIXME: add docs

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="rollup_bundle-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="rollup_bundle-args"></a>args |  Command line arguments to pass to Rollup. Can be used to override config file settings. These argument passed on the command line before arguments that are added by the rule. Run <code>bazel</code> with <code>--subcommands</code> to see what Rollup CLI command line was invoked. See the &lt;a href="https://rollupjs.org/guide/en/#command-line-flags"&gt;Rollup CLI docs&lt;/a&gt; for a complete list of supported arguments.   | List of strings | optional | [] |
| <a id="rollup_bundle-config_file"></a>config_file |  A <code>rollup.config.js</code> file Passed to the <code>--config</code> option, see [the config doc](https://rollupjs.org/guide/en/#configuration-files) If not set, a default basic Rollup config is used.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | //packages/rollup:rollup.config.js |
| <a id="rollup_bundle-deps"></a>deps |  Other libraries that are required by the code, or by the rollup.config.js   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="rollup_bundle-entry_point"></a>entry_point |  The bundle's entry point (e.g. your main.js or app.js or index.js). This is just a shortcut for the <code>entry_points</code> attribute with a single output chunk named the same as the rule. For example, these are equivalent: <pre><code>python rollup_bundle(     name = "bundle",     entry_point = "index.js", ) </code></pre> <pre><code>python rollup_bundle(     name = "bundle",     entry_points = {         "index.js": "bundle"     } ) </code></pre> If <code>rollup_bundle</code> is used on a <code>ts_library</code>, the <code>rollup_bundle</code> rule handles selecting the correct outputs from <code>ts_library</code>. In this case, <code>entry_point</code> can be specified as the <code>.ts</code> file and <code>rollup_bundle</code> will handle the mapping to the <code>.mjs</code> output file. For example: <pre><code>python ts_library(     name = "foo",     srcs = [         "foo.ts",         "index.ts",     ], ) rollup_bundle(     name = "bundle",     deps = [ "foo" ],     entry_point = "index.ts", ) </code></pre>   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |
| <a id="rollup_bundle-entry_points"></a>entry_points |  The bundle's entry points (e.g. your main.js or app.js or index.js). Passed to the [<code>--input</code> option](https://github.com/rollup/rollup/blob/master/docs/999-big-list-of-options.md#input) in Rollup. Keys in this dictionary are labels pointing to .js entry point files. Values are the name to be given to the corresponding output chunk. Either this attribute or <code>entry_point</code> must be specified, but not both.   | <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: Label -> String</a> | optional | {} |
| <a id="rollup_bundle-format"></a>format |  Specifies the format of the generated bundle. One of the following: - <code>amd</code>: Asynchronous Module Definition, used with module loaders like RequireJS - <code>cjs</code>: CommonJS, suitable for Node and other bundlers - <code>esm</code>: Keep the bundle as an ES module file, suitable for other bundlers and inclusion as a <code>&lt;script type=module&gt;</code> tag in modern browsers - <code>iife</code>: A self-executing function, suitable for inclusion as a <code>&lt;script&gt;</code> tag. (If you want to create a bundle for your application, you probably want to use this.) - <code>umd</code>: Universal Module Definition, works as amd, cjs and iife all in one - <code>system</code>: Native format of the SystemJS loader   | String | optional | "esm" |
| <a id="rollup_bundle-is_windows"></a>is_windows |  Internal use only.   | Boolean | optional | False |
| <a id="rollup_bundle-output_dir"></a>output_dir |  Whether to produce a directory output. We will use the [<code>--output.dir</code> option](https://github.com/rollup/rollup/blob/master/docs/999-big-list-of-options.md#outputdir) in rollup rather than <code>--output.file</code>. If the program produces multiple chunks, you must specify this attribute. Otherwise, the outputs are assumed to be a single file.   | Boolean | optional | False |
| <a id="rollup_bundle-rollup"></a>rollup |  Target that executes the rollup binary   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @rollup |
| <a id="rollup_bundle-silent"></a>silent |  Whether to execute the rollup binary with the --silent flag, defaults to False. Using --silent can cause rollup to [ignore errors/warnings](https://github.com/rollup/rollup/blob/master/docs/999-big-list-of-options.md#onwarn)  which are only surfaced via logging.  Since bazel expects printing nothing on success, setting silent to True is a more Bazel-idiomatic experience, however could cause rollup to drop important warnings.   | Boolean | optional | False |
| <a id="rollup_bundle-silent_on_success"></a>silent_on_success |  Even stronger than --silent, defaults to False. Since the build still emits some texted, even when passed --silent, this uses the same flag as npm_package_bin to supress all output on sucess.   | Boolean | optional | False |
| <a id="rollup_bundle-sourcemap"></a>sourcemap |  Whether to produce sourcemaps. Passed to the [<code>--sourcemap</code> option](https://github.com/rollup/rollup/blob/master/docs/999-big-list-of-options.md#outputsourcemap") in Rollup   | String | optional | "inline" |
| <a id="rollup_bundle-srcs"></a>srcs |  Non-entry point JavaScript source files from the workspace. You must not repeat file(s) passed to entry_point/entry_points.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |


<a id="#lib.implementation"></a>

## lib.implementation

<pre>
lib.implementation(<a href="#lib.implementation-ctx">ctx</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="lib.implementation-ctx"></a>ctx |  <p align="center"> - </p>   |  none |


<a id="#lib.outputs"></a>

## lib.outputs

<pre>
lib.outputs(<a href="#lib.outputs-sourcemap">sourcemap</a>, <a href="#lib.outputs-name">name</a>, <a href="#lib.outputs-entry_point">entry_point</a>, <a href="#lib.outputs-entry_points">entry_points</a>, <a href="#lib.outputs-output_dir">output_dir</a>)
</pre>

Supply some labelled outputs in the common case of a single entry point

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="lib.outputs-sourcemap"></a>sourcemap |  <p align="center"> - </p>   |  none |
| <a id="lib.outputs-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="lib.outputs-entry_point"></a>entry_point |  <p align="center"> - </p>   |  none |
| <a id="lib.outputs-entry_points"></a>entry_points |  <p align="center"> - </p>   |  none |
| <a id="lib.outputs-output_dir"></a>output_dir |  <p align="center"> - </p>   |  none |


