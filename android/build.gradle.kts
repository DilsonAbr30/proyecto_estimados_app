// Top-level build file where you can add configuration options common to all sub-projects/modules.

// --- 1. Usamos tu bloque buildscript con tus versiones ---
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Tus versiones
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.10")
        classpath("com.google.gms:google-services:4.4.0")
    }
}
    
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// --- 2. ¡AQUÍ ESTÁ LA CORRECCIÓN DE SINTAXIS! ---
// Así se escribe en Kotlin (.kts)
rootProject.buildDir = rootProject.file("../build")
subprojects {
    project.buildDir = File(rootProject.buildDir, project.name)
    // Combinamos tus dos bloques "subprojects" en uno solo
    project.evaluationDependsOn(":app")
}
// --- FIN DE LA CORRECCIÓN ---

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}