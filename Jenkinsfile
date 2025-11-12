pipeline {
    agent any

    environment {
        // --- PREENCHA ISTO ---
        DOCKERHUB_USER = 'felipebcarlos' // O seu utilizador Docker Hub
        APP_NAME = 'meu-primeiro-pipeline' // O nome da imagem
        VM_PROD_IP = '192.168.15.3' // ❗️ O IP da sua VM 2
        VM_PROD_USER = 'braga' // ❗️ O utilizador SSH da sua VM 2
        // ---------------------
    }

    stages {
        stage('Test') {
            agent { docker { image 'node:lts-buster-slim' } }
            steps {
                sh 'npm install'
            }
        }
        
        stage('Build Image') {
            steps {
                sh "docker build -t ${env.DOCKERHUB_USER}/${env.APP_NAME}:latest ."
                sh "docker tag ${env.DOCKERHUB_USER}/${env.APP_NAME}:latest ${env.DOCKERHUB_USER}/${env.APP_NAME}:${env.BUILD_NUMBER}"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DOCKERHUB_CREDS', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                    sh "docker push ${env.DOCKERHUB_USER}/${env.APP_NAME}:latest"
                    sh "docker push ${env.DOCKERHUB_USER}/${env.APP_NAME}:${env.BUILD_NUMBER}"
                }
            }
        }

        // --- NOVO STAGE ABAIXO ---

        stage('Deploy to Production') {
            steps {
                echo "A fazer deploy da versão ${env.BUILD_NUMBER} para a VM 2 (${env.VM_PROD_IP})"
                
                // 1. Usa a credencial SSH (ID: VM_PROD_SSH_KEY) que guardámos no "Cofre"
                withCredentials([sshUserPrivateKey(credentialsId: 'VM_PROD_SSH_KEY', keyFileVariable: 'SSH_KEY_FILE')]) {
                    
                    // 2. O Jenkins irá ligar-se à VM 2 via SSH e executar os comandos
                    sh '''
                    ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE ${env.VM_PROD_USER}@${env.VM_PROD_IP} \'
                        echo "--- (VM 2) Ligado via SSH. A fazer o deploy..." && \
                        
                        docker login -u ${env.DOCKERHUB_USER} -p $DOCKER_PASSWORD && \

                        echo "--- (VM 2) A parar o container antigo (se existir)..." && \
                        docker stop ${env.APP_NAME} || true && \
                        docker rm ${env.APP_NAME} || true && \

                        echo "--- (VM 2) A puxar a nova imagem do Docker Hub..." && \
                        docker pull ${env.DOCKERHUB_USER}/${env.APP_NAME}:${env.BUILD_NUMBER} && \

                        echo "--- (VM 2) A iniciar o novo container..." && \
                        docker run -d --name ${env.APP_NAME} -p 3000:3000 ${env.DOCKERHUB_USER}/${env.APP_NAME}:${env.BUILD_NUMBER} && \
                        
                        echo "--- (VM 2) Deploy concluído!"
                    \'
                    '''
                }
            }
        }
    }
    
    post {
        always {
            sh 'docker logout'
        }
    }
}
