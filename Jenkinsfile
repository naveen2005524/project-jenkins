pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh "docker build -t shoestore:6 ."
            }
        }
        stage('Deploy') {
            steps {
                sh "docker rm -f shoestore6 || true"
                sh "docker run -d -p 8082:80 --name shoestore5 shoestore:6"
            }
        }
    }
}