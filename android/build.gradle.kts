// android/build.gradle.kts
// Este é o arquivo Gradle de nível de PROJETO (raiz do diretório 'android').

// Bloco 'buildscript' para configurar o Gradle em si e seus plugins.
// As dependências de 'classpath' para os plugins vão AQUI.
buildscript {
    // Não usamos 'ext' aqui diretamente. As versões são passadas diretamente nas dependências.
    
    // Repositórios onde o Gradle busca seus próprios plugins.
    repositories {
        google()       // Repositório do Google (fundamental para Android e Firebase)
        mavenCentral() // Repositório Maven Central
    }
    // Dependências de classpath para os PLUGINS do Gradle.
    dependencies {
        // Plugin Android Gradle (AGP) - necessário para construir apps Android.
        // Mantenha a versão que seu projeto Flutter usa ou a versão mais recente compatível.
        classpath("com.android.tools.build:gradle:8.4.1") // VERIFIQUE/AJUSTE SUA VERSÃO DO AGP AQUI
        
        // Plugin Kotlin Gradle - para suporte a Kotlin no projeto.
        // Use a versão que seu Flutter/Gradle usa.
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22") // VERIFIQUE/AJUSTE SUA VERSÃO DO KOTLIN AQUI
        
        // **IMPORTANTE:** O plugin do Google Services DEVE ser declarado aqui no 'classpath'.
        // Ele será *aplicado* no arquivo 'app/build.gradle.kts'.
        // Mantenha a versão que você usou ou a mais recente compatível.
        classpath("com.google.gms:google-services:4.4.2") // VERIFIQUE/AJUSTE SUA VERSÃO DO GOOGLE-SERVICES AQUI
        
        // Se você usar Crashlytics ou Performance Monitoring, o plugin deles também vai aqui:
        // classpath("com.google.firebase:firebase-crashlytics-gradle:2.9.9") // Exemplo
        // classpath("com.google.firebase:perf-plugin:1.4.2") // Exemplo
    }
}

// Bloco 'allprojects' para configurar repositórios e outras configurações para TODOS os módulos
// dentro deste projeto Gradle (incluindo 'app').
allprojects {
    repositories {
        google()
        mavenCentral()
        // Adicione outros repositórios, se necessário (ex: para bibliotecas customizadas).
        // maven { url = uri("https://jitpack.io") }
    }
}

// Configura o diretório de build para o projeto raiz (geralmente '../build').
// Isso garante que os artefatos de build sejam colocados em um local centralizado.
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

// Configura o diretório de build para cada subprojeto dentro do novo adiretório de build raiz.
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Garante que o projeto ':app' seja avaliado (processado) antes dos outros subprojetos.
// Isso ajuda a resolver dependências corretamente.
subprojects {
    project.evaluationDependsOn(":app")
}

// Define uma tarefa 'clean' personalizada para limpar o diretório de build do projeto raiz.
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir) // Deleta o diretório de build
}
