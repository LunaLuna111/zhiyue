import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseKeyProperties = Properties()
val releaseKeyPropertiesFile = rootProject.file("key.properties")
if (releaseKeyPropertiesFile.exists()) {
    releaseKeyPropertiesFile.inputStream().use(releaseKeyProperties::load)
}

val hasReleaseSigning = listOf(
    "storeFile",
    "storePassword",
    "keyAlias",
    "keyPassword",
).all { releaseKeyProperties.getProperty(it)?.isNotBlank() == true }

android {
    namespace = "com.zhiyue.client"
    // flutter_secure_storage 11 compiles against API 37; the SDK is installed.
    compileSdk = 37
    // The installed 28.2 directory is incomplete (source.properties is
    // missing), so retain the complete r28b toolchain for local builds.
    ndkVersion = "28.1.13356709"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.zhiyue.client"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndk {
            abiFilters.add("arm64-v8a")
        }
    }

    buildFeatures {
        buildConfig = true
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = rootProject.file(releaseKeyProperties.getProperty("storeFile"))
                storePassword = releaseKeyProperties.getProperty("storePassword")
                keyAlias = releaseKeyProperties.getProperty("keyAlias")
                keyPassword = releaseKeyProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        getByName("release") {
            // A local key.properties release key is never committed. CI and
            // local builds without that file use the generated debug key so
            // the open-source project remains buildable without secrets.
            signingConfig = signingConfigs.getByName(
                if (hasReleaseSigning) "release" else "debug",
            )
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }

    packaging {
        jniLibs {
            // Compress native libraries inside the APK. Android extracts them
            // at install time, trading install space for the smallest file.
            useLegacyPackaging = true
            // Flutter and plugins may expose artifacts for multiple ABI sets.
            // Enforce the compact test APK's arm64-only contract at packaging.
            excludes += setOf(
                "**/armeabi-v7a/**",
                "**/x86/**",
                "**/x86_64/**",
            )
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
    // Install the privacy profile before any page JavaScript executes when the
    // device WebView supports DOCUMENT_START_SCRIPT.
    implementation("androidx.webkit:webkit:1.14.0")
    // The debug-only Salt interoperability channel must preserve the
    // official App's HTTP/2 transport. Android HttpsURLConnection negotiated
    // HTTP/1.1 through the local TLS-validating proxy and Zhihu rejected that
    // otherwise identical request with HTTP 418.
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("com.google.zxing:core:3.5.3")
}
