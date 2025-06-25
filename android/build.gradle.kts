allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Use a simpler approach: set the build folder one level above Android.
buildDir = file("../build")

subprojects {
    // Place each module’s build output inside the parent build folder.
    buildDir = file("${rootProject.buildDir}/${project.name}")
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
