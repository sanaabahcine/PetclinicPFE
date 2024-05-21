pipeline {
    agent any
    
    tools {
        jdk 'jdk17'
        maven 'maven3'
    }
    
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        KUBECONFIG = 'C:/Users/Dell/.kube/config'
        DOCKER_HUB_REPO = 'sanaeabahcine371/petclinic1'
    }
    
    stages {
        stage('Clean workspace') {
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
                    def version = sh(script: "mvn help:evaluate -Dexpression=project.version -q -DforceStdout", returnStdout: true).trim()
                    env.PROJECT_VERSION = version
                }
            }
        }
    
        stage('Build and Push Docker Image') {
            steps {
                script {
                    sh "docker build -t petclinic-image ."
                    sh "docker tag petclinic-image ${DOCKER_HUB_REPO}:${PROJECT_VERSION}"
                    sh "docker push ${DOCKER_HUB_REPO}:${PROJECT_VERSION}"
                }
            }
        }
        
        stage('Check Kubernetes Connectivity') {
            steps {
                script {
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
        
        stage('Update Helm Chart') {
            steps {
                script {
                    sh 'git config --global user.email "sanae.abahcine@esi.ac.ma"'
                    sh 'git config --global user.name "sanaabahcine"'
                    sh "sed -i 's/tag: latest/tag: ${PROJECT_VERSION}/g' ./petclinic/values.yaml"
                    sh 'git add ./petclinic/values.yaml'
                    sh 'git commit -m "Update image tag in values.yaml"'
                    sh 'git pull --rebase origin main'
                    sh 'git push origin main'
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
stage('Update Helm Chart') {
            steps {
                script {
                    // Configuration de l'identité Git dans le pipeline
                    sh 'git config --global user.email "sanae.abahcine@esi.ac.ma"'
                    sh 'git config --global user.name "sanaabahcine"'

                    // Modification du fichier values.yaml
                    sh "sed -i 's/tag: latest/tag: ${PROJECT_VERSION}/g' ./petclinic/values.yaml"

                    // Ajout et commit des modifications
                    sh 'git add ./petclinic/values.yaml'
                    sh 'git commit -m "Update image tag in values.yaml"'

                    // Tirer les modifications depuis la branche principale distante avec rebase pour éviter les conflits de fusion
                    sh 'git pull --rebase origin main'

                    // Pousser les modifications locales fusionnées vers la branche principale distante
                    sh 'git push origin main'
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
