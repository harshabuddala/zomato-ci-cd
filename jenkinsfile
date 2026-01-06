pipeline {
    agent any

    environment {
        // REPLACE THIS WITH YOUR ECR REPO URI {(e.g. 123456789012.dkr.ecr.ap-south-1.amazonaws.com/bookmyshow-app)}
        ECR_REPO_URI = '460474850557.dkr.ecr.ap-south-1.amazonaws.com/zomato'
        AWS_REGION = 'ap-south-1' 
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo 'Building Docker Image...'
                    sh "docker build -t ${ECR_REPO_URI}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    echo 'Logging into ECR...'
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO_URI}"
                    
                    echo 'Pushing Docker Image...'
                    sh "docker push ${ECR_REPO_URI}:${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy to Dev') {
            steps {
                script {
                    echo 'Deploying to Dev Environment...'
                    // Run Ansible playbook
                    sh "ansible-playbook ansible/deploy.yml -e \"env=dev image_tag=${IMAGE_TAG} ecr_repo=${ECR_REPO_URI}\""
                }
            }
        }
        
        stage('Validation') {
            steps {
                echo 'Validating Dev Environment...'
                // You can add automated tests here (e.g. curl check)
                sh "kubectl get pods -n dev"
                sh "kubectl get svc -n dev"
            }
        }

        stage('Manual Approval') {
            steps {
                script {
                    env.PROCEED_TO_PROD = input message: 'User verification required',
                                        parameters: [choice(name: 'Promote to Production?', choices: 'yes\nno', description: 'Check Grafana/Prometheus before approving')]
                }
            }
        }

        stage('Deploy to Prod') {
            when {
                expression { env.PROCEED_TO_PROD == 'yes' }
            }
            steps {
                script {
                    echo 'Deploying to Production Environment...'
                    sh "ansible-playbook ansible/deploy.yml -e \"env=prod image_tag=${IMAGE_TAG} ecr_repo=${ECR_REPO_URI}\""
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline execution finished.'
            // Clean up docker images to save space (optional)
            sh "docker rmi ${ECR_REPO_URI}:${IMAGE_TAG} || true"
        }
    }
}
