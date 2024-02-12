#!/usr/bin/env bash
# Copyright (c) 2007-2024 MKTecnologia
# Author: Marcos A. Campos (MKTecnologia)
# License: MIT
# initDeb.sh faz as configurações iniciais do GNU/DEBIAN

#VARIAVEIS
usuario=$USER
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

# EXIBIR HOSTNAME E ENDEREÇO IP
PC=$(hostname)
IP=$(hostname -I | awk '{print $1}')

# VERIFICA SE É O DEBIAN
is_debian() {
    # OBTÉM A ID DA DISTRIBUIÇÃO
    deb_id=$(cat /etc/os-release | grep "^ID=" | cut -d '=' -f 2)
    $esperar
}

# VERIFICAR SE É O DEBIAN 12
is_debian_12() {
    # OBTÉM A VERSÃO DO SISTEMA ATUAL
    deb_version=$(cat /etc/os-release | grep VERSION_ID | cut -d '"' -f 2)
}

func_is_debian() {
      is_debian
      if [ "$deb_id" == "debian" ]; then
        local message="S.O. DETECTADO GNU/DEBIAN"
        func_message
        $esperar
        is_debian_12
        if [ "$deb_version" == "12" ]; then
          local message="S.O. GNU/DEBIAN VERSÃO 12"
          func_message
          $esperar
        else
          echo -ne "S.O. NÃO É GNU/DEBIAN 12.........................."
          echo -e "${red}RECOMENDAMOS ATUALIZAR O S.O.!${nc}"
          $esperar
        fi
      else
        echo -ne "${purple}S.O. DETECTADO NÃO É GNU/DEBIAN...........................................${NC}"
        echo -e "${red}SAINDO${nc}"
        $esperar
        exit 1
      fi
}

