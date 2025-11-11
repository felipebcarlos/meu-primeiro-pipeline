pipeline {
    // 1. O agente 'any' diz para rodar no nó principal
    // (O nosso 'meu-jenkins-docker', que tem o CLI do Docker)
    agent any

    environment {
        // 2. MUDE AQUI!
        // Coloque o seu nome de usuário do Docker Hub
        DOCKERHUB_USER = 'felipebcarlos'
        APP_NAME = 'meu-primeiro-pipeline'
    }

    stages {
        stage('Test') {
            // 3. Boa prática: testar num ambiente limpo
            agent { docker { image 'node:lts-buster-slim' } }
            steps {
                sh 'npm install'
                // sh 'npm test' // (Aqui é onde os testes rodariam)
            }
        }
        
        stage('Build Image') {
            steps {
                echo "Construindo a imagem: ${env.DOCKERHUB_USER}/${env.APP_NAME}"
                
                // 4. Constrói a imagem usando o Dockerfile
                sh "docker build -t ${env.DOCKERHUB_USER}/${env.APP_NAME}:latest ."
                
                // 5. Cria uma tag única com o número do build (ex: :1, :2)
                sh "docker tag ${env.DOCKERHUB_USER}/${env.APP_NAME}:latest ${env.DOCKERHUB_USER}/${env.APP_NAME}:${env.BUILD_NUMBER}"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo "Publicando a imagem no Docker Hub..."
                
                // 6. Usa o "cofre" (ID: DOCKERHUB_CREDS) para fazer login
                withCredentials([usernamePassword(credentialsId: 'DOCKERHUB_CREDS', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                    
                    // 7. Envia as duas tags para o Docker Hub
                    sh "docker push ${env.DOCKERHUB_USER}/${env.APP_NAME}:latest"
                    sh "docker push ${env.DOCKERHUB_USER}/${env.APP_NAME}:${env.BUILD_NUMBER}"
                }
            }
        }
    }
    
    post {
        // 8. Limpeza: Faz logout do Docker Hub
        always {
            sh 'docker logout'
        }
    }
}
