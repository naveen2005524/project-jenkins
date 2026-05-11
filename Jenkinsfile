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
                sh "docker run -d -p 8082:80 --name shoestore8 shoestore:6"
            }
        }
        stage('stop') {
            steps {
                sh "docker stop -f shoestore5 || true"
            }
        }
        stage('remove') {
            steps {
                sh "docker rm -f shoestore5 || true"
                sh "sudo docker container prune"
                sh "sudo docker image prune"
            }
        }
    }
}