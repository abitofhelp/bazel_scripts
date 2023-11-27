# dynamic_repo_tags_providing_rule.bzl: It contains a rule that determines the value of the
# VERSION environment variable in the Bazel build's context and creates a proper repository
# tag from it. The tag is written to a temporary file that is managed by Bazel build.  A
# second tag is written to this file with the version being replaced by 'latest'.

def _impl(ctx):
    out = ctx.actions.declare_file(ctx.label.name + ".txt")
    ctx.actions.write(
        output = out,
        content = "{}:latest\n{}:v{}\n".format(ctx.attr.root_name, ctx.attr.root_name, ctx.configuration.default_shell_env.get("VERSION", "0.0.0")),
    )
    return [DefaultInfo(files = depset([out]))]

dynamic_repo_tags = rule(
    implementation = _impl,
    attrs = {
        "root_name": attr.string(mandatory = True),
    },
)
