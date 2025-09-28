#!/bin/bash

#=====================================================
# Autor: Maksyflay Souza
# Script Avançado: Docker + Docker Compose Standalone
# Debian 12
#=====================================================

# Verifica se está rodando como root
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
    jq \
    git \
    unzip

#------------------------------
# Instalando Docker Engine
#------------------------------
echo "🗝 Adicionando chave GPG do Docker..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "📦 Adicionando repositório Docker..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "🔄 Atualizando repositórios..."
apt update -y

echo "🐳 Instalando Docker Engine..."
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin

echo "✅ Habilitando e iniciando Docker..."
systemctl enable docker
systemctl start docker

#------------------------------
# Instalando Docker Compose Standalone
#------------------------------
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')
echo "⬇️ Instalando Docker Compose versão $DOCKER_COMPOSE_VERSION..."
curl -SL "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-linux-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

# Link simbólico para compatibilidade com 'docker compose'
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

#------------------------------
# Finalizando
#------------------------------
echo "🧪 Testando instalações..."
docker --version
docker-compose --version
docker compose version

echo "👤 Adicionando usuário atual ao grupo docker (necessário logout/login)..."
usermod -aG docker $SUDO_USER

echo "🎉 Instalação concluída com sucesso!"
echo "Para usar Docker sem sudo, faça logout e login novamente."
