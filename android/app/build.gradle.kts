plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

android {
    namespace = "com.finext.asteria"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.finext.asteria"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.android.gms:play-services-ads-identifier:18.3.0")
}

// Validate only the release task graph; debug builds need no production keys.
val validateReleaseSigningConfig by tasks.registering {
    group = "verification"
    description = "Requires production signing credentials for release artifacts."
    doLast {
        check(keystorePropertiesFile.exists()) {
            "Release signing requires android/key.properties; debug signing is not allowed."
        }
        val required = listOf("keyAlias", "keyPassword", "storeFile", "storePassword")
        check(required.all { !keystoreProperties.getProperty(it).isNullOrBlank() }) {
            "Release signing requires keyAlias, keyPassword, storeFile and storePassword."
        }
        check(file(keystoreProperties.getProperty("storeFile")).isFile) {
            "Release signing keystore file is missing."
        }
    }
}

tasks.configureEach {
    if (name == "preReleaseBuild") {
        dependsOn(validateReleaseSigningConfig)
    }
}
