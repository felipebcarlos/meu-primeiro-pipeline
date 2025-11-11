# Estágio 1: Build
# Usamos uma imagem 'node' completa para instalar as dependências
FROM node:lts-buster-slim AS build
WORKDIR /app
COPY package*.json ./
RUN npm install

# Estágio 2: Produção
# Usamos uma imagem 'slim' (leve) para a imagem final
FROM node:lts-buster-slim
WORKDIR /app
COPY --from=build /app/node_modules ./node_modules
COPY index.js .
EXPOSE 3000
CMD ["node", "index.js"]
