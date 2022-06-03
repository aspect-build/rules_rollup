"@generated by @aspect_rules_js//npm/private:translate_pnpm_lock.bzl from pnpm lock file @//:pnpm-lock.yaml"

# buildifier: disable=bzl-visibility
load("@aspect_rules_js//npm/private:linked_npm_packages.bzl", "linked_npm_packages")
load("@npm__rollup__2.70.2__links//:defs.bzl", link_0 = "link_npm_package")

def link_all_npm_packages(name = "node_modules"):
    """Generated list of link_npm_package() target generators and first-party linked packages corresponding to the packages in @//:pnpm-lock.yaml

    Args:
        name: name of catch all target to generate for all packages linked
    """
    root_package = ""
    link_packages = [""]
    is_root = native.package_name() == root_package
    is_direct = native.package_name() in link_packages
    if not is_root and not is_direct:
        msg = "The link_all_npm_packages() macro loaded from @npm//:defs.bzl and called in bazel package '%s' may only be called in the bazel package(s) corresponding to the root package '' and packages ['']" % native.package_name()
        fail(msg)
    direct_targets = []
    scoped_direct_targets = {}

    direct_targets.append(link_0(name = "{}/rollup".format(name), direct = None, fail_if_no_link = False))

    for scope, scoped_targets in scoped_direct_targets.items():
        linked_npm_packages(
            name = "{}/{}".format(name, scope),
            srcs = [t for t in scoped_targets if t],
            tags = ["manual"],
            visibility = ["//visibility:public"],
        )

    linked_npm_packages(
        name = name,
        srcs = [t for t in direct_targets if t],
        tags = ["manual"],
        visibility = ["//visibility:public"],
    )
