pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh "docker build -t shoestore:5 ."
            }
        }
        stage('Deploy') {
            steps {
                sh "docker rm -f shoestore || true"
                sh "docker run -d -p 8080:80 --name shoestore2 shoestore:5"
            }
        }
    }
}