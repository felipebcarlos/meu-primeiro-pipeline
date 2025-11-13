pipeline {
    agent any

    environment {
        // --- ❗️❗️❗️ VERIFIQUE ESTA SECÇÃO ❗️❗️❗️ ---
        // Coloque aqui o seu nome de utilizador do Docker Hub
        DOCKERHUB_USER = 'felipebcarlos'
        
        // O nome da sua aplicação/imagem
        APP_NAME = 'meu-primeiro-pipeline'
        
        // O IP da sua VM 2 (Produção)
        VM_PROD_IP = '192.168.15.3' 
        
        // O utilizador com que acede via SSH à sua VM 2
        VM_PROD_USER = 'ubuntu' 
        // -------------------------------------
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
                echo "Construindo a imagem: $DOCKERHUB_USER/$APP_NAME"
                sh "docker build -t $DOCKERHUB_USER/$APP_NAME:latest ."
                sh "docker tag $DOCKERHUB_USER/$APP_NAME:latest $DOCKERHUB_USER/$APP_NAME:$BUILD_NUMBER"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo "Publicando a imagem no Docker Hub..."
                withCredentials([usernamePassword(credentialsId: 'DOCKERHUB_CREDS', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                    sh "docker push $DOCKERHUB_USER/$APP_NAME:latest"
                    sh "docker push $DOCKERHUB_USER/$APP_NAME:$BUILD_NUMBER"
                }
            }
        }

        // --- STAGE DE DEPLOY CORRIGIDO ---
        
        stage('Deploy to Production') {
            steps {
                echo "A fazer deploy da versão $BUILD_NUMBER para a VM 2 ($VM_PROD_IP)"
                
                // Carrega AMBAS as credenciais
                withCredentials([
                    sshUserPrivateKey(credentialsId: 'VM_PROD_SSH_KEY', keyFileVariable: 'SSH_KEY_FILE'),
                    string(credentialsId: 'DOCKERHUB_TOKEN', variable: 'DOCKER_TOKEN_VAR')
                ]) {
                    
                    // Script SH agora usa a sintaxe de shell correta (ex: $VM_PROD_USER)
                    sh '''
                    ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE $VM_PROD_USER@$VM_PROD_IP \'
                        echo "--- (VM 2) Ligado via SSH. A fazer o deploy..." && \
                        
                        echo "--- (VM 2) A fazer login no Docker Hub..." && \
                        echo $DOCKER_TOKEN_VAR | docker login -u $DOCKERHUB_USER --password-stdin && \

                        echo "--- (VM 2) A parar o container antigo (se existir)..." && \
                        docker stop $APP_NAME || true && \
                        docker rm $APP_NAME || true && \

                        echo "--- (VM 2) A puxar a nova imagem (build $BUILD_NUMBER)..." && \
                        docker pull $DOCKERHUB_USER/$APP_NAME:$BUILD_NUMBER && \

                        echo "--- (VM 2) A iniciar o novo container..." && \
                        docker run -d --name $APP_NAME -p 3000:3000 $DOCKERHUB_USER/$APP_NAME:$BUILD_NUMBER && \
                        
                        echo "--- (VM 2) A fazer logout do Docker Hub..." && \
                        docker logout && \

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
