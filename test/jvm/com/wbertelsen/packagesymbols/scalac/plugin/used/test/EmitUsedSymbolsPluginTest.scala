// Copyright 2019 Foursquare Labs Inc. All Rights Reserved.

package com.wbertelsen.packagesymbols.scalac.plugin.used.test

import com.fasterxml.jackson.databind.{DeserializationFeature, ObjectMapper, PropertyNamingStrategy}
import com.fasterxml.jackson.module.scala.DefaultScalaModule
import com.fasterxml.jackson.module.scala.experimental.ScalaObjectMapper
import java.io.{File, FileWriter}
import java.nio.file.Files

import com.wbertelsen.packagesymbols.scalac.plugin.used.EmitUsedSymbolsPlugin
import org.junit.{Assert, Test}
import org.reflections.util.ClasspathHelper

import scala.collection.JavaConverters._
import scala.io.Source
import scala.reflect.internal.util.BatchSourceFile
import scala.tools.nsc.{Global, Settings}
import scala.tools.nsc.reporters.ConsoleReporter

case class EmitUsedSymbolsPluginOutput(
    source: String,
    imports: Seq[String],
    fullyQualifiedNames: Seq[String]
)

class EmitUsedSymbolsPluginTest {

  val json = new ObjectMapper with ScalaObjectMapper
  json.registerModule(new DefaultScalaModule)
  json.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, true)
  json.setPropertyNamingStrategy(
    new PropertyNamingStrategy.LowerCaseWithUnderscoresStrategy
  )

  @Test
  def testSymbolTraversal(): Unit = {
    val allowlist = Set(
      "io.fsq.common.scala.Identity",
      "io.fsq.common.scala.LazyLocal"
    )
    val allowlistFile =
      Files.createTempFile("EmitUsedSymbolsPluginTest_allowlist", ".tmp").toFile
    val allowlistWriter = new FileWriter(allowlistFile)
    allowlist.foreach(symbol => {
      allowlistWriter.write(symbol)
      allowlistWriter.write('\n')
    })
    allowlistWriter.close()
    System.setProperty(
      "com.wbertelsen.packagesymbols.scalac.plugin.used.allowlist",
      allowlistFile.getAbsolutePath
    )

    val outputDir =
      Files.createTempDirectory("EmitUsedSymbolsPluginTest_outputDir").toFile
    System.setProperty(
      "com.wbertelsen.packagesymbols.scalac.plugin.used.outputDir",
      outputDir.getAbsolutePath
    )

    val settings = new Settings
    settings.usejavacp.value = true
    settings.stopAfter.value = List(EmitUsedSymbolsPlugin.name)

    // Sometimes we are run from a "thin" jar where a wrapper jar defines
    // the full classpath in a MANIFEST.  IMain's default classloader does
    // not respect MANIFEST Class-Path entries by default, so we force it
    // here.
    settings.classpath.value = ClasspathHelper
      .forManifest()
      .asScala
      .map(_.toString)
      .mkString(":")

    val global = new Global(settings, new ConsoleReporter(settings)) {
      override def computeInternalPhases(): Unit = {
        super.computeInternalPhases()
        for (phase <- new EmitUsedSymbolsPlugin(this).components) {
          phasesSet += phase
        }
      }
    }

    val testSourceFile = new File(
      "test/jvm/com/wbertelsen/packagesymbols/scalac/plugin/used/test/SampleFileForPluginTests.scala"
    )
    val testSource = {
      val content = {
        val source = Source.fromFile(testSourceFile.getPath)
        val arr = source.toArray
        source.close()
        arr
      }
      new BatchSourceFile(
        testSourceFile.getName,
        content
      )
    }

    val runner = new global.Run()
    runner.compileSources(List(testSource))

    val outputFile = new File(outputDir, testSourceFile.getName)
    val outputJson = json.readValue[EmitUsedSymbolsPluginOutput](outputFile)

    val expectedJson = EmitUsedSymbolsPluginOutput(
      source = testSourceFile.getName,
      imports = Vector(
        "io.fsq.common.scala.Lists.Implicits._",
        "io.fsq.common.scala.TryO"
      ),
      fullyQualifiedNames = Vector(
        "io.fsq.common.scala.Identity",
        "io.fsq.common.scala.LazyLocal"
      )
    )

    Assert.assertEquals(
      "emitted source file name doesn't match expected",
      expectedJson.source,
      outputJson.source
    )
    Assert.assertArrayEquals(
      "emitted imports don't match expected",
      expectedJson.imports.sorted.toArray: Array[Object],
      outputJson.imports.sorted.toArray: Array[Object]
    )
    Assert.assertArrayEquals(
      "emitted names don't match expected",
      expectedJson.fullyQualifiedNames.sorted.toArray: Array[Object],
      outputJson.fullyQualifiedNames.sorted.toArray: Array[Object]
    )
  }
}
