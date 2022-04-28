# Declare the local Bazel workspace.
workspace(name = "aspect_rules_rollup")

# Fetch deps needed only locally for development
load(":internal_deps.bzl", "rules_rollup_internal_deps")

rules_rollup_internal_deps()

# Fetch dependencies which users need as well
load("//rollup:repositories.bzl", "rollup_register_toolchains", "rules_rollup_dependencies")

rules_rollup_dependencies()

rollup_register_toolchains()

# Set-up rules_js
load("@aspect_rules_js//js:repositories.bzl", "rules_js_dependencies")

rules_js_dependencies()

load("@rules_nodejs//nodejs:repositories.bzl", "nodejs_register_toolchains")

nodejs_register_toolchains(
    name = "nodejs",
    node_version = "16.9.0",
)

load("@aspect_bazel_lib//lib:repositories.bzl", "DEFAULT_YQ_VERSION", "register_yq_toolchains")

register_yq_toolchains(
    version = DEFAULT_YQ_VERSION,
)

load("@aspect_rules_js//js:npm_import.bzl", "translate_pnpm_lock")

translate_pnpm_lock(
    name = "npm",
    enable_lifecycle_hooks = False,
    pnpm_lock = "//example:pnpm-lock.yaml",
)

load("@npm//:repositories.bzl", "npm_repositories")

npm_repositories()

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
