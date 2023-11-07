pipeline {
    agent any
    options {
        buildDiscarder(logRotator(daysToKeepStr: '1', numToKeepStr: '3'))
        disableConcurrentBuilds()
        
    }
    environment {
        registry = '123432287013.dkr.ecr.us-east-1.amazonaws.com/navi-dracs-test'
        dockerImage = 'latest'
    }
    stages{
        stage('gitcheckout') {
            steps {
                echo 'git pull'
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/suppada/ecs-deploy.git']]])
            }
        }
        stage('Push image to ECR') {
            steps {
                sh '''
                    /opt/homebrew/Cellar/awscli/2.13.32/bin/aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123432287013.dkr.ecr.us-east-1.amazonaws.com
                    docker build -t navi-dracs-test .
                    docker push image_name_containing_repo_name
                    docker tag navi-dracs-test:latest 123432287013.dkr.ecr.us-east-1.amazonaws.com/navi-dracs-test:latest
                    docker push 123432287013.dkr.ecr.us-east-1.amazonaws.com/navi-dracs-test:latest
                '''
            }
        }
    }
}