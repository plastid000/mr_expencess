plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mrtechbd.mrexpense"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // Desugaring এর জন্য এই ব্লকটা খুব জরুরি
    compileOptions {
        isCoreLibraryDesugaringEnabled = true // এনাবল করা হলো
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.mrtechbd.mrexpense"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true // এটিও রাখা ভালো
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Desugaring লাইব্রেরি এখানে অ্যাড করো
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}