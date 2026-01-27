plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.online_medicine_lab"
    compileSdk = flutter.compileSdkVersion
    
    // FIXED: Hardcoding the NDK version to point to your new installation
    ndkVersion = "29.0.14206865" 

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        
        // ADDED: Fixes the 'flutter_local_notifications' requirement
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.online_medicine_lab"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ADDED: This library provides the Java 8+ APIs (like java.time) 
    // needed by flutter_local_notifications on older Android devices.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}