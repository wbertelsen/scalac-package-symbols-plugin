#!/bin/bash

set -eu
set -o pipefail

bazel test --cache_test_results=no --test_summary=detailed --test_output=all --test_arg=-test.v  //...
