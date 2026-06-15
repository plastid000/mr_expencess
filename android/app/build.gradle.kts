plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mrtechbd.mrexpense"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.mrtechbd.mrexpense"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {

        // 🔥 RELEASE SIGNING (CI/CD + LOCAL BOTH SUPPORT)
        create("release") {
            storeFile = file("release-key.jks")

            storePassword = System.getenv("KEYSTORE_PASSWORD")
                ?: "LOCAL_FALLBACK_PASSWORD_CHANGE_ME"

            keyAlias = System.getenv("KEY_ALIAS")
                ?: "my-key"

            keyPassword = System.getenv("KEY_PASSWORD")
                ?: "LOCAL_FALLBACK_PASSWORD_CHANGE_ME"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}