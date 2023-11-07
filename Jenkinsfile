pipeline {
    agent any
    options {
        buildDiscarder(logRotator(daysToKeepStr: '1', numToKeepStr: '3'))
        disableConcurrentBuilds()
        
    }
    environment {
        registry = '123432287013.dkr.ecr.us-east-1.amazonaws.com/navi-dracs-test'
        imageTag = 'latest'
        ecrRepoName = 'navi-dracs-test'
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
                    /opt/homebrew/Cellar/awscli/2.13.32/bin/aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $registry
                    docker tag "$ecrRepoName:$imageTag" "$registry:$imageTag"
                    docker push "$registry:$imageTag"
                '''
            }
        }
    }
}