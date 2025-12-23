pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        CLUSTER_NAME = "ecommerce-eks"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Configure kubectl') {
            steps {
                sh '''
                aws eks update-kubeconfig \
                  --name $CLUSTER_NAME \
                  --region $AWS_REGION
                '''
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                kubectl apply -f k8s/
                '''
            }
        }
    }
}
