########################################################################################################################
# dynamic_repo_tags_providing_rule.bzl:
# Copyright (c) 1999-2023 A Bit of Help, Inc.
#
# This file contains a rule that determines the value of the VERSION environment variable in
# Bazel build's context and creates a proper repository tag from it. The tag is written to a temporary
# file that is managed by Bazel build.  A second tag is written to this file with the version being
# replaced by 'latest'.
#
# You can set the VERSION environment variable to any string that meets the constraints for an OCI image name.
# I've configured my Makefile to set the version to one of the following:
#
#   (1) Uncomment the following two lines to use the version from a file named version.env.
#   contains the following: VERSION="5.2.0"
#   include scripts/version.env
#   export
#   -------------------------------------------------------------------------------
#   (2) Uncomment the following to use GIT id value as the version.
#   VERSION=$(shell git describe --always)
#   -------------------------------------------------------------------------------
#
# USAGE:
#   1) Add the following load() to your WORKSPACE or MODULE.bazel file.  It assumes that
#      you have a directory named "scripts" at the root of your project and that the folder
#      contains an empty BUILD.bazel file.
#
#       load("//scripts:dynamic_repo_tags_providing_rule.bzl", "dynamic_repo_tags")
#
#   2) In your BUILD.bazel file, set the rule's root_name for your image without any ':xxxx' extension.
#
#        dynamic_repo_tags(
#            name = "generate_repository_tags",
#            root_name = "abcd.azurecr.io/project-service-linux-x86_64",
#        )
#
#   3) In your BUILD.bazel file, set the repo_tags to reference the dynamic_repo_tags.
#        oci_tarball(
#            name = "server_tarball",
#            image = ":server_oci_image",
#            repo_tags = "generate_repository_tags",   # <<<<<<<<<-------------------
#        )
#
#   4) Build  your OCI image, which should generate two tagged images, such as the following example:
#       "abcd.azurecr.io/project-service-linux-x86_64:latest"
#       "abcd.azurecr.io/project-service-linux-x86_64:v5.0.2"
########################################################################################################################

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
