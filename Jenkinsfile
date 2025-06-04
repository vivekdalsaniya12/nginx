@Library('shared-lib') _
pipeline {

    agent any

    environment {
        DEPLOYMENT_FILE = 'deployment.yml'
        IMAGE_NAME = 'vivekdalsaniya/nginx-web'
        NEW_TAG = "${BUILD_NUMBER}"  // or get it from Git tag/sha
    }

    stages {
        stage('Checkout from GitHub') {
            steps {
                codeClone("master", "https://github.com/vivekdalsaniya12/nginx.git")
                ls
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
                    codeClone("main", "https://github.com/vivekdalsaniya12/manifests.git")
                    ls
                    // Replace image tag using sed (cross-platform safe version)
                    sh """
                    sed -i.bak 's|${IMAGE_NAME}:.*|${IMAGE_NAME}:${NEW_TAG}|' ${DEPLOYMENT_FILE}
                    rm -f ${DEPLOYMENT_FILE}.bak
                    """

                    // Optional: show the diff
                    sh "git diff ${DEPLOYMENT_FILE}"

                    // Git commit and push
                    sh """
                    git config user.name "vivekdalsaniya12"
                    git config user.email "vivekdalsaniya12@gmail.com"
                    git add ${DEPLOYMENT_FILE}
                    git commit -m "CI: Update image to ${IMAGE_NAME}:${NEW_TAG}"
                    git push origin main
                    """
                }
            }
        }
    }
}