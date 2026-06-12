plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mrtechbd.mrexpense"
    compileSdk = 36

    // Desugaring এর জন্য এই ব্লকটা খুব জরুরি
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    // দুইটা defaultConfig ছিল, একটা করে দিলাম
    defaultConfig {
        applicationId = "com.mrtechbd.mrexpense"
        minSdk = flutter.minSdkVersion 
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    // signingConfigs সবসময় buildTypes-এর উপরে রাখতে হয়!
    // .kts ফাইলের জন্য '=' ব্যবহার করতে হয়
    signingConfigs {
        create("release") {
            storeFile = file("release-key.jks")
            storePassword = "MDLM_MRTECH_BD_2024T_CHANGE_THISc0fbff1b519387015f2131c9cdaa3baafe048274aa370b7afd2a7b266854c00dcaeiubhgea**"
            keyAlias = "my-key"
            keyPassword = "MDLM_MRTECH_BD_2024T_CHANGE_THISc0fbff1b519387015f2131c9cdaa3baafe048274aa370b7afd2a7b266854c00dcaeiubhgea**"
        }
    }

    // দুইটা buildTypes ছিল, মার্জ করে দিলাম। .kts এর সঠিক সিনট্যাক্স দেওয়া হলো।
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    // Desugaring লাইব্রেরি এখানে অ্যাড করা হলো
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}