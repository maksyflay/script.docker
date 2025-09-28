#!/bin/bash

#=====================================================
# Autor: Maksyflay Souza
# Script de Instalação: Docker + Docker Compose no Debian 12
#=====================================================

# Verificar se o script está sendo executado como root
if [[ $EUID -ne 0 ]]; then
   echo "❌ Este script precisa ser executado como root" 
   exit 1
fi

echo "🚀 Atualizando o sistema..."
apt update -y && apt upgrade -y

echo "🔧 Instalando dependências essenciais..."
apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    bash-completion \
    jq

echo "🗝 Adicionando a chave GPG oficial do Docker..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "📦 Adicionando o repositório do Docker..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "🔄 Atualizando os repositórios..."
apt update -y

echo "🐳 Instalando Docker Engine e Docker CLI..."
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "✅ Habilitando e iniciando o Docker..."
systemctl enable docker
systemctl start docker

echo "🧪 Testando a instalação do Docker..."
docker --version
docker compose version

echo "👤 Adicionando usuário atual ao grupo docker (necessário logout/login)..."
usermod -aG docker $SUDO_USER

echo "🎉 Instalação concluída com sucesso!"
echo "Para usar o Docker sem sudo, faça logout e login novamente."
