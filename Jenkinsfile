if (env.BRANCH_NAME == "${params.BRANCH}") {
    env.AWS_ACCOUNT = "${params.AWS_ACCOUNT}"
}
pipeline {
    agent any
    parameters {
        string(name: 'NAME', defaultValue: 'navi-dracs-test', description: 'Ecr Repository Name')
        string(name: 'BRANCH', defaultValue: 'main', description: 'Git Branch Name')
        choice(name: 'AWS_ACCOUNT', choices: ['123432287013', '123432287023',], description: 'AWS Account')
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
        REPOSITORY_URI = "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO_NAME}"
    }
    stages{
        stage('Git Checkout') {
            steps {
                echo 'git pull'
                checkout([$class: 'GitSCM', branches: [[name: '${params.Branch}']], credentialsId: 'github', extensions: [], userRemoteConfigs: [[url: 'https://github.com/suppada/ecs-deploy.git']]])
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
                    /opt/homebrew/Cellar/awscli/2.13.32/bin/aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $REPOSITORY_URI 
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
        // stage('Deploy to ECS') {
        //     steps {
        //         sh 'aws ecs update-service --cluster to-do-app --desired-count 1 --service to-do-app-service --task-definition to-do-app --force-new-deployment'
        //     }
        // }
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