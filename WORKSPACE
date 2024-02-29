# Declare the local Bazel workspace.
workspace(name = "aspect_rules_rollup")

# Fetch deps needed only locally for development
load(":internal_deps.bzl", "rules_rollup_internal_deps")

rules_rollup_internal_deps()

load("//rollup:dependencies.bzl", "rules_rollup_dependencies")

# Fetch dependencies which users need as well
rules_rollup_dependencies()

load("@aspect_rules_js//js:repositories.bzl", "rules_js_dependencies")

rules_js_dependencies()

load("@rules_nodejs//nodejs:repositories.bzl", "nodejs_register_toolchains")

nodejs_register_toolchains(
    name = "nodejs",
    node_version = "16.9.0",
)

load("@aspect_rules_js//npm:npm_import.bzl", "npm_translate_lock")

npm_translate_lock(
    name = "npm",
    npmrc = "//:.npmrc",
    pnpm_lock = "//:pnpm-lock.yaml",
    verify_node_modules_ignored = "//:.bazelignore",
)

load("@npm//:repositories.bzl", "npm_repositories")

npm_repositories()

load("@aspect_bazel_lib//lib:repositories.bzl", "DEFAULT_YQ_VERSION", "aspect_bazel_lib_dependencies", "register_yq_toolchains")

aspect_bazel_lib_dependencies()

register_yq_toolchains(
    version = DEFAULT_YQ_VERSION,
)

# For running our own unit tests
load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

############################################
# Gazelle, for generating bzl_library targets
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains(version = "1.19.3")

gazelle_dependencies()

# Buildifier
load("@buildifier_prebuilt//:deps.bzl", "buildifier_prebuilt_deps")

buildifier_prebuilt_deps()

load("@buildifier_prebuilt//:defs.bzl", "buildifier_prebuilt_register_toolchains")

buildifier_prebuilt_register_toolchains()
