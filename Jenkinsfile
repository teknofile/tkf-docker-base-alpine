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
    CONTAINER_NAME = 'tkf-docker-base-alpine'
  }

  stages {
    // Setup all the basic enviornment variables needed for the build
    stage("Setup ENV variables") {
      steps {
        script {
          env.EXIT_STATUS = ''
          env.CURR_DATE = sh(
            script: '''date '+%Y-%m-%d_%H:%M:%S%:z' ''',
            returnStdout: true).trim()
          env.GITHASH_SHORT = sh(
            script: '''git log -1 --format=%h''',
            returnStdout: true).trim()
          env.GITHASH_LONG = sh(
            script: '''git log -1 --format=%H''',
            returnStdout: true).trim()
        }
      }
    }

    stage('Build amd64') {
      agent {
        label 'X86_64'
      }
      steps {
        echo "Running on node: ${NODE_NAME}"

        git([url: 'https://github.com/teknofile/tkf-docker-base-alpine.git', branch: 'main', credentialsId: 'TKFBuildBot'])

        script {
          withDockerRegistry(credentialsId: 'teknofile-dockerhub') {
            sh '''
              docker buildx create --name tkf-builder-${CONTAINER_NAME}-${GITHASH_SHORT} --use
              docker buildx inspect tkf-builder-${CONTAINER_NAME}-${GITHASH_SHORT} --bootstrap

              docker buildx build \
                --no-cache \
                --pull \
                --builder tkf-builder-${CONTAINER_NAME}-${GITHASH_SHORT} \
                --platform linux/amd64 \
                -t teknofile/${CONTAINER_NAME} \
                -t teknofile/${CONTAINER_NAME}:latest \
                -t teknofile/${CONTAINER_NAME}:${GITHASH_LONG} \
                -t teknofile/${CONTAINER_NAME}:${GITHASH_SHORT} \
                . \
                --push

              docker buildx stop tkf-builder-${CONTAINER_NAME}-${GITHASH_SHORT}
              docker buildx rm tkf-builder-${CONTAINER_NAME}-${GITHASH_SHORT}
            '''
          }
        }
      }
    }
  }
  post {
    cleanup {
      cleanWs()
	deleteDir()
    }
  }
}
