plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.lifex_ai"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    // 36.1.0 على هذا الجهاز مجلد فارغ بلا aapt. 34.0.0 مكتمل ويسمح بالبناء.
    buildToolsVersion = "34.0.0"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // لا تغيّر applicationId — هذا معرّف التطبيق الرسمي على Google Play
        applicationId = "com.lifex_ai"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            // TODO: استبدال بتوقيع إنتاجي حقيقي (keystore) قبل النشر على Google Play.
            // مؤقتًا نستخدم مفتاح debug فقط ليتمكن flutter build apk --release من إنتاج APK قابل للتجربة.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
