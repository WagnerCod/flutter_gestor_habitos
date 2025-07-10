// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // O plugin do Google Services é aplicado aqui.
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.flutter_gestor_habitos" // Substitua pelo seu namespace real
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.flutter_gestor_habitos" // Substitua pelo seu ID real
        minSdk = 23 // minSdk 23 é uma boa escolha
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
    // IMPORTANTE: Corrija a versão do Firebase BoM.
    // Verifique a versão mais recente em: https://firebase.google.com/docs/android/setup#available-libraries
    implementation(platform("com.google.firebase:firebase-bom:33.1.0")) // <-- VERSÃO CORRIGIDA/ATUALIZADA

    // Adicione as dependências do Firebase que você usa, SEM especificar a versão.
    // O BoM cuida disso para você.
    implementation("com.google.firebase:firebase-analytics")
    // Ex: implementation("com.google.firebase:firebase-auth")
    // Ex: implementation("com.google.firebase:firebase-firestore")
}