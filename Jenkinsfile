pipeline {
    agent any
    tools {
        jdk 'jdk17'
        maven 'maven3'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
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
        stage('mvn test') {
            steps {
                sh 'mvn clean test jacoco:report'
            }
        }
        stage("Sonarqube Analysis") {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectKey=Petclinic \
                        -Dsonar.projectName=Petclinic \
                        -Dsonar.projectVersion=1.0 \
                        -Dsonar.sources=src/ \
                        -Dsonar.java.binaries=. \
                        -Dsonar.junit.reportsPath=target/surefire-reports/ \
                        -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml \
                        -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
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
                    // Build the Docker image
                    sh "docker build -t petclinic-image ."
                    
                    // Tag the Docker image
                    sh "docker tag petclinic-image sanaeabahcine371/petclinic1:latest"
                    
                    // Push the Docker image to Docker Hub
                    sh "docker push sanaeabahcine371/petclinic1:latest"
                }
            }
        }
        stage("Deploy to Kubernetes") {
            steps {
                script {
                    // Deploy the application using Helm
                    sh "helm upgrade --install petclinic ./petclinic-chart --values ./petclinic-chart/values.yaml"
                }
            }
        }
    }
}
