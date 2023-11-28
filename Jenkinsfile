if (env.BRANCH_NAME == "${env.BRANCH}") {
    env.AWS_ACCOUNT = "${env.ACCOUNT_ID}"
}
pipeline {
    agent any
    parameters {
        string(name: 'NAME', defaultValue: 'navi-dracs-test', description: 'Ecr Repository Name')
        string(name: 'BRANCH', defaultValue: 'main', description: 'Git Branch Name')
        choice(name: 'AWS_ACCOUNT', choices: ['123432287013', '123432287023',], description: 'AWS Account ID')
        string(name: 'CLUSTER', defaultValue: 'dracs-test-dev-cluster', description: 'ECS Cluster Name')
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
        ACCOUNT_ID = "${params.AWS_ACCOUNT}"
        REGION = "us-east-1"
        ECR_REPO_NAME = "${params.NAME}"
        VERSION = "${BUILD_NUMBER}-${env.GIT_COMMIT}"
        IMAGE_TAG = "${VERSION}"
        TAG = "latest"
        BRANCH = "${params.BRANCH}"
        REPOSITORY_URI = "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO_NAME}"
        ECS_CLUSTER = "${params.CLUSTER}"
    }
    stages{
        stage('Git Checkout') {
            steps {
                echo 'git pull'
                git branch: '$BRANCH', credentialsId: '9fe95b1f-883e-4166-9743-a57c84d7ca17', url: 'https://github.com/suppada/ecs-deploy.git'
            }
        }
        stage('Maven Build'){
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
        stage('Docker Build') {
            steps {
                sh '''
                    /opt/homebrew/Cellar/awscli/2.13.32/bin/aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REPOSITORY_URI 
                    docker build -t $ECR_REPO_NAME .
                    docker tag $ECR_REPO_NAME:$TAG $REPOSITORY_URI:$VERSION
                '''
            }
        }
        stage('Docker Image Push To ECR') {
            steps {
                sh '''
                    docker push $REPOSITORY_URI:$VERSION
                '''
            }
        }
        stage('Deploy to ECS') {
            steps {
                sh '''
                    /opt/homebrew/Cellar/awscli/2.13.32/bin/aws ecs register-task-definition --cli-input-json "file://ecs/image.json"
                '''
            }
        }
    }
    post {
        always {
            echo 'Deleting all local images'
            sh '''
                docker image prune -af
            '''
        }
    }
}
