pipeline {
    agent any
    tools {
        jdk 'jdk17'
        maven 'maven3'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
           KUBECONFIG = 'C:/Users/Dell/.kube/config'
    }
    stages {
        stage('clean workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout From Git') {
            steps {
                git branch: 'main', url: 'https://github.com/sanaabahcine/PetclinicPFE.git'
            }
        }
        stage('mvn compile') {
            steps {
                sh 'mvn clean compile'
            }
        }
    
     
        stage('mvn build') {
            steps {
                sh 'mvn clean install'
            }
        }
        stage("Build and Push Docker Image") {
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

                   
sh "helm --kubeconfig=C:/Users/Dell/.kube/config upgrade --install petclinic PetclinicPFE/petclinic --values PetclinicPFE/petclinic/values.yaml"




                        }
            }
        }
    }
}
