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
    TKF_PLATFORMS = 'linux/arm/v7,linux/arm64,linux/amd64'
    TKF_USER = 'teknofile'
    TKF_REPO = 'tkf-docker-base-alpine'
    DOCKERHUB_IMAGE = "${TKF_USER}" + "/" + "${TKF_REPO}"

    dockerImage = ''
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


    stage("Cloning Git") {
      steps {
        git([url: 'https://github.com/teknofile/tkf-docker-base-alpine.git', branch: 'main', credentialsId: 'teknofile-github-user-token'])
      }
    }

    stage('Build x86_64') {
      steps {
        echo "Running on node: ${NODE_NAME}"

        script {
          withDockerRegistry(credentialsId: 'teknofile-dockerhub') {
            sh '''
              dockerImage = docker.build ${DOCKERHUB_IMAGE}
            '''
          }
        }
      }
    }
  }
  post {
    cleanup {
      cleanWs()
    }
  }
}
