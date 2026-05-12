pipeline {
    agent any
    stages {
        stage('terraform') {
            steps {
                sh "terraform init"
                sh "terraform validate"
                sh "terraform plan"
                sh "terraform apply -auto-approve"
            }
        }
        stage('outputs') {
            steps {
                sh "terraform output public_ip"
            }
        }
        // stage('destroy') {
        //     steps {
        //         sh "terraform destroy -auto-approve"
        //     }
        // }
    }
}