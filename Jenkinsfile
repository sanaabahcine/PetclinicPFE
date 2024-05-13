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
        // Étapes précédentes du pipeline
        // ...
        
        stage('Check Kubernetes Connectivity') {
            steps {
                script {
                    // Exécutez une commande kubectl pour obtenir la liste des nœuds dans le cluster Kubernetes
                    sh "kubectl --kubeconfig=${KUBECONFIG} get nodes"
                }
            }
        }
        stage("Deploy to Kubernetes") {
            steps {
                script {
                    // Déployez l'application en utilisant Helm avec le contexte Kubernetes de Rancher Desktop
                    sh "helm --kubeconfig=${KUBECONFIG} upgrade --install petclinic ./petclinic-chart --values ./petclinic-chart/values.yaml"
                }
            }
        }
    }
}
