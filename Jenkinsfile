pipeline {
    agent any
    tools {
        jdk 'jdk17'
        maven 'maven3'
    }
    environment {
       
           SCANNER_HOME=tool 'sonar-scanner'
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
                sh 'mvn test'
            }
        }
        stage("Sonarqube Analysis") {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                   
                           sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Petclinic \
                       -Dsonar.projectName=Petclinic \
                       -Dsonar.projectVersion=1.0 \
                       -Dsonar.sources=src/ \
                           -Dsonar.java.binaries=. \
                       -Dsonar.junit.reportsPath=target/surefire-reports/ \
                       -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                       -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
                }
            }
        }
        stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
                    // true = set pipeline to UNSTABLE, false = don't
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('mvn build') {
            steps {
                sh 'mvn clean install'
            }
        }
        stage("OWASP Dependency Check") {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --format HTML ', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.html'
            }
        }
        stage("Docker Build & Push") {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {   
                        sh "docker build -t petclinic1 ."
                        sh "docker tag petclinic1 sanaeabahcine371/petclinic1:latest "
                        sh "docker push sanaeabahcine371/petclinic1:latest "
                    }
                }
            }
        }
    }
}
