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

    stage('Build amd64') {
      agent {
        label 'X86_64'
      }
      steps {
        echo "Running on node: ${NODE_NAME}"

        git([url: 'https://github.com/teknofile/tkf-docker-base-alpine.git', branch: 'main', credentialsId: 'teknofile-github-user-token'])

        script {
          env.OVERLAY_VERSION='v2.2.0.1'
          env.OVERLAY_ARCH='amd64'

          withDockerRegistry(credentialsId: 'teknofile-dockerhub') {
            sh '''
              docker build --build-arg OVERLAY_VERSION=${OVERLAY_VERSION} --build-arg OVERLAY_ARCH=${OVERLAY_ARCH} -t ${DOCKERHUB_IMAGE}:amd64 .
              docker push ${DOCKERHUB_IMAGE}:amd64
            '''
            dockerImage.push("amd64")
          }
        }
      }
    }
    stage('Build aarch64') {
      agent {
        label 'aarch64'
      }
      steps {
        echo "Running on node: ${NODE_NAME}"
        git([url: 'https://github.com/teknofile/tkf-docker-base-alpine.git', branch: 'main', credentialsId: 'teknofile-github-user-token'])
        script {

          env.OVERLAY_VERSION='v2.2.0.1'
          env.OVERLAY_ARCH='aarch64'

          withDockerRegistry(credentialsId: 'teknofile-dockerhub') {
            sh '''
              docker build --build-arg OVERLAY_VERSION=${OVERLAY_VERSION} --build-arg OVERLAY_ARCH=${OVERLAY_ARCH} -t ${DOCKERHUB_IMAGE}:aarch64 .
              docker push ${DOCKERHUB_IMAGE}:aarch64
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
