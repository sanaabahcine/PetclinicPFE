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
        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }
        stage('Unit Tests') {
            steps {
                // Run your unit tests here
            }
        }
        stage('Package') {
            steps {
                sh 'mvn clean package'
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
        stage('Check Kubernetes Connectivity') {
            steps {
                script {
                    // Execute a kubectl command to get the list of nodes in the Kubernetes cluster
                    sh "kubectl --kubeconfig=${KUBECONFIG} get nodes"
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
