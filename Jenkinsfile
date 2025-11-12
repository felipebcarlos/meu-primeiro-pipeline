pipeline {
    // 1. O agente 'any' diz para rodar no nó principal
    // (O nosso 'meu-jenkins-docker', que tem o CLI do Docker)
    agent any

    environment {
        // --- ❗️❗️❗️ EDITE ESTA SECÇÃO ❗️❗️❗️ ---
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
            // Boa prática: testar num ambiente limpo
            agent { docker { image 'node:lts-buster-slim' } }
            steps {
                sh 'npm install'
                // sh 'npm test' // (Aqui é onde os testes rodariam)
            }
        }
        
        stage('Build Image') {
            steps {
                echo "Construindo a imagem: ${env.DOCKERHUB_USER}/${env.APP_NAME}"
                
                // Constrói a imagem usando o Dockerfile
                sh "docker build -t ${env.DOCKERHUB_USER}/${env.APP_NAME}:latest ."
                
                // Cria uma tag única com o número do build (ex: :5)
                sh "docker tag ${env.DOCKERHUB_USER}/${env.APP_NAME}:latest ${env.DOCKERHUB_USER}/${env.APP_NAME}:${env.BUILD_NUMBER}"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo "Publicando a imagem no Docker Hub..."
                
                // Usa o "cofre" (ID: DOCKERHUB_CREDS) para fazer login
                withCredentials([usernamePassword(credentialsId: 'DOCKERHUB_CREDS', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                    
                    // Envia as duas tags para o Docker Hub
                    sh "docker push ${env.DOCKERHUB_USER}/${env.APP_NAME}:latest"
                    sh "docker push ${env.DOCKERHUB_USER}/${env.APP_NAME}:${env.BUILD_NUMBER}"
                }
            }
        }

        // --- STAGE DE DEPLOY CORRIGIDO ---
        
        stage('Deploy to Production') {
            steps {
                echo "A fazer deploy da versão ${env.BUILD_NUMBER} para a VM 2 (${env.VM_PROD_IP})"
                
                // 1. Carrega AMBAS as credenciais: a chave SSH E o token do Docker
                withCredentials([
                    sshUserPrivateKey(credentialsId: 'VM_PROD_SSH_KEY', keyFileVariable: 'SSH_KEY_FILE'),
                    string(credentialsId: 'DOCKERHUB_TOKEN', variable: 'DOCKER_TOKEN_VAR')
                ]) {
                    
                    // 2. Agora o script SSH tem acesso a $SSH_KEY_FILE e $DOCKER_TOKEN_VAR
                    //    O erro 'Bad substitution' deve desaparecer.
                    sh '''
                    ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE ${env.VM_PROD_USER}@${env.VM_PROD_IP} \'
                        echo "--- (VM 2) Ligado via SSH. A fazer o deploy..." && \
                        
                        echo "--- (VM 2) A fazer login no Docker Hub..." && \
                        echo $DOCKER_TOKEN_VAR | docker login -u ${env.DOCKERHUB_USER} --password-stdin && \

                        echo "--- (VM 2) A parar o container antigo (se existir)..." && \
                        docker stop ${env.APP_NAME} || true && \
                        docker rm ${env.APP_NAME} || true && \

                        echo "--- (VM 2) A puxar a nova imagem (build ${env.BUILD_NUMBER})..." && \
                        docker pull ${env.DOCKERHUB_USER}/${env.APP_NAME}:${env.BUILD_NUMBER} && \

                        echo "--- (VM 2) A iniciar o novo container..." && \
                        docker run -d --name ${env.APP_NAME} -p 3000:3000 ${env.DOCKERHUB_USER}/${env.APP_NAME}:${env.BUILD_NUMBER} && \
                        
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
        // Limpeza: Faz logout do Docker Hub no *agente* Jenkins
        always {
            sh 'docker logout'
        }
    }
}
