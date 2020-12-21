// Copyright 2011 Foursquare Labs Inc. All Rights Reserved.
// Forked from https://github.com/foursquare/fsqio/blob/395c947/src/jvm/io/fsq/buildgen/plugin/exported/EmitExportedSymbolsPlugin.scala
// Under the Apache 2.0 license
// Modified from upstream to take -P options and to work more like the used symbol plugin

package com.wbertelsen.packagesymbols.scalac.plugin.exported

import java.io.{FileWriter, PrintWriter, Writer}

import scala.reflect.internal.Flags
import scala.tools.nsc.{Global, Phase}
import scala.tools.nsc.plugins.{Plugin, PluginComponent}

class EmitExportedSymbolsPlugin(val global: Global) extends Plugin {

  val name = "emit-exported-symbols"
  val description = "Emit symbols importable from this source"
  val components = List[PluginComponent](EmitExportedSymbolsPluginComponent)
  var outputDir: Option[String] = None
  var debug = false

  override def processOptions(
      options: List[String],
      error: String => Unit
  ): Unit = {
    for (option <- options) {
      if (option.startsWith("outputDir:")) {
        outputDir = Option(option.substring("outputDir:".length))
      } else if (option.startsWith("debug")) {
        debug = true
      } else {
        error(s"[$name] Option not understood: " + option)
      }
    }
  }

  override val optionsHelp: Option[String] = Some(
    s"  -P:$name:outputDir:dir\tset output directory to dir" + "\n" +
    s"  -P:$name:debug\tprint debug output"
  )

  private object EmitExportedSymbolsPluginComponent extends PluginComponent {
    import global._

    val global = EmitExportedSymbolsPlugin.this.global

    override val runsAfter = List("parser")
    override val runsBefore = List("namer")

    val phaseName = EmitExportedSymbolsPlugin.this.name

    override def newPhase(prev: Phase): StdPhase =
      new StdPhase(prev) {
        override def name = EmitExportedSymbolsPlugin.this.name
        override def description = EmitExportedSymbolsPlugin.this.description
        override def apply(unit: global.CompilationUnit): Unit = {
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
          val traverser = new ExportedSymbolTraverser(unit, outputWriter)
          traverser.traverse(unit.body)
          outputWriter.close()
        }
      }

    class ExportedSymbolTraverser(unit: CompilationUnit, outputWriter: Writer)
        extends Traverser {

      private def isPrivate(md: MemberDef) = {
        (md.mods.flags & Flags.PRIVATE.toLong) != 0
      }

      private def traversePackageSymbols(tree: Tree): Seq[String] = {
        tree match {
          case md: MemberDef if isPrivate(md) => Seq.empty

          case pd: PackageDef => {
            val childNames = pd.children.flatMap(traversePackageSymbols)
            val fqChildNames = childNames.map(pd.pid + "." + _)
            Vector(pd.pid.toString) ++ fqChildNames
          }

          case md: ModuleDef => {
            val childNames = md.children.flatMap(traversePackageSymbols)
            md.name.toString match {
              case "package" => childNames
              case other =>
                Vector(md.name.toString) ++ childNames.map(other + "." + _)
            }
          }

          case cd: ClassDef => {
            Vector(cd.name.toString)
          }

          case dd: ValOrDefDef => {
            if (dd.name.toString != "<init>") {
              Vector(dd.name.toString)
            } else {
              Seq.empty
            }
          }

          case td: TypeDef => {
            Vector(td.name.toString)
          }

          case _ => tree.children.flatMap(traversePackageSymbols)
        }
      }

      override def traverse(tree: Tree): Unit =
        tree match {
          case PackageDef(pid, _) => {
            val symbols = traversePackageSymbols(tree).toSet
            val symbolsJson = symbols.map(x => "\"%s\"".format(x)).mkString(",")
            val packageName = pid
            outputWriter.write("""
            {
              "package": "%s",
              "source": "%s",
              "symbols": [%s]
            }
          """.format(packageName, unit.source.path, symbolsJson))
          }
        }
    }
  }
}
