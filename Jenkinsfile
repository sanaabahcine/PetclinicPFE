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
            def newImageTag = "${DOCKER_HUB_REPO}:${PROJECT_VERSION}"
            sh "sed -i 's|tag:.*|tag: ${newImageTag.split(':')[1]}|'  ./petclinic/values.yaml"
          
        }
    }
}

        stage('Commit and Push Changes to Helm Repository') {
    steps {
        script {
            sh 'git config --global user.email "sanae.abahcine@esi.ac.ma"'
            sh 'git config --global user.name "sanaabahcine"'
            sh 'git add ./petclinic/values.yaml'
            sh 'git commit -m "Update image tag in values.yaml"'
            sh 'git push origin main'
        }
    }
}


        stage('Print Updated values.yaml') {
    steps {
        script {
            sh "cat ./petclinic/values.yaml"
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
