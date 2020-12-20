# WORKSPACE
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

skylib_version = "1.0.3"

http_archive(
    name = "bazel_skylib",
    sha256 = "1c531376ac7e5a180e0237938a2536de0c54d93f5c278634818e0efc952dd56c",
    type = "tar.gz",
    url = "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/{}/bazel-skylib-{}.tar.gz".format(skylib_version, skylib_version),
)

rules_scala_version = "cdaccd5fe4e13791b3df5770ffaf6f16463fa5c5"

http_archive(
    name = "io_bazel_rules_scala",
    sha256 = "b19603fabd7e7b2fa252146f6fe1c1e0c2761e8e036323a1795f36f35023d364",
    strip_prefix = "rules_scala-%s" % rules_scala_version,
    type = "zip",
    url = "https://github.com/bazelbuild/rules_scala/archive/%s.zip" % rules_scala_version,
)

# Stores Scala version and other configuration
# 2.12 is a default version, other versions can be use by passing them explicitly:
# scala_config(scala_version = "2.11.12")
load("@io_bazel_rules_scala//:scala_config.bzl", "scala_config")

scala_config()

load("@io_bazel_rules_scala//scala:scala.bzl", "scala_repositories")

scala_repositories()

load("@io_bazel_rules_scala//scala:toolchains.bzl", "scala_register_toolchains")

scala_register_toolchains()

# JUnit 4
load("@io_bazel_rules_scala//testing:junit.bzl", "junit_repositories", "junit_toolchain")

junit_repositories()

junit_toolchain()

# ScalaTest
load("@io_bazel_rules_scala//testing:scalatest.bzl", "scalatest_repositories", "scalatest_toolchain")

scalatest_repositories()

scalatest_toolchain()

# Specs2 with Junit
load("@io_bazel_rules_scala//testing:specs2_junit.bzl", "specs2_junit_repositories", "specs2_junit_toolchain")

specs2_junit_repositories()

specs2_junit_toolchain()

# 3rdparty
load("//3rdparty:workspace.bzl", "maven_dependencies")

maven_dependencies()

load("//3rdparty:target_file.bzl", "build_external_workspace")

build_external_workspace(name = "third_party")
