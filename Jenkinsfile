pipeline {
    agent any
    options {
        buildDiscarder(logRotator(daysToKeepStr: '1', numToKeepStr: '3'))
        disableConcurrentBuilds()
        
    }
    environment {
        ACCOUNT_ID = "123432287013"
        REGION = "us-east-1"
        IMAGE_TAG = 'latest'
        ECR_REPO_NAME = 'navi-dracs-test'
        REPOSITORY_URI = "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO_NAME}"
    }
    stages{
        // stage('gitcheckout') {
        //     steps {
        //         echo 'git pull'
        //         checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/suppada/ecs-deploy.git']]])
        //     }
        // }
        stage('Push image to ECR') {
            steps {
                sh '''
                    /opt/homebrew/Cellar/awscli/2.13.32/bin/aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $REPOSITORY_URI 
                    docker tag $ECR_REPO_NAME:$IMAGE_TAG $REPOSITORY_URI:$IMAGE_TAG
                    docker push $REPOSITORY_URI:$imageTag
                '''
            }
        }
    }
}