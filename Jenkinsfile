#!groovy

@Library('github.com/mozmeao/jenkins-pipeline@20170607.1')

def loadBranch(String branch) {
  if (fileExists("./jenkins/${branch}.yaml")) {
    config = readYaml file: "./jenkins/${branch}.yaml"
    println "config ==> ${config}"
  }
  else {
    config = []
  }

  if (config && config.pipeline && config.pipeline.enabled == false) {
    println "Pipeline disabled."
  }
  else {
    if (config && config.pipeline && config.pipeline.script) {
      println "Loading ./jenkins/${config.pipeline.script}.groovy"
      load "./jenkins/${config.pipeline.script}.groovy"
    }
    else {
      println "Loading ./jenkins/${branch}.groovy"
      load "./jenkins/${branch}.groovy"
    }
  }
}

node {
  stage("Prepare") {
    checkout scm
    setGitEnvironmentVariables()

    // When checking in a file exists in another directory start with './' or
    // prepare to fail.
    if (fileExists("./jenkins/${env.BRANCH_NAME}.groovy") || fileExists("./jenkins/${env.BRANCH_NAME}.yaml")) {
      loadBranch(env.BRANCH_NAME)
    }
    else {
      loadBranch("default")
    }
  }
}
