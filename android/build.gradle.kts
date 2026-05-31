allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.findByName("android")
            if (android != null) {
                try {
                    android.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType).invoke(android, 36)
                } catch (e: Exception) {
                    try {
                        android.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType).invoke(android, 36)
                    } catch (ex: Exception) {
                        // Ignore
                    }
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
