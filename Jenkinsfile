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
        
        stage('Checkout main repo') {
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
        
        stage('Unit Tests') {
            steps {
                sh 'mvn clean test jacoco:report'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'  // Archive JUnit reports for Jenkins
                    jacoco execPattern: 'target/jacoco.exec'  // Archive JaCoCo reports
                }
            }
        }

        stage('Sonarqube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh '''
                        $SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectKey=Petclinic \
                        -Dsonar.projectName=Petclinic \
                        -Dsonar.projectVersion=${PROJECT_VERSION} \
                        -Dsonar.sources=src/ \
                        -Dsonar.java.binaries=target/classes \
                        -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
                    '''
                }
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
        
        stage('Checkout Helm Repo') {
            steps {
                dir('helm_chart_petclinic') {
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: '*/main']],
                        userRemoteConfigs: [[
                            url: 'https://github.com/sanaabahcine/helm_chart_petclinic.git',
                            credentialsId: 'github1'
                        ]]
                    ])
                    sh 'git checkout main'
                }
            }
        }

        stage('Update Helm Chart') {
            steps {
                dir('helm_chart_petclinic') {
                    script {
                        def newImageTag = "${DOCKER_HUB_REPO}:${PROJECT_VERSION}"
                        sh "sed -i 's|tag:.*|tag: ${newImageTag.split(':')[1]}|' ./petclinic/values.yaml"
                    }
                }
            }
        }

        stage('Commit and Push Changes to Helm Repository') {
            steps {
                dir('helm_chart_petclinic') {
                    script {
                        sh 'git config --global user.email "sanae.abahcine@esi.ac.ma"'
                        sh 'git config --global user.name "sanaabahcine"'
                        
                        // Vérifier s'il y a des modifications dans le répertoire de travail
                        def gitStatus = sh(script: 'git status --porcelain', returnStatus: true)
                        
                        if (gitStatus != 0) {
                            // S'il y a des modifications, ajouter, valider et pousser les modifications
                            sh 'git add ./petclinic/values.yaml'
                            sh 'git commit -m "Update image tag in values.yaml"'
                            sh 'git pull origin main --rebase'
                            sh 'git push origin main'
                        } else {
                            echo 'Aucune modification à valider et à pousser.'
                        }
                    }
                }
            }
        }

        stage('Deployment') {
            steps {
                script {
                    sh "helm upgrade --install petclinic ./helm_chart_petclinic/petclinic --values ./helm_chart_petclinic/petclinic/values.yaml --kubeconfig=${KUBECONFIG}"
                }
            }
        }
    }
}
