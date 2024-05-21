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
         stage('Get Version from Petclinic Code') {
            steps {
                script {
                    // Obtention de la version du projet Petclinic
                    def version = sh(script: "mvn help:evaluate -Dexpression=project.version -q -DforceStdout", returnStdout: true).trim()
                    env.PROJECT_VERSION = version
                }
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
                    branches: [[name: '*/main']], // Spécifiez la branche que vous souhaitez récupérer
                    userRemoteConfigs: [[
                        url: 'https://github.com/sanaabahcine/helm_chart_petclinic.git', // URL du nouveau référentiel
                        credentialsId: 'github1' // ID des identifiants à utiliser
                    ]]
                ])
            }
        }
stages {
        stage('Update Helm Chart') {
            steps {
                script {
                    // Configure Git user
                    sh 'git config --global user.email sanae.abahcine@esi.ac.ma'
                    sh 'git config --global user.name sanaabahcine'
                    
                    // Update image tag in values.yaml
                    sh "sed -i 's/tag: latest/tag: 5.3.13/g' ./petclinic/values.yaml"
                    
                    // Add changes to Git
                    sh 'git add ./petclinic/values.yaml'
                    
                    // Commit changes
                    sh 'git commit -m "Update image tag in values.yaml"'
                    
                    // Pull latest changes from remote repository
                    sh 'git pull --rebase origin main'
                    
                    // Push changes to remote repository, forcing the update
                    sh 'git push --force origin main'
                }
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