# EXIBIR MENSAGEM AO USUARIO
func_message() {
local func_message="${purple}$message${nc}"
local message_length=${#func_message}
local ok_position=$((80 - message_length))
local dots_count=$((ok_position - 5))
echo -ne "$func_message"
for ((i = 0; i < dots_count; i++)); do
    echo -n "."
done
echo -e "${green}[OK]${nc}"
}

# MENSAGEM INICIAL
clear
echo "##############################"
echo "## SCRIPT CONFIG GNU/DEBIAN ##"
echo "##############################"
echo ""
func_is_debian
echo -e "${green}## INICIANDO CONFIG DO GNU/DEBIAN ##${nc}"
echo ""
$esperar

# INSTALAÇÃO DE PACOTES
func_install_pkg() {
  local message="INSTALANDO PACOTES"
  apt-get update > /dev/null 2>&1
  apt-get install -y vim neofetch qemu-guest-agent > /dev/null 2>&1
  func_message
  $esperar
}

# AJUSTE MOUSE VIM
func_set_vim() {
local message="AJUSTANDO MOUSE NO VIM"
sed -i 's/^"\s*\(set mouse=a\)/\1/' /etc/vim/vimrc
func_message
$esperar
}

# DESATIVA SSH PERMITROOTLOGIN
func_disable_ssh() {
   local message="DESATIVANDO PERMITROOTLOGIN NO SSH"
  sed -i 's/^PermitRootLogin .*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
  service ssh restart > /dev/null
  func_message
  $esperar
}

func_add_ssh_key() {
  local chave_publica="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDW2K3YdN9/O18AVtiyOt5b5rBHUDxu3iuUghV/I2vli3ZxNL0HxmlDjMvb4EsP4Y5WD9J16rDCWGA7QGEfj5ZhKuJRkyZVKJDCr8E99NhLTd8CvxYDBQY88kKyy2e47asSpAZGZwW74OgxbkYC6yeG1nz4Gxi2sTkfa27yXea3gewuT5ozvWtskjkyNc47WrMXJWQ6khMqe+doQQkZXUVrZZp3lp1lGRy8I5FYBAXmRntWTMF7RfLURh6bNA2PRc5mLLaePq8cwLHfz2ucnmHXK/EA4vFCAAchKs3OlEZZ/y72PPZAz/A7OP3jo+kgJFOe+qaTjHZCU1XsPMU3ezu3 Caverna@notecaverna.local"
  local arquivo_chaves="/${usuario}/.ssh/authorized_keys"

  # VERIFICA SE A CHAVE PÚBLICA JÁ ESTÁ PRESENTE NO ARQUIVO
  if grep -qF "$chave_publica" "$arquivo_chaves"; then
    local message="CHAVE SSH JÁ CONFIGURADA"
    func_message
  else
    # ADICIONA A CHAVE PÚBLICA AO ARQUIVO
    local message="ADICIONANDO CHAVE SSH"
    echo "$chave_publica" >> "$arquivo_chaves"
    func_message
  fi
}

# AJUSTA NEOFETCH
func_set_neofetch() {
  local message="CONFIGURANDO INFORMAÇÕES DO SISTEMA NO LOGIN"
  cat << 'EOF' | tee /etc/update-motd.d/10-uname > /dev/null
#!/bin/sh
echo ""
neofetch
EOF
chmod +x /etc/update-motd.d/10-uname
func_message
$esperar
}

# AJUSTA MOTD
func_set_motd() {
  local message="LIMPANDO MOTD"
  echo "" > /etc/motd
  func_message
  $esperar
}

# AJUSTA ISSUE
func_set_issue() {
  local message="ATUALIZANDO ARQUIVO ISSUE"
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
func_message
$esperar
}

# AJUSTA .BASHRC
func_set_basrc() {
  local message="CONFIGURANDO .BASHRC"
  file="/${usuario}/.bashrc"
  sed -i 's/^# export LS_OPTIONS='\''--color=auto'\''$/export LS_OPTIONS='\''--color=auto'\''/' "$file"
  sed -i 's/^# eval "\$(dircolors)"$/eval "\$(dircolors)"/' "$file"
  sed -i 's/^# alias ls='\''ls \$LS_OPTIONS'\''$/alias ls='\''ls \$LS_OPTIONS'\''/' "$file"
  sed -i 's/^# alias ll='\''ls \$LS_OPTIONS -l'\''$/alias ll='\''ls \$LS_OPTIONS -l'\''/' "$file"
  sed -i 's/^# alias l='\''ls \$LS_OPTIONS -lA'\''$/alias l='\''ls \$LS_OPTIONS -lA'\''/' "$file"
  sed -i 's/^# \(alias rm='\''rm -i'\''\)/\1/' "$file"
  sed -i 's/^# \(alias cp='\''cp -i'\''\)/\1/' "$file"
  sed -i 's/^# \(alias mv='\''mv -i'\''\)/\1/' "$file"
func_message
$esperar
}

# SOLICITAR NOME DE DOMÍNIO AO USUÁRIO
func_get_domain() {
  echo -ne "${purple}DIGITE O NOME DO DOMÍNIO${nc} ${green}(EXEMPLO: MINHAEMPRESA.INTRANET):${nc} "
  read dominio
}

# AJUSTA NOME DE DOMÍNIO
func_set_domain() {
  local message="CONFIGURANDO NOME DE DOMÍNIO PARA: ${green}$dominio${nc}  "
  sed -i "/#kernel.domainname = example.com/akernel.domainname = $domainname" /etc/sysctl.conf
  sysctl -p > /dev/null
  func_message
  $esperar
}

# EXECUTA FUNÇÕES
func_install_pkg
func_set_vim
func_disable_ssh
func_add_ssh_key
func_set_neofetch
func_set_motd
func_set_issue
func_set_basrc
func_get_domain
func_set_domain

# MENSAGEM DE CONCLUSÃO
echo -e "${green}CONFIGURAÇÕES CONCLUÍDAS...${nc}"
echo -e "${purple}HOSTNAME PC: ${nc} ${green}${PC}.${dominio}${nc}"
echo -e "${purple}IP PC: ${nc} ${green}${IP}${nc}"
echo -e "${red}REINICIANDO${nc}"
$reiniciar
init 6
