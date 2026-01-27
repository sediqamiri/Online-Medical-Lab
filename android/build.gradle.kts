allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory.set(file("${rootProject.projectDir}/../build"))

subprojects {
    val newBuildDir = file("${rootProject.layout.buildDirectory.get()}/${project.name}")
    project.layout.buildDirectory.set(newBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// We use 'withType' on the specific Plugin to avoid the 'afterEvaluate' crash.
// This executes as the plugin is applied, not after the project is finished.
subprojects {
    plugins.withType<com.android.build.gradle.BasePlugin> {
        val android = extensions.getByType<com.android.build.gradle.BaseExtension>()
        android.ndkVersion = "29.0.14206865"
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}