pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials'
        DOCKERHUB_USERNAME = 'YOUR_DOCKERHUB_USERNAME'

        MOVIE_IMAGE = "${DOCKERHUB_USERNAME}/movie-service"
        CAST_IMAGE  = "${DOCKERHUB_USERNAME}/cast-service"

        IMAGE_TAG = "${BUILD_NUMBER}"
        CHART_PATH = "./charts"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Images') {
            steps {
                sh "docker build -t ${MOVIE_IMAGE}:${IMAGE_TAG} ./movie-service"
                sh "docker build -t ${CAST_IMAGE}:${IMAGE_TAG} ./cast-service"
            }
        }

        stage('Docker Hub Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "${DOCKERHUB_CREDENTIALS}",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }

        stage('Push Images') {
            steps {
                sh "docker push ${MOVIE_IMAGE}:${IMAGE_TAG}"
                sh "docker push ${CAST_IMAGE}:${IMAGE_TAG}"
            }
        }

        stage('Deploy Dev') {
            when {
                branch 'develop'
            }
            steps {
                sh """
                    helm upgrade --install fastapi-dev ${CHART_PATH} \
                      -n dev --create-namespace \
                      -f ${CHART_PATH}/values-dev.yaml \
                      --set movieService.image.repository=${MOVIE_IMAGE} \
                      --set movieService.image.tag=${IMAGE_TAG} \
                      --set castService.image.repository=${CAST_IMAGE} \
                      --set castService.image.tag=${IMAGE_TAG}
                """
            }
        }

        stage('Deploy QA') {
            when {
                branch 'qa'
            }
            steps {
                sh """
                    helm upgrade --install fastapi-qa ${CHART_PATH} \
                      -n qa --create-namespace \
                      -f ${CHART_PATH}/values-qa.yaml \
                      --set movieService.image.repository=${MOVIE_IMAGE} \
                      --set movieService.image.tag=${IMAGE_TAG} \
                      --set castService.image.repository=${CAST_IMAGE} \
                      --set castService.image.tag=${IMAGE_TAG}
                """
            }
        }

        stage('Deploy Staging') {
            when {
                branch 'staging'
            }
            steps {
                sh """
                    helm upgrade --install fastapi-staging ${CHART_PATH} \
                      -n staging --create-namespace \
                      -f ${CHART_PATH}/values-staging.yaml \
                      --set movieService.image.repository=${MOVIE_IMAGE} \
                      --set movieService.image.tag=${IMAGE_TAG} \
                      --set castService.image.repository=${CAST_IMAGE} \
                      --set castService.image.tag=${IMAGE_TAG}
                """
            }
        }

        stage('Approve Production') {
            when {
                branch 'master'
            }
            steps {
                input message: 'Deploy to production?', ok: 'Deploy'
            }
        }

        stage('Deploy Production') {
            when {
                branch 'master'
            }
            steps {
                sh """
                    helm upgrade --install fastapi-prod ${CHART_PATH} \
                      -n prod --create-namespace \
                      -f ${CHART_PATH}/values-prod.yaml \
                      --set movieService.image.repository=${MOVIE_IMAGE} \
                      --set movieService.image.tag=${IMAGE_TAG} \
                      --set castService.image.repository=${CAST_IMAGE} \
                      --set castService.image.tag=${IMAGE_TAG}
                """
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
    }
}