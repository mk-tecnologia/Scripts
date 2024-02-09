#!/usr/bin/env bash
# Copyright (c) 2007-2024 MKTecnologia
# Author: Marcos A. Campos (MKTecnologia)
# License: MIT
# initDeb.sh faz as configurações iniciais do GNU/DEBIAN

#USUARIO ATUAL
usuario=$USER

#DEFINE ESPERAS
esperar="sleep 3"
reiniciar="sleep 5"

# DEFINE CORES ANSI
red='\033[0;31m'
green='\033[0;32m'
purple='\033[0;35m'
nc='\033[0m' # Sem cor

# VERIFICA SE O SCRIPT É EXECUTADO COM PERMISSÕES DE SUPERUSUÁRIO
if [[ $EUID -ne 0 ]]; then
    echo "${green}ESTE SCRIPT DEVE SER EXECUTADO COMO ROOT${nc}"
    exit 1
fi

# MENSAGEM INICIAL
clear
echo -ne "${purple}INICIANDO CONFIGURAÇÕES DO SISTEMA...${nc}"
echo ""
$esperar

# INSTALAÇÃO DE PACOTES
echo -ne "${purple}INSTALANDO PACOTES...${nc}"
apt-get update > /dev/null
apt-get install -y vim neofetch qemu-guest-agent > /dev/null
echo -e "${green}OK${nc}"
$esperar

# DESATIVA SSH PERMITROOTLOGIN
echo -ne "${purple}DESATIVANDO PERMITROOTLOGIN NO SSH...${nc}"
sed -i 's/^PermitRootLogin .*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
service ssh restart > /dev/null
echo -e "${green}OK${nc}"
$esperar

# COPIAR CHAVE SSH
echo -ne "${purple}COPIANDO CHAVE SSH..${nc}"
cat << EOF | tee /${usuario}/.ssh/authorized_keys > /dev/null
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDW2K3YdN9/O18AVtiyOt5b5rBHUDxu3iuUghV/I2vli3ZxNL0HxmlDjMvb4EsP4Y5WD9J16rDCWGA7QGEfj5ZhKuJRkyZVKJDCr8E99NhLTd8CvxYDBQY88kKyy2e47asSpAZGZwW74OgxbkYC6yeG1nz4Gxi2sTkfa27yXea3gewuT5ozvWtskjkyNc47WrMXJWQ6khMqe+doQQkZXUVrZZp3lp1lGRy8I5FYBAXmRntWTMF7RfLURh6bNA2PRc5mLLaePq8cwLHfz2ucnmHXK/EA4vFCAAchKs3OlEZZ/y72PPZAz/A7OP3jo+kgJFOe+qaTjHZCU1XsPMU3ezu3 Caverna@notecaverna.local
EOF
echo -e "${green}OK${nc}"

# AJUSTA NEOFETCH
echo -ne "${purple}CONFIGURANDO INFORMAÇÕES DO SISTEMA NO LOGIN...${nc}"
cat << 'EOF' | tee /etc/update-motd.d/10-uname > /dev/null
#!/bin/sh
echo ""
neofetch
EOF
chmod +x /etc/update-motd.d/10-uname
echo -e "${green}OK${nc}"
$esperar

# AJUSTA MOTD
echo -ne "${purple}LIMPANDO MOTD...${nc}"
echo "" > /etc/motd
echo -e "${green}OK${nc}"
$esperar

# AJUSTA ISSUE
echo -ne "${purple}ATUALIZANDO ARQUIVO ISSUE...${nc}"
cat << EOF | tee /etc/issue > /dev/null

 ███╗   ███╗██╗  ██╗████████╗███████╗ ██████╗███╗   ██╗ ██████╗ ██╗      ██████╗  ██████╗ ██╗ █████╗
 ████╗ ████║██║ ██╔╝╚══██╔══╝██╔════╝██╔════╝████╗  ██║██╔═══██╗██║     ██╔═══██╗██╔════╝ ██║██╔══██╗
 ██╔████╔██║█████╔╝    ██║   █████╗  ██║     ██╔██╗ ██║██║   ██║██║     ██║   ██║██║  ███╗██║███████║
 ██║╚██╔╝██║██╔═██╗    ██║   ██╔══╝  ██║     ██║╚██╗██║██║   ██║██║     ██║   ██║██║   ██║██║██╔══██║
 ██║ ╚═╝ ██║██║  ██╗   ██║   ███████╗╚██████╗██║ ╚████║╚██████╔╝███████╗╚██████╔╝╚██████╔╝██║██║  ██║
 ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝╚═╝  ╚═╝
 marcos@mktecnologia.net.br
 www.mktecnologia.net.br
 Use linux :)

 ## Based in => \\S
 ## Kernel => \\r on an \\m

 ## Hostname => \\n.\\o
 ## IPV4 ETHO => \\4{ens18}

 #################
 # MK TECNOLOGIA #
 #################

EOF
chattr +i /etc/issue > /dev/null
echo -e "${green}OK${nc}"
$esperar

# AJUSTA .BASHRC
echo -ne "${purple}CONFIGURANDO .BASHRC...${nc}"
cat << 'EOF' >> /${usuario}/.bashrc
# Adicionado pelo script de configuração
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
EOF
echo -e "${green}OK${nc}"
$esperar

# SOLICITAR NOME DE DOMÍNIO AO USUÁRIO
echo -ne "${purple}DIGITE O NOME DO DOMÍNIO${nc} ${green}(EXEMPLO: MINHAEMPRESA.INTRANET):${nc} "
read dominio

# AJUSTA NOME DE DOMÍNIO
echo -ne "${purple}CONFIGURANDO NOME DE DOMÍNIO PARA${nc} ${green}$dominio...${nc}"
echo "kernel.domainname = $dominio" >> /etc/sysctl.conf
sysctl -p > /dev/null
echo -e "${green}OK${nc}"
$esperar

# MENSAGEM DE CONCLUSÃO
echo -ne "${green}CONFIGURAÇÕES CONCLUÍDAS...${nc}"
echo "REINICIANDO"
$reiniciar
init 6
