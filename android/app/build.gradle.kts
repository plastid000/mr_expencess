plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mrtechbd.mrexpense"
    compileSdk = 36
    defaultConfig {
        minSdk = 34 // বা তোমার যেটা দরকার
        targetSdk = 36
        // ...
    }
    ndkVersion = flutter.ndkVersion

    // Desugaring এর জন্য এই ব্লকটা খুব জরুরি
    compileOptions {
        isCoreLibraryDesugaringEnabled = true // এনাবল করা হলো
        sourceCompatibility = JavaVersion.VERSION_17 // 1_8 থেকে 17 করো
        targetCompatibility = JavaVersion.VERSION_17 // 1_8 থেকে 17 করো
    }

    kotlinOptions {
        jvmTarget = "17" // 1.8 থেকে 17 করো
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
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}