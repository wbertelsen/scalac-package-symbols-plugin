#!/bin/bash

set -eu
set -o pipefail

bazel build //src/jvm/com/wbertelsen/packagesymbols/scalac/plugin/used:assemble-maven
bazel build //src/jvm/com/wbertelsen/packagesymbols/scalac/plugin/exported:assemble-maven
