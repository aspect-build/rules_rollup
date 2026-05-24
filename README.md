# Bazel rules for rollup

> [!NOTE]
> This repository uses the [Aspect CLI](https://github.com/aspect-build/aspect-cli) for CI and local development.
> See the [docs](https://docs.aspect.build/cli/overview) and [install instructions](https://docs.aspect.build/cli/install) to get started.

This is a pure-starlark distribution which replaces the `@bazel/rollup` npm package.
It's meant for use with aspect-build/rules_js, which has a pnpm-based layout for node_modules.

## Installation

From the release you wish to use:
<https://github.com/aspect-build/rules_rollup/releases>
copy the WORKSPACE snippet into your `WORKSPACE` file.

## Usage

See the [API documentation](./docs/rollup.md) and the example usage in the [example](https://github.com/aspect-build/rules_rollup/tree/main/example/) folder.
Note that the example also relies on code in the `/WORKSPACE` file in the root of this repo.
