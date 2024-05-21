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
        stage('Checkout Main Repo') {
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
                    
                    // Extract version from pom.xml
                    def version = sh(script: "mvn help:evaluate -Dexpression=project.version -q -DforceStdout", returnStdout: true).trim()

                    // Tag the Docker image
                    sh "docker tag petclinic-image sanaeabahcine371/petclinic1:${version}"
                    
                    // Push the Docker image to Docker Hub
                    sh "docker push sanaeabahcine371/petclinic1:${version}"
                }
            }
        }
        
        stage('update_helm_chart') {
            steps {
                script {
                    def version = sh(script: "mvn help:evaluate -Dexpression=project.version -q -DforceStdout", returnStdout: true).trim()
                    
                    // Replace the tag in values.yaml with the newly built Docker image tag
                    sh "sed -i 's/tag: latest/tag: ${version}/g' ./petclinic/values.yaml"
                    
                    // Commit and push the changes back to the repository
                    sh "git add ./petclinic/values.yaml"
                    sh "git commit -m 'Update image tag in values.yaml'"
                    sh "git push origin main"
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
        
        stage('Checkout Helm Repo') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']], 
                    userRemoteConfigs: [[
                        url: 'https://github.com/sanaabahcine/helm_chart_petclinic.git', 
                        credentialsId: 'github1' 
                    ]]
                ])
            }
        }
        
        stage('Deploy to AKS') {
            steps {
                script {
                    sh "helm upgrade --install petclinic ./petclinic --values ./petclinic/values.yaml --kubeconfig=${KUBECONFIG}"
                }
            }
        }
    }
}
