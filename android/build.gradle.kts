// android/build.gradle.kts

buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.4.1")
        
        // CORREÇÃO: Coloque a versão do Kotlin diretamente aqui.
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.23") // <-- VERSÃO ATUALIZADA E CORRETA

        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// CORREÇÃO: Converta a String de caminho para um objeto File.
rootProject.buildDir = file("../build")

subprojects {
    // CORREÇÃO: Faça o mesmo para os subprojetos.
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
    project.evaluationDependsOn(":app")
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}