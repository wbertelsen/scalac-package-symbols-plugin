#!/bin/bash

set -eu
set -o pipefail

bazel build //...
