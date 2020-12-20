// Copyright 2011 Foursquare Labs Inc. All Rights Reserved.
// Modified from upstream to take -P options and remove non inclusive language

package io.fsq.buildgen.plugin.used

import java.io.{FileWriter, PrintWriter, Writer}
import scala.io.Source
import scala.tools.nsc.{Global, Phase}
import scala.tools.nsc.plugins.{Plugin, PluginComponent}

object EmitUsedSymbolsPlugin {
  val name = "emit-used-symbols"
  val description = "Emit imported or used fully qualified from source"
  val rootSymbolPrefix = "_root_."
  val rootSymbolPrefixLength = rootSymbolPrefix.length
}

class EmitUsedSymbolsPlugin(override val global: Global) extends Plugin {
  override val name = EmitUsedSymbolsPlugin.name
  override val description = EmitUsedSymbolsPlugin.description
  override val components =
    List[PluginComponent](EmitUsedSymbolsPluginComponent)

  var outputDir: Option[String] = None
  var allowlistFile: Option[String] = None
  var debug = false

  // Default to props so tests still work
  val allowListProp = Option(
    System.getProperty("io.fsq.buildgen.plugin.used.allowlist")
  )
  allowListProp.foreach(p => allowlistFile = Option(p))
  val outputDirProp = Option(
    System.getProperty("io.fsq.buildgen.plugin.used.outputDir")
  )
  outputDirProp.foreach(p => outputDir = Option(p))

  override def processOptions(
      options: List[String],
      error: String => Unit
  ): Unit = {
    for (option <- options) {
      if (option.startsWith("outputDir:")) {
        outputDir = Option(option.substring("outputDir:".length))
      } else if (option.startsWith("debug")) {
        debug = true
      } else if (option.startsWith("allowlistFile:")) {
        allowlistFile = Some(option.substring("allowlistFile:".length))
      } else {
        error(s"[$name] not understood: " + option)
      }
    }
  }

  override val optionsHelp: Option[String] = Some(
    s"  -P:$name:outputDir:dir\tset output directory to dir" + "\n" +
      s"  -P:$name:debug\tprint debug output" + "\n" +
      s"  -P:$name:allowlistFile:file\tset allowlist file file"
  )

  private object EmitUsedSymbolsPluginComponent extends PluginComponent {
    import global._

    override val global = EmitUsedSymbolsPlugin.this.global
    override val phaseName = EmitUsedSymbolsPlugin.name
    override val runsAfter = List("parser")
    override val runsBefore = List("namer")

    private lazy val allowlist = allowlistFile
      .map(path => {
        val source = Source.fromFile(path)
        val allowlistSet = source.getLines().toSet
        source.close()
        allowlistSet
      })
      .getOrElse({
        println(
          s"[$name] -P:$name:allowlistFile not specified, will not gather fully qualified names"
        )
        Set.empty[String]
      })

    class UsedSymbolTraverser(
        unit: CompilationUnit,
        allowlist: Set[String],
        outputWriter: Writer
    ) extends Traverser {
      def gatherImports(tree: Tree): Seq[String] =
        tree match {
          case Import(pkg, selectors) => {
            selectors.map(symbol => s"$pkg.${symbol.name}")
          }
          case _: ImplDef => Nil
          case _ => {
            tree.children.flatMap(gatherImports)
          }
        }

      def gatherFQNames(tree: Tree, pid: String): Seq[String] =
        tree match {
          case s: Select => {
            val symbol = s.toString
            if (symbol != pid) {
              if (allowlist.contains(symbol)) {
                Vector(symbol)
              } else if (
                symbol.startsWith(EmitUsedSymbolsPlugin.rootSymbolPrefix)
              ) {
                val unprefixedSymbol =
                  symbol.substring(EmitUsedSymbolsPlugin.rootSymbolPrefixLength)
                if (allowlist.contains(unprefixedSymbol)) {
                  Vector(unprefixedSymbol)
                } else {
                  Vector.empty
                }
              } else {
                Vector.empty
              }
            } else {
              Vector.empty
            }
          }
          case Import(_, _) => Vector.empty
          case _ => {
            tree.children.flatMap(x => gatherFQNames(x, pid))
          }
        }

      override def traverse(tree: Tree): Unit =
        tree match {
          case PackageDef(pid, _) => {
            val imports = gatherImports(tree).distinct
            val importsJson = imports.map(x => "\"" + x + "\"").mkString(",")
            val fqNames = gatherFQNames(tree, pid.toString).distinct
            val fqNamesJson = fqNames.map(x => "\"" + x + "\"").mkString(",")
            if (debug) {
              println("IMPORTS" + importsJson)
              println("FQNAMES" + fqNamesJson)
            }
            outputWriter.write(s"""
            {
              "source": "${unit.source.path}",
              "imports": [$importsJson],
              "fully_qualified_names": [$fqNamesJson]
            }
          """)
          }
        }
    }

    override def newPhase(prev: Phase): StdPhase =
      new StdPhase(prev) {
        override def name: String = EmitUsedSymbolsPlugin.name
        override def description: String = EmitUsedSymbolsPlugin.description
        override def apply(unit: CompilationUnit): Unit = {
          val outputWriter = outputDir
            .map(outputDir => {
              val pathSafeSource =
                unit.source.path.replaceAllLiterally("/", ".")
              new FileWriter(s"$outputDir/$pathSafeSource")
            })
            .getOrElse({
              println(
                s"[$name] -P:$name:outputDir not specified, writing to stdout"
              )
              new PrintWriter(System.out)
            })

          val traverser = new UsedSymbolTraverser(unit, allowlist, outputWriter)
          traverser.traverse(unit.body)
          outputWriter.close()
        }
      }
  }
}
