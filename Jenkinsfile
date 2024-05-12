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
        stage("Quality Gate") {
    steps {
       
            // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
            // true = set pipeline to UNSTABLE, false = don't
            waitForQualityGate abortPipeline: true
        
    }
}




      
    
    }
}
