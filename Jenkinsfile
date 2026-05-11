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
        stage('stop') {
            steps {
                sh "docker stop -f shoestore5 || true"
            }
        }
        stage('remove') {
            steps {
                sh "docker rm -f shoestore5 || true"
                sh "sudo docker rm $(sudo docker ps -a -q)"
                sh "sudo docker rmi $(sudo docker images -a -q)"
            }
        }
    }
}