@Library('shared-lib') _
pipeline {

    agent any

    environment {
        DEPLOYMENT_FILE = 'deployment.yaml'
        IMAGE_NAME = 'vivekdalsaniya/nginx-web'
        NEW_TAG = "${BUILD_NUMBER}"  // or get it from Git tag/sha
    }

    stages {
        stage('Checkout from GitHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nginx-web', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    codeClone("master", "https://${USERNAME}:${PASSWORD}@github.com/vivekdalsaniya12/nginx.git")
                }
            }
        }

        stage('Docker Build') {
            steps {
                dockerBuild("vivekdalsaniya/nginx-web", "${BUILD_NUMBER}", ".")
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockercreds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    dockerPush("${USERNAME}", "${PASSWORD}", "${IMAGE_NAME}", "${BUILD_NUMBER}")
                }
            }
        }
        stage('Update Manifest') {
            steps {
                script {
                    echo "Updating image to ${IMAGE_NAME}:${NEW_TAG} in ${DEPLOYMENT_FILE}"
                    // clone the repository if not already done
                    withCredentials([usernamePassword(credentialsId: 'nginx-web', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        codeClone("main", "https://${USERNAME}:${PASSWORD}@github.com/vivekdalsaniya12/manifests.git")
                    }
                    // Replace image tag using sed (cross-platform safe version)
                    sh """
                    sed -i.bak 's|${IMAGE_NAME}:.*|${IMAGE_NAME}:${NEW_TAG}|' ${DEPLOYMENT_FILE}
                    rm -f ${DEPLOYMENT_FILE}.bak
                    """

                    // Optional: show the diff
                    sh "git diff ${DEPLOYMENT_FILE}"

                    // Git commit and push
                    sh '''
                    git config user.name "vivekdalsaniya12"
                    git config user.email "vivekdalsaniya12@gmail.com"
                    git config --global --add safe.directory $(pwd)
                    git add ${DEPLOYMENT_FILE}
                    git commit -m "CI: Update image to ${IMAGE_NAME}:${NEW_TAG}"
                    '''
                    withCredentials([usernamePassword(credentialsId: 'nginx-web', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh 'git push https://${USERNAME}:${PASSWORD}@github.com/vivekdalsaniya12/manifests.git'
                    }
                }
            }
        }
    }
}