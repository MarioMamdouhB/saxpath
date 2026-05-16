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
    
    // Fix for older plugins like flutter_fft that lack namespace
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            if (android.namespace == null) {
                // Generate a namespace based on the project name
                val manifestFile = project.file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    val packageName = groovy.xml.XmlParser().parse(manifestFile).attribute("package")
                    if (packageName != null) {
                        android.namespace = packageName.toString()
                    } else {
                        android.namespace = "com.saxpath.${project.name.replace(":", ".")}"
                    }
                } else {
                    android.namespace = "com.saxpath.${project.name.replace(":", ".")}"
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
