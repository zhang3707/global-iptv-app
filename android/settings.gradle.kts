pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        // 🎯 黄金梯队：海外虚拟机优先走官方，本地走国内！谁能通谁先上！
        google()
        mavenCentral()
        gradlePluginPortal()
        // 腾讯云黄金备载节点
        maven { url = java.net.URI("https://mirrors.cloud.tencent.com/nexus/repository/maven-public/") }
        // 修复后的阿里云节点
        maven { url = java.net.URI("https://maven.aliyun.com/repository/public") }
        maven { url = java.net.URI("https://maven.aliyun.com/repository/gradle-plugin") }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.0.1" apply false
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
}

include(":app")