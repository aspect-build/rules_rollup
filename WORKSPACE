# Declare the local Bazel workspace.
workspace(name = "aspect_rules_rollup")

# Fetch deps needed only locally for development
load(":internal_deps.bzl", "rules_rollup_internal_deps")

rules_rollup_internal_deps()


# Fetch dependencies which users need as well
load("//rollup:repositories.bzl", "rules_rollup_dependencies")

rules_rollup_dependencies()

load("//rollup:configure.bzl", "rollup_register_toolchains")

rollup_register_toolchains()


# Set-up rules_js
load("@aspect_rules_js//js:repositories.bzl", "js_dependencies")

js_dependencies()

load("@aspect_rules_js//js:configure.bzl", "js_configure")

js_configure()


# Generates rollup/private/versions/v2.70.2/npm.bzl
load("@aspect_rules_js//js:npm_import.bzl", "translate_pnpm_lock")

translate_pnpm_lock(
    name = "rollup_npm_deps",
    pnpm_lock = "//rollup/private/versions/v2.70.2:pnpm-lock.yaml",
)

# For running our own unit tests
load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

############################################
# Gazelle, for generating bzl_library targets
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")
load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

go_rules_dependencies()

go_register_toolchains(version = "1.17.2")

gazelle_dependencies()
