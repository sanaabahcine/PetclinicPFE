pipeline {
    agent any
    tools {
        jdk 'jdk17'
        maven 'maven3'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        KUBECONFIG = 'C:\\Users\\Dell\\.kube\\config' // Chemin vers le fichier kubeconfig de Rancher Desktop
    }
    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/sanaabahcine/PetclinicPFE.git'
            }
        }
         stage('mvn compile') {
            steps {
                sh 'mvn clean compile'
            }
        }
        stage('mvn test') {
            steps {
                sh 'mvn clean test jacoco:report'
            }
      
        }
        stage('Build and Push Docker Image') {
            steps {
                script {
                    // Build the Docker image
                    sh "docker build -t petclinic-image ."
                    
                    // Tag the Docker image
                    sh "docker tag petclinic-image sanaeabahcine371/petclinic1:latest"
                    
                    // Push the Docker image to Docker Hub
                    sh "docker push sanaeabahcine371/petclinic1:latest"
                }
            }
        }
     
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Deploy the application using Helm with the Kubernetes context from Rancher Desktop
                    sh "helm --kubeconfig=${KUBECONFIG} upgrade --install petclinic ./petclinic-chart --values ./petclinic-chart/values.yaml"
                }
            }
        }
    }
}
