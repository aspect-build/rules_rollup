# Bazel rules for rollup

This is a pure-starlark distribution which replaces the `@bazel/rollup` npm package.
It's meant for use with aspect-build/rules_js, which has a pnpm-based layout for node_modules.

## Installation

From the release you wish to use:
<https://github.com/aspect-build/rules_rollup/releases>
copy the WORKSPACE snippet into your `WORKSPACE` file.

## Usage

See the [API documentation](./docs/rollup.md) and the example usage in the [example](example/) folder.
Note that the example also relies on code in the `/WORKSPACE` file in the root of this repo.
