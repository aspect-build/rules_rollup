"extensions for bzlmod"

load(":repositories.bzl", "rollup_repositories")

rollup_toolchain = tag_class(attrs = {
    "name": attr.string(doc = "Base name for generated repositories"),
    "rollup_version": attr.string(doc = "Explicit version of rollup."),
    # TODO: support this variant
    # "rollup_version_from": attr.string(doc = "Location of package.json which may have a version for @rollup/core."),
})

def _toolchain_extension(module_ctx):
    registrations = {}
    for mod in module_ctx.modules:
        for toolchain in mod.tags.toolchain:
            if toolchain.name in registrations.keys():
                if toolchain.rollup_version == registrations[toolchain.name]:
                    # No problem to register a matching toolchain twice
                    continue
                fail("Multiple conflicting toolchains declared for name {} ({} and {}".format(
                    toolchain.name,
                    toolchain.rollup_version,
                    registrations[toolchain.name],
                ))
            else:
                registrations[toolchain.name] = toolchain.rollup_version
    for name, rollup_version in registrations.items():
        rollup_repositories(
            name = name,
            rollup_version = rollup_version,
            register = False,
        )

rollup = module_extension(
    implementation = _toolchain_extension,
    tag_classes = {"toolchain": rollup_toolchain},
)
