// android/app/build.gradle.kts
// Este é o arquivo Gradle de nível de MÓDULO (para o seu aplicativo Flutter).

// ESTE É O ÚNICO E PRINCIPAL BLOCO 'plugins' DESTE ARQUIVO.
// TODOS os plugins que este MÓDULO (o aplicativo) usa devem ser declarados AQUI.
plugins {
    id("com.android.application")           // Plugin para construir um aplicativo Android.
    id("kotlin-android")                    // Plugin para suporte a Kotlin no módulo.
    id("dev.flutter.flutter-gradle-plugin") // Plugin do Flutter para integração do build.

    // **IMPORTANTE:** O plugin do Google Services DEVE ser aplicado AQUI.
    // Ele NÃO deve ter 'version' ou 'apply false' aqui.
    // A versão é declarada no arquivo 'android/build.gradle.kts' (nível de projeto).
    id("com.google.gms.google-services") 
    
    // Se você usa outros plugins como Crashlytics, Performance Monitoring, etc., eles também vão aqui:
    // id("com.google.firebase.crashlytics") // Exemplo: se usar Crashlytics
    // id("com.google.firebase.perf")      // Exemplo: se usar Performance Monitoring
}

// Configurações específicas do módulo Android (namespace, SDKs, etc.).
android {
    // Namespace do seu aplicativo. MUITO IMPORTANTE: Substitua "com.example.flutter_gestor_habitos"
    // pelo namespace REAL do seu projeto, que deve ser o mesmo usado no Firebase Console e no AndroidManifest.xml.
    namespace = "com.example.flutter_gestor_habitos" 
    
    // Versão do SDK de compilação.
    compileSdk = flutter.compileSdkVersion 
    
    // Versão do NDK (Native Development Kit).
    // ADICIONADO: Configura a versão do NDK para a exigida pelo Firebase.
    ndkVersion = "27.0.12077973" 

    // Opções de compilação Java/Kotlin.
    compileOptions {
        // Recomenda-se Java 11 ou mais recente para projetos Flutter modernos.
        sourceCompatibility = JavaVersion.VERSION_11 
        targetCompatibility = JavaVersion.VERSION_11
    }

    // Opções específicas do Kotlin.
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Configurações padrão do aplicativo.
    defaultConfig {
        // MUITO IMPORTANTE: Substitua "com.example.flutter_gestor_habitos"
        // pelo ID ÚNICO da sua aplicação. Este ID identifica seu app na Google Play Store.
        applicationId = "com.example.flutter_gestor_habitos" 
        
        // Versões mínimas e alvo do SDK Android.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        
        // Código e nome da versão do aplicativo.
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    // Configurações para diferentes tipos de build (ex: 'release' para builds de produção).
    buildTypes {
        release {
            // Configurações de assinatura para builds de lançamento.
            // Para desenvolvimento, 'debug' é usado. Para lançamento, você deve ter sua própria chave de assinatura.
            signingConfig = signingConfigs.getByName("debug") 
        }
    }
}

// Bloco 'flutter' para indicar ao Gradle onde o código-fonte do Flutter está.
flutter {
    source = "../.." // Aponta para a raiz do projeto Flutter
}

// Dependências do seu aplicativo.
dependencies {
    // **IMPORTANTE:** Importa o Firebase Bill of Materials (BoM).
    // Isso garante que todas as suas dependências do Firebase usem versões compatíveis.
    // VERIFIQUE/AJUSTE A VERSÃO DO BOM AQUI. A versão 33.14.0 estava no seu exemplo.
    implementation(platform("com.google.firebase:firebase-bom:33.14.0")) 

    // **TODO:** Adicione as dependências dos produtos Firebase que você usa.
    // Quando você usa o BoM acima, NÃO especifique a versão para as dependências individuais do Firebase.
    implementation("com.google.firebase:firebase-analytics") // Exemplo: Firebase Analytics
    // implementation("com.google.firebase:firebase-firestore") // Exemplo: Cloud Firestore
    // implementation("com.google.firebase:firebase-auth")      // Exemplo: Firebase Authentication
    // Adicione outras bibliotecas Firebase aqui conforme necessário.
}
