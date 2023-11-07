pipeline {
    agent any
    parameters {
        string(name: 'ecr repo', defaultValue: 'navi-dracs-test', description: 'Ecr Repository Name')
    }
    options {
        timestamps()
        buildDiscarder(logRotator(artifactDaysToKeepStr: '4', artifactNumToKeepStr: '3', daysToKeepStr: '3', numToKeepStr: '3'))
        timeout(time: 10, unit: 'MINUTES')
    }
    tools {
      maven 'maven3'
    }
    environment {
        ACCOUNT_ID = "123432287013"
        REGION = "us-east-1"
        ECR_REPO_NAME = "${name}"
        VERSION = "${BUILD_NUMBER}-${env.GIT_COMMIT}"
        IMAGE_TAG = "${VERSION}"
        TAG = 'latest'
        REPOSITORY_URI = "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO_NAME}"
    }
    stages{
        stage('Build'){
            steps{
                 sh 'mvn clean compile install package'
                 archiveArtifacts artifacts: 'target/*.war', onlyIfSuccessful: true
            }
            post {
                always {
                    echo 'Test run completed'
                    junit allowEmptyResults: true, testResults: '**/target/*.xml'
                }
            }
        }
        stage('Push image to ECR') {
            steps {
                sh '''
                    /opt/homebrew/Cellar/awscli/2.13.32/bin/aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $REPOSITORY_URI 
                    docker build -t $ECR_REPO_NAME .
                    docker tag $ECR_REPO_NAME:$TAG $REPOSITORY_URI:$VERSION
                    docker push $REPOSITORY_URI:$VERSION
                '''
            }
        }
    }
}