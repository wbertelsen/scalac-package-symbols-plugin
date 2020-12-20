# scala-buildgen-plugin
scalac plugin for detecting used/exported symbols of scala sources,
forked from https://github.com/foursquare/fsqio/tree/master/src/jvm/io/fsq/buildgen/plugin 

(Copyright 2020 Foursquare Labs Inc under the [Apache 2.0 License](https://github.com/foursquare/fsqio/blob/master/LICENSE.md))

This is useful for generating BUILD files for build systems that require explicit source dependencies such as [bazel](https://bazel.build/) and [pants](https://v1.pantsbuild.org/index.html)
