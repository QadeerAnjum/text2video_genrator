allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
buildscript {
     repositories {
        google() // ✅ Needed for Firebase and Google Services
        mavenCentral() // Optional but recommended
    }
    dependencies {
    classpath("com.google.gms:google-services:4.4.2") // ✅ Correct Kotlin DSL
    classpath("com.android.tools.build:gradle:7.4.1") // ✅ Kotlin syntax

}
}