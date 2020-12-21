#!/bin/bash

set -eu
set -o pipefail

bazel run  //src/jvm/com/wbertelsen/packagesymbols/scalac/plugin/used:deploy-maven -- release
bazel run  //src/jvm/com/wbertelsen/packagesymbols/scalac/plugin/exported:deploy-maven -- release
