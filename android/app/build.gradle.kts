plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")   // ✅ Firebase plugin added
}

android {
    namespace = "com.example.shopidoe"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.shopidoe"
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

dependencies {
    // ✅ Firebase BOM (controls versions)
    implementation(platform("com.google.firebase:firebase-bom:34.12.0"))

    // ✅ Add Firebase services (choose what you need)
    implementation("com.google.firebase:firebase-auth")      // Authentication
    implementation("com.google.firebase:firebase-firestore") // Database (optional)
    implementation("com.google.firebase:firebase-analytics") // Analytics (optional)
}

flutter {
    source = "../.."
}