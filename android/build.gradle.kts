allprojects {
    repositories {
        // 🎯 黄金梯队：海外虚拟机优先走官方，本地走国内！谁能通谁先上！
        google()
        mavenCentral()
        // 腾讯云黄金备载节点
        maven { url = java.net.URI("https://mirrors.cloud.tencent.com/nexus/repository/maven-public/") }
        // 修复后的阿里云节点
        maven { url = java.net.URI("https://maven.aliyun.com/repository/public") }
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
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
