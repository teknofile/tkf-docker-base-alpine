pipeline {
  agent {
    // By default run stuff on a x86_64 node, when we get
    // to the parts where we need to build an image on a diff
    // architecture, we'll run that bit on a diff agent

    label 'X86_64'
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '10', daysToKeepStr: '60'))
    parallelsAlwaysFailFast()
  }

  // Configuration for the variables used for this specific repo
  environment {
    TKF_USER = 'teknofile'
    TKF_REPO = 'tkf-docker-base-alpine'

    CONTAINER_NAME = 'tkf-docker-base-alpine'
    DOCKERHUB_IMAGE = 'teknofile/tkf-docker-base-alpine'
  }

  stages {
    
    // Setup all the basic enviornment variables needed for the build
    stage("Setup ENV variables") {
      steps {
        script {
          env.EXIT_STATUS = ''
          env.GITHUB_DATE = sh(
            script: '''date '+%Y-%m-%d%T%H:%M:%S%:z' ''',
            returnStdout: true).trim()
          env.COMMIT_SHA = sh(
            script: '''git rev-parse HEAD''',
            returnStdout: true).trim()
          env.IMAGE = env.DOCKERHUB_IMAGE
          env.META_TAG = env.COMMIT_SHA
        }
      }
    }

    // Build the containers for all of the necessary architectures and push them to the repo
    stage('Build Containers') {
      parallel {
        stage('Build X86_64') {
          steps {
            echo "Running on node: ${NODE_NAME}"
            sh "docker build --no-cache --pull -t ${IMAGE}:amd64-${META_TAG} ."
            // TODO: Tag/Push images
          }
        }
/*
        stage('Build armhf') {
          agent {
            label 'ARMHF'
          }

          steps {
            echo "Running on node: ${NODE_NAME}"
            sh "docker build --no-cache --pull -f Dockerfile.armhf -t ${IMAGE}:arm32v7-${META_TAG} ."
            // TODO: Tag/Push images
          }
        }
*/
/*
        stage('Build arm64') {
          agent {
            label 'ARM64'
          }

          steps {
            echo "Running on node: ${NODE_NAME}"
            sh "docker build --no-cache --pull -f Dockerfile.aarch64 -t ${IMAGE}:arm64v8-${META_TAG} ."
            // TODO: Tag/Push images
          }
        }
*/
      }
    }
  }

  post {
    cleanup {
      cleanWs()
    }
  }
}
