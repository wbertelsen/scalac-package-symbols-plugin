# Do not edit. bazel-deps autogenerates this file from.
_JAVA_LIBRARY_TEMPLATE = """
java_library(
  name = "{name}",
  exports = [
      {exports}
  ],
  runtime_deps = [
    {runtime_deps}
  ],
  visibility = [
      "{visibility}"
  ]
)\n"""

_SCALA_IMPORT_TEMPLATE = """
scala_import(
    name = "{name}",
    exports = [
        {exports}
    ],
    jars = [
        {jars}
    ],
    runtime_deps = [
        {runtime_deps}
    ],
    visibility = [
        "{visibility}"
    ]
)
"""

_SCALA_LIBRARY_TEMPLATE = """
scala_library(
    name = "{name}",
    exports = [
        {exports}
    ],
    runtime_deps = [
        {runtime_deps}
    ],
    visibility = [
        "{visibility}"
    ]
)
"""


def _build_external_workspace_from_opts_impl(ctx):
    build_header = ctx.attr.build_header
    separator = ctx.attr.separator
    target_configs = ctx.attr.target_configs

    result_dict = {}
    for key, cfg in target_configs.items():
      build_file_to_target_name = key.split(":")
      build_file = build_file_to_target_name[0]
      target_name = build_file_to_target_name[1]
      if build_file not in result_dict:
        result_dict[build_file] = []
      result_dict[build_file].append(cfg)

    for key, file_entries in result_dict.items():
      build_file_contents = build_header + '\n\n'
      for build_target in file_entries:
        entry_map = {}
        for entry in build_target:
          elements = entry.split(separator)
          build_entry_key = elements[0]
          if elements[1] == "L":
            entry_map[build_entry_key] = [e for e in elements[2::] if len(e) > 0]
          elif elements[1] == "B":
            entry_map[build_entry_key] = (elements[2] == "true" or elements[2] == "True")
          else:
            entry_map[build_entry_key] = elements[2]

        exports_str = ""
        for e in entry_map.get("exports", []):
          exports_str += "\"" + e + "\",\n"

        jars_str = ""
        for e in entry_map.get("jars", []):
          jars_str += "\"" + e + "\",\n"

        runtime_deps_str = ""
        for e in entry_map.get("runtimeDeps", []):
          runtime_deps_str += "\"" + e + "\",\n"

        name = entry_map["name"].split(":")[1]
        if entry_map["lang"] == "java":
            build_file_contents += _JAVA_LIBRARY_TEMPLATE.format(name = name, exports=exports_str, runtime_deps=runtime_deps_str, visibility=entry_map["visibility"])
        elif entry_map["lang"].startswith("scala") and entry_map["kind"] == "import":
            build_file_contents += _SCALA_IMPORT_TEMPLATE.format(name = name, exports=exports_str, jars=jars_str, runtime_deps=runtime_deps_str, visibility=entry_map["visibility"])
        elif entry_map["lang"].startswith("scala") and entry_map["kind"] == "library":
            build_file_contents += _SCALA_LIBRARY_TEMPLATE.format(name = name, exports=exports_str, runtime_deps=runtime_deps_str, visibility=entry_map["visibility"])
        else:
            print(entry_map)

      ctx.file(ctx.path(key + "/BUILD"), build_file_contents, False)
    return None

build_external_workspace_from_opts = repository_rule(
    attrs = {
        "target_configs": attr.string_list_dict(mandatory = True),
        "separator": attr.string(mandatory = True),
        "build_header": attr.string(mandatory = True),
    },
    implementation = _build_external_workspace_from_opts_impl
)




def build_header():
 return """load("@io_bazel_rules_scala//scala:scala_import.bzl", "scala_import")
load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library")"""

def list_target_data_separator():
 return "|||"

