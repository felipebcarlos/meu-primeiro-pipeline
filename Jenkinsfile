pipeline {
    agent {
        // Isto é o que vai testar o seu setup da Fase 1!
        // O "Docker Pipeline" plugin vai usar o socket.
        docker { image 'node:lts-buster-slim' }
    }

    stages {
        stage('Rodando dentro do Contêiner') {
            steps {
                sh 'echo "--- Se você vê isto, o DooD funcionou! ---"'
                sh 'echo "--- Estou rodando dentro de um contêiner Node.js ---"'
                sh 'node --version'
            }
        }
    }
}
