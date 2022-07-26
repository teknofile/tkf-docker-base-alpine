def loadConfigYaml()
{
  def valuesYaml = readYaml (file: './config.yaml')
  return valuesYaml;
}

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

    stage('Build Containers') {
      agent {
        label 'X86_64'
      }
      steps {
        echo "Running on node: ${NODE_NAME}"

        git([url: 'https://github.com/teknofile/tkf-docker-base-alpine.git', branch: env.BRANCH_NAME, credentialsId: 'TKFBuildBot'])

        script {

          configYaml = loadConfigYaml()
          env.ALPINE_VERSION = configYaml.alpine.srcVersion
          env.S6_OVERLAY_VERSION = configYaml.s6overlay.version

          withDockerRegistry(credentialsId: 'teknofile-dockerhub') {
            sh '''
              docker buildx create --bootstrap --use --name tkf-builder-${CONTAINER_NAME}-${GITHASH_SHORT}
              docker buildx build \
                --no-cache \
                --pull \
                --platform linux/amd64,linux/arm64,linux/arm \
                --build-arg ALPINE_VERSION=${ALPINE_VERSION} \
                --build-arg S6_OVERLAY_VERSION=${S6_OVERLAY_VERSION}
                -t teknofile/${CONTAINER_NAME} \
                -t teknofile/${CONTAINER_NAME}:${BUILD_ID} \
                -t teknofile/${CONTAINER_NAME}:${GITHASH_LONG} \
                -t teknofile/${CONTAINER_NAME}:${GITHASH_SHORT} \
                -t teknofile/${CONTAINER_NAME}:${ALPINE_VERSION} \
                . \
                --push

              docker buildx stop tkf-builder-${CONTAINER_NAME}-${GITHASH_SHORT}
              docker buildx rm tkf-builder-${CONTAINER_NAME}-${GITHASH_SHORT}
            '''
          }
        }
      }
    }
    stage('Tag Latest') {
      when {
        branch "main"
      }
      steps {
        script {
          withDockerRegistry(credentialsId: 'teknofile-dockerhub') {
            sh '''
              docker tag teknofile/${CONTAINER_NAME}:${GITHASH_LONG} teknofile/${CONTAINER_NAME}:latest
              docker push teknofile/${CONTAINER_NAME}:latest
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