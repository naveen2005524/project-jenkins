pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh "docker build -t shoestore:${env.BUILD_ID} ."
            }
        }
        stage('Deploy') {
            steps {
                sh "docker run -d -p 8080:80 --name shoestore shoestore:${env.BUILD_ID}"
            }
        }
    }
}