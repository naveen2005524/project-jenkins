pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh "kubectl apply -f deployment.yml "
            }
        }
        stage('pods') {
            steps {
                sh "kubectl get pods"
            }
        }
    }
}