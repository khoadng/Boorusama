import java.util.Properties
import com.android.build.api.dsl.ApplicationExtension
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

val hasValidKeystore = keystorePropertiesFile.exists() && 
    keystoreProperties["storeFile"] != null && 
    file(keystoreProperties["storeFile"] as String).exists()
val splitPerAbi = project.findProperty("split-per-abi") == "true"
val compileSdkVersion = providers.gradleProperty("boorusama.android.compileSdk").get().toInt()
val targetSdkVersion = providers.gradleProperty("boorusama.android.targetSdk").get().toInt()
val minSdkVersion = providers.gradleProperty("boorusama.android.minSdk").get().toInt()
val androidBuildToolsVersion = providers.gradleProperty("boorusama.android.buildTools").get()
val ndkVersionName = providers.gradleProperty("boorusama.android.ndk").get()

extensions.configure<ApplicationExtension> {
    namespace = "com.degenk.boorusama"
    compileSdk = compileSdkVersion
    buildToolsVersion = androidBuildToolsVersion
    ndkVersion = ndkVersionName

    buildFeatures {
        resValues = true
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.degenk.boorusama"
        minSdk = minSdkVersion
        targetSdk = targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            if (hasValidKeystore) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }
   
    buildTypes {
        release {
            signingConfig = if (hasValidKeystore) signingConfigs.getByName("release") else signingConfigs.getByName("debug")
            ndk {
                debugSymbolLevel = "SYMBOL_TABLE"
                if (!splitPerAbi) {
                    abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a", "x86_64"))
                }
            }
        }
    }

    flavorDimensions.add("boorusama")

    productFlavors {
        create("dev") {
            dimension = "boorusama"
            resValue("string", "app_name", "Boorusama Dev")
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
        }

        create("prod") {
            dimension = "boorusama"
            resValue("string", "app_name", "Boorusama")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
