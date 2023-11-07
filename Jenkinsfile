pipeline {
    agent any
    options {
        buildDiscarder(logRotator(daysToKeepStr: '1', numToKeepStr: '3'))
        disableConcurrentBuilds()
        
    }
    environment {
        ACCOUNT_ID = "123432287013"
        REGION = "us-east-1"
        ECR_REPO_NAME = 'navi-dracs-test'
        VERSION = "${env.BUILD_ID}-${env.GIT_COMMIT}"
        IMAGE_TAG = "${VERSION}"
        TAG = 'latest'
        REPOSITORY_URI = "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO_NAME}"
    }
    stages{
        stage('Push image to ECR') {
            steps {
                sh '''
                    /opt/homebrew/Cellar/awscli/2.13.32/bin/aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $REPOSITORY_URI 
                    docker build -t ${NAME} .
                    docker tag $ECR_REPO_NAME:$TAG $REPOSITORY_URI:$IMAGE_TAG
                    docker push $REPOSITORY_URI:$IMAGE_TAG
                '''
            }
        }
    }
}