def list_target_data():
    return {
"com/fasterxml/jackson/core:jackson_annotations": ["lang||||||java","name||||||//com/fasterxml/jackson/core:jackson_annotations","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/com/fasterxml/jackson/core/jackson_annotations","runtimeDeps|||L|||","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"com/fasterxml/jackson/core:jackson_core": ["lang||||||java","name||||||//com/fasterxml/jackson/core:jackson_core","visibility||||||//visibility:public","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/com/fasterxml/jackson/core/jackson_core","runtimeDeps|||L|||","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"com/fasterxml/jackson/core:jackson_databind": ["lang||||||java","name||||||//com/fasterxml/jackson/core:jackson_databind","visibility||||||//visibility:public","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/com/fasterxml/jackson/core/jackson_databind","runtimeDeps|||L|||//com/fasterxml/jackson/core:jackson_annotations|||//com/fasterxml/jackson/core:jackson_core","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"com/fasterxml/jackson/dataformat:jackson_dataformat_yaml": ["lang||||||java","name||||||//com/fasterxml/jackson/dataformat:jackson_dataformat_yaml","visibility||||||//visibility:public","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/com/fasterxml/jackson/dataformat/jackson_dataformat_yaml","runtimeDeps|||L|||//com/fasterxml/jackson/core:jackson_core|||//com/fasterxml/jackson/core:jackson_databind|||//org/yaml:snakeyaml","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"com/google/guava:guava": ["lang||||||java","name||||||//com/google/guava:guava","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/com/google/guava/guava","runtimeDeps|||L|||","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"junit:junit": ["lang||||||java","name||||||//junit:junit","visibility||||||//visibility:public","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/junit/junit","runtimeDeps|||L|||//org/hamcrest:hamcrest_core","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/apache/commons:commons_lang3": ["lang||||||java","name||||||//org/apache/commons:commons_lang3","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/apache/commons/commons_lang3","runtimeDeps|||L|||","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/apache/maven:maven_aether_provider": ["lang||||||java","name||||||//org/apache/maven:maven_aether_provider","visibility||||||//visibility:public","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/apache/maven/maven_aether_provider","runtimeDeps|||L|||//org/apache/maven:maven_repository_metadata|||//org/codehaus/plexus:plexus_utils|||//org/apache/commons:commons_lang3|||//org/eclipse/aether:aether_impl|||//org/eclipse/aether:aether_api|||//org/eclipse/aether:aether_util|||//org/apache/maven:maven_model_builder|||//org/eclipse/aether:aether_spi|||//org/apache/maven:maven_model|||//org/codehaus/plexus:plexus_component_annotations","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/apache/maven:maven_artifact": ["lang||||||java","name||||||//org/apache/maven:maven_artifact","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/apache/maven/maven_artifact","runtimeDeps|||L|||//org/codehaus/plexus:plexus_utils|||//org/apache/commons:commons_lang3","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/apache/maven:maven_builder_support": ["lang||||||java","name||||||//org/apache/maven:maven_builder_support","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/apache/maven/maven_builder_support","runtimeDeps|||L|||//org/codehaus/plexus:plexus_utils|||//org/apache/commons:commons_lang3","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/apache/maven:maven_model": ["lang||||||java","name||||||//org/apache/maven:maven_model","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/apache/maven/maven_model","runtimeDeps|||L|||//org/codehaus/plexus:plexus_utils|||//org/apache/commons:commons_lang3","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/apache/maven:maven_model_builder": ["lang||||||java","name||||||//org/apache/maven:maven_model_builder","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/apache/maven/maven_model_builder","runtimeDeps|||L|||//org/codehaus/plexus:plexus_utils|||//org/apache/commons:commons_lang3|||//com/google/guava:guava|||//org/codehaus/plexus:plexus_interpolation|||//org/apache/maven:maven_artifact|||//org/apache/maven:maven_model|||//org/codehaus/plexus:plexus_component_annotations|||//org/apache/maven:maven_builder_support","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/apache/maven:maven_repository_metadata": ["lang||||||java","name||||||//org/apache/maven:maven_repository_metadata","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/apache/maven/maven_repository_metadata","runtimeDeps|||L|||//org/codehaus/plexus:plexus_utils","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/apache/maven:maven_settings": ["lang||||||java","name||||||//org/apache/maven:maven_settings","visibility||||||//visibility:public","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/apache/maven/maven_settings","runtimeDeps|||L|||//org/codehaus/plexus:plexus_utils","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/apache/maven:maven_settings_builder": ["lang||||||java","name||||||//org/apache/maven:maven_settings_builder","visibility||||||//visibility:public","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/apache/maven/maven_settings_builder","runtimeDeps|||L|||//org/codehaus/plexus:plexus_utils|||//org/apache/commons:commons_lang3|||//org/sonatype/plexus:plexus_sec_dispatcher|||//org/apache/maven:maven_settings|||//org/codehaus/plexus:plexus_interpolation|||//org/codehaus/plexus:plexus_component_annotations|||//org/apache/maven:maven_builder_support","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/codehaus/plexus:plexus_component_annotations": ["lang||||||java","name||||||//org/codehaus/plexus:plexus_component_annotations","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/codehaus/plexus/plexus_component_annotations","runtimeDeps|||L|||","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/codehaus/plexus:plexus_interpolation": ["lang||||||java","name||||||//org/codehaus/plexus:plexus_interpolation","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/codehaus/plexus/plexus_interpolation","runtimeDeps|||L|||","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/codehaus/plexus:plexus_utils": ["lang||||||java","name||||||//org/codehaus/plexus:plexus_utils","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/codehaus/plexus/plexus_utils","runtimeDeps|||L|||","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/eclipse/aether:aether_api": ["lang||||||java","name||||||//org/eclipse/aether:aether_api","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/eclipse/aether/aether_api","runtimeDeps|||L|||","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/eclipse/aether:aether_impl": ["lang||||||java","name||||||//org/eclipse/aether:aether_impl","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/eclipse/aether/aether_impl","runtimeDeps|||L|||//org/eclipse/aether:aether_api|||//org/eclipse/aether:aether_spi|||//org/eclipse/aether:aether_util","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/eclipse/aether:aether_spi": ["lang||||||java","name||||||//org/eclipse/aether:aether_spi","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/eclipse/aether/aether_spi","runtimeDeps|||L|||//org/eclipse/aether:aether_api","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/eclipse/aether:aether_util": ["lang||||||java","name||||||//org/eclipse/aether:aether_util","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/eclipse/aether/aether_util","runtimeDeps|||L|||//org/eclipse/aether:aether_api","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/hamcrest:hamcrest_core": ["lang||||||java","name||||||//org/hamcrest:hamcrest_core","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/hamcrest/hamcrest_core","runtimeDeps|||L|||","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/javassist:javassist": ["lang||||||java","name||||||//org/javassist:javassist","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/javassist/javassist","runtimeDeps|||L|||","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/reflections:reflections": ["lang||||||java","name||||||//org/reflections:reflections","visibility||||||//visibility:public","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/reflections/reflections","runtimeDeps|||L|||//org/javassist:javassist","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/scala_sbt:test_interface": ["lang||||||java","name||||||//org/scala_sbt:test_interface","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/scala_sbt/test_interface","runtimeDeps|||L|||","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/slf4j:slf4j_api": ["lang||||||java","name||||||//org/slf4j:slf4j_api","visibility||||||//visibility:public","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/slf4j/slf4j_api","runtimeDeps|||L|||","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/slf4j:slf4j_simple": ["lang||||||java","name||||||//org/slf4j:slf4j_simple","visibility||||||//visibility:public","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/slf4j/slf4j_simple","runtimeDeps|||L|||//org/slf4j:slf4j_api","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/sonatype/plexus:plexus_cipher": ["lang||||||java","name||||||//org/sonatype/plexus:plexus_cipher","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/sonatype/plexus/plexus_cipher","runtimeDeps|||L|||","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/sonatype/plexus:plexus_sec_dispatcher": ["lang||||||java","name||||||//org/sonatype/plexus:plexus_sec_dispatcher","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/sonatype/plexus/plexus_sec_dispatcher","runtimeDeps|||L|||//org/codehaus/plexus:plexus_utils|||//org/sonatype/plexus:plexus_cipher","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/yaml:snakeyaml": ["lang||||||java","name||||||//org/yaml:snakeyaml","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||//external:jar/org/yaml/snakeyaml","runtimeDeps|||L|||","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/scala_lang:scala_compiler": ["lang||||||scala/unmangled:2.12.10","name||||||//org/scala_lang:scala_compiler","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||@io_bazel_rules_scala_scala_compiler//:io_bazel_rules_scala_scala_compiler","runtimeDeps|||L|||","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/scala_lang:scala_library": ["lang||||||scala/unmangled:2.12.10","name||||||//org/scala_lang:scala_library","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||@io_bazel_rules_scala_scala_library//:io_bazel_rules_scala_scala_library","runtimeDeps|||L|||","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/scala_lang:scala_reflect": ["lang||||||scala/unmangled:2.12.10","name||||||//org/scala_lang:scala_reflect","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||@io_bazel_rules_scala_scala_reflect//:io_bazel_rules_scala_scala_reflect","runtimeDeps|||L|||","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"com/chuusai:shapeless": ["lang||||||scala:2.12.10","name||||||//com/chuusai:shapeless","visibility||||||//:__subpackages__","kind||||||import","deps|||L|||","jars|||L|||//external:jar/com/chuusai/shapeless_2_12","sources|||L|||","exports|||L|||","runtimeDeps|||L|||//org/scala_lang:scala_library|||//org/typelevel:macro_compat","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"com/fasterxml/jackson/module:jackson_module_scala": ["lang||||||scala:2.12.10","name||||||//com/fasterxml/jackson/module:jackson_module_scala","visibility||||||//visibility:public","kind||||||import","deps|||L|||","jars|||L|||//external:jar/com/fasterxml/jackson/module/jackson_module_scala_2_12","sources|||L|||","exports|||L|||","runtimeDeps|||L|||//org/scala_lang:scala_library|||//com/fasterxml/jackson/core:jackson_core|||//com/fasterxml/jackson/core:jackson_annotations|||//com/fasterxml/jackson/core:jackson_databind","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"com/github/alexarchambault:argonaut_shapeless_6_2": ["lang||||||scala:2.12.10","name||||||//com/github/alexarchambault:argonaut_shapeless_6_2","visibility||||||//:__subpackages__","kind||||||import","deps|||L|||","jars|||L|||//external:jar/com/github/alexarchambault/argonaut_shapeless_6_2_2_12","sources|||L|||","exports|||L|||","runtimeDeps|||L|||//org/scala_lang:scala_library|||//io/argonaut:argonaut|||//com/chuusai:shapeless","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"io/argonaut:argonaut": ["lang||||||scala:2.12.10","name||||||//io/argonaut:argonaut","visibility||||||//:__subpackages__","kind||||||import","deps|||L|||","jars|||L|||//external:jar/io/argonaut/argonaut_2_12","sources|||L|||","exports|||L|||","runtimeDeps|||L|||//org/scala_lang:scala_reflect","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"io/get_coursier:coursier": ["lang||||||scala:2.12.10","name||||||//io/get_coursier:coursier","visibility||||||//visibility:public","kind||||||import","deps|||L|||","jars|||L|||//external:jar/io/get_coursier/coursier_2_12","sources|||L|||","exports|||L|||","runtimeDeps|||L|||//io/get_coursier:coursier_core|||//io/get_coursier:coursier_cache|||//org/scala_lang:scala_library|||//com/github/alexarchambault:argonaut_shapeless_6_2","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"io/get_coursier:coursier_cache": ["lang||||||scala:2.12.10","name||||||//io/get_coursier:coursier_cache","visibility||||||//visibility:public","kind||||||import","deps|||L|||","jars|||L|||//external:jar/io/get_coursier/coursier_cache_2_12","sources|||L|||","exports|||L|||","runtimeDeps|||L|||//io/get_coursier:coursier_util|||//org/scala_lang:scala_library","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"io/get_coursier:coursier_core": ["lang||||||scala:2.12.10","name||||||//io/get_coursier:coursier_core","visibility||||||//visibility:public","kind||||||import","deps|||L|||","jars|||L|||//external:jar/io/get_coursier/coursier_core_2_12","sources|||L|||","exports|||L|||","runtimeDeps|||L|||//io/get_coursier:coursier_util|||//org/scala_lang:scala_library|||//org/scala_lang/modules:scala_xml","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"io/get_coursier:coursier_util": ["lang||||||scala:2.12.10","name||||||//io/get_coursier:coursier_util","visibility||||||//visibility:public","kind||||||import","deps|||L|||","jars|||L|||//external:jar/io/get_coursier/coursier_util_2_12","sources|||L|||","exports|||L|||","runtimeDeps|||L|||//org/scala_lang:scala_library","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/scala_lang/modules:scala_parser_combinators": ["lang||||||scala:2.12.10","name||||||//org/scala_lang/modules:scala_parser_combinators","visibility||||||//:__subpackages__","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||@io_bazel_rules_scala_scala_parser_combinators//:io_bazel_rules_scala_scala_parser_combinators","runtimeDeps|||L|||","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/scala_lang/modules:scala_xml": ["lang||||||scala:2.12.10","name||||||//org/scala_lang/modules:scala_xml","visibility||||||//visibility:public","kind||||||library","deps|||L|||","jars|||L|||","sources|||L|||","exports|||L|||@io_bazel_rules_scala_scala_xml//:io_bazel_rules_scala_scala_xml","runtimeDeps|||L|||","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/scalacheck:scalacheck": ["lang||||||scala:2.12.10","name||||||//org/scalacheck:scalacheck","visibility||||||//visibility:public","kind||||||import","deps|||L|||","jars|||L|||//external:jar/org/scalacheck/scalacheck_2_12","sources|||L|||","exports|||L|||","runtimeDeps|||L|||//org/scala_lang:scala_library|||//org/scala_sbt:test_interface","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/scalactic:scalactic": ["lang||||||scala:2.12.10","name||||||//org/scalactic:scalactic","visibility||||||//:__subpackages__","kind||||||import","deps|||L|||","jars|||L|||//external:jar/org/scalactic/scalactic_2_12","sources|||L|||","exports|||L|||","runtimeDeps|||L|||//org/scala_lang:scala_library|||//org/scala_lang:scala_reflect","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/scalatest:scalatest": ["lang||||||scala:2.12.10","name||||||//org/scalatest:scalatest","visibility||||||//visibility:public","kind||||||import","deps|||L|||","jars|||L|||//external:jar/org/scalatest/scalatest_2_12","sources|||L|||","exports|||L|||","runtimeDeps|||L|||//org/scala_lang:scala_library|||//org/scalactic:scalactic|||//org/scala_lang:scala_reflect|||//org/scala_lang/modules:scala_xml","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"],
"org/typelevel:macro_compat": ["lang||||||scala:2.12.10","name||||||//org/typelevel:macro_compat","visibility||||||//:__subpackages__","kind||||||import","deps|||L|||","jars|||L|||//external:jar/org/typelevel/macro_compat_2_12","sources|||L|||","exports|||L|||","runtimeDeps|||L|||//org/scala_lang:scala_library","processorClasses|||L|||","generatesApi|||B|||false","licenses|||L|||","generateNeverlink|||B|||false"]
 }


def build_external_workspace(name):
  return build_external_workspace_from_opts(name = name, target_configs = list_target_data(), separator = list_target_data_separator(), build_header = build_header())

