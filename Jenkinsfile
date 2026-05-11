pipeline {
    agent any
    stages {
        stage('kubectl') {
            steps {
                sh "kubectl apply -f deployment.yml "
            }
        }
        stage('pods') {
            steps {
                sh "kubectl get pods"
                sh "minikube start"
                sh "minikube service shoestore1 --url"
            }
        }
    }
}