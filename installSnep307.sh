#!/usr/bin/env bash

# Função para exibir mensagem com atraso
show_message() {
    echo -e "$1"
    sleep 3
}

# Mensagem inicial
show_message "${green}Iniciando instalação do SNEP 3.07...${nc}"

# Adiciona PATH ao .bashrc
show_message "${green}Adicionando PATH ao .bashrc...${nc}"
cat << 'EOF' | tee -a /root/.bashrc > /dev/null
export PATH="/usr/local/sbin/:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}"
EOF
source ~/.bashrc
show_message "OK"

# Adiciona repositório Sury
show_message "${green}Adicionando repositório Sury...${nc}"
apt update > /dev/null
apt install -y software-properties-common apt-transport-https curl gnupg1 gnupg2 > /dev/null
curl -sSL https://packages.sury.org/php/README.txt | bash -x > /dev/null
apt update && apt upgrade -y > /dev/null
show_message "OK"

# Instala pré-requisitos
show_message "${green}Instalando pré-requisitos...${nc}"
apt install -y apt-transport-https apache2 mariadb-server htop unzip mc ncdu xmlstarlet git unixodbc unixodbc-dev odbcinst1debian2 libncurses5-dev g++ build-essential lshw libjansson-dev libssl-dev sox sqlite3 libsqlite3-dev libxml2-dev uuid-dev libcurl4-openssl-dev libvorbis-dev libmariadb-dev-compat dialog python3 locate rsyslog wget odbc-mariadb libusb-0.1-4 > /dev/null
show_message "OK"

# Instala PHP 5.6
show_message "${green}Instalando PHP 5.6...${nc}"
apt install -y php5.6 php5.6-fpm php5.6-cgi php5.6-mysql php5.6-gd php5.6-curl php5.6-opcache php5.6-xml libgd-tools php-pear > /dev/null
update-alternatives --config php #selecione a versão do PHP 5.6
show_message "OK"

# Configurações PHP 5.6
php_ini_files=("/etc/php/5.6/cgi/php.ini" "/etc/php/5.6/cli/php.ini" "/etc/php/5.6/fpm/php.ini")
for php_ini_file in "${php_ini_files[@]}"; do
    show_message "${green}Configurando ${php_ini_file}...${nc}"
    sed -i '/^register_argc_argv/c\register_argc_argv = On' "${php_ini_file}"
    sed -i '/^date.timezone/c\date.timezone = America/Sao_Paulo' "${php_ini_file}"
    sed -i '/^output_buffering/c\output_buffering = 4096' "${php_ini_file}"
    sed -i '/^memory_limit/c\memory_limit = 128M' "${php_ini_file}"
    sed -i '/^upload_max_filesize/c\upload_max_filesize = 128M' "${php_ini_file}"
    sed -i '/^max_execution_time/c\max_execution_time = 300' "${php_ini_file}"
    show_message "OK"
done

# Ativa módulos do Apache
show_message "${green}Ativando módulos do Apache...${nc}"
a2enmod proxy_fcgi setenvif && a2enconf php5.6-fpm > /dev/null
systemctl reload apache2 && systemctl restart apache2 > /dev/null
systemctl status apache2
show_message "OK"

# Instala Asterisk 13.x
show_message "${green}Instalando Asterisk 13.x...${nc}"
cd /usr/src && wget http://downloads.asterisk.org/pub/telephony/asterisk/old-releases/asterisk-13.38.3.tar.gz && tar -zxf asterisk-13.38.3.tar.gz
cd asterisk-13.38.3/ && ./configure && make menuselect && make -j4 && make -j16 install
cp contrib/init.d/rc.debian.asterisk /etc/init.d/asterisk && chmod +x /etc/init.d/asterisk
update-rc.d asterisk defaults
systemctl daemon-reload && systemctl restart asterisk && systemctl status asterisk
show_message "OK"

# Configura segurança do MySQL
show_message "${green}Configurando segurança do MySQL...${nc}"
mysql_secure_installation <<EOF
Y
99184748
Y
Y
Y
Y
EOF
show_message "OK"

# Ajusta configuração do MariaDB
show_message "${green}Ajustando configuração do MariaDB...${nc}"
sed -i '/^sql-mode/c\sql-mode=NO_ENGINE_SUBSTITUTION' /etc/mysql/mariadb.conf.d/50-server.cnf
systemctl restart mariadb && systemctl status mariadb
show_message "OK"

# Instala SNEP 3.07
show_message "${green}Instalando SNEP 3.07...${nc}"
cd /var/www/html && wget -c https://bitbucket.org/snepdev/snep-3/get/master.tar.bz2 -O snep.tar.bz2
wget -c https://bitbucket.org/snepdev/billing/get/master.tar.gz -O bill.tar.gz
wget -c https://bitbucket.org/snepdev/ivr/get/master.tar.gz -O ivr.tar.gz
tar jxf snep.tar.bz2 && tar xf bill.tar.gz && tar xf ivr.tar.gz
mv snepdev-snep-3-1ca9454a467d snep
cd snepdev-billing-104bff715f7c && tar cf - . | tar xvf - -C ../snep/modules/billing/ && cd ..
cd snepdev-ivr-5a6a4e67be68 && tar cf - . | tar xvf - -C ../snep/modules/ivr/ && cd ..
mkdir -p /var/log/snep && cd /var/log/snep && touch ui.log && touch agi.log
ln -s /var/log/asterisk/full full && chown -R www-data:www-data *
cd /var/www/html/snep/ && ln -s /var/log/snep logs
cd /var/lib/asterisk/agi-bin/ && ln -s /var/www/html/snep/agi/ snep
cd /etc/apache2/sites-enabled/ && ln -s /var/www/html/snep/install/snep.apache2 001-snep cd /var/spool/asterisk/
rm -rf monitor && ln -sf /var/www/html/snep/arquivos monitor
cd /var/www/html/snep/install/database
mysql -u root -p < database.sql
mysql -u root -p snep < schema.sql
mysql -u root -p snep < system_data.sql
mysql -u root -p snep < core-cnl.sql
mysql -u root -p snep < /var/www/html/snep/modules/billing/install/schema.sql
cd /var/www/html/snep/install/sounds && mkdir -p /var/lib/asterisk/sounds/en
tar -xzf asterisk-core-sounds-en-wav-current.tar.gz -C /var/lib/asterisk/sounds/en
tar -xzf asterisk-extra-sounds-en-wav-current.tar.gz -C /var/lib/asterisk/sounds/en && mkdir /var/lib/asterisk/sounds/es
tar -xzf asterisk-core-sounds-es-wav-current.tar.gz -C /var/lib/asterisk/sounds/es && mkdir /var/lib/asterisk/sounds/pt_BR
tar -xzf asterisk-core-sounds-pt_BR-wav.tgz -C /var/lib/asterisk/sounds/pt_BR && cd /var/lib/asterisk/sounds
mkdir -p es/tmp es/backup en/tmp en/backup pt_BR/tmp pt_BR/backup && chown -R www-data:www-data *
mkdir -p /var/www/html/snep/sounds && cd /var/www/html/snep/sounds/
ln -sf /var/lib/asterisk/moh/ moh && ln -sf /var/lib/asterisk/sounds/pt_BR/ pt_BR
cd /var/lib/asterisk/moh && mkdir tmp backup
chown -R www-data:www-data /var/lib/asterisk/moh && rm -f *-asterisk-moh-opsound-wav
mv -bf /var/www/html/snep/install/etc/asterisk /etc/ && cp -y /var/www/html/snep/install/etc/odbc* /etc/
chown -R www-data:www-data /etc/asterisk/snep
cd /var/www/html
find . -type f -exec chmod 640 {} \; -exec chown www-data:www-data {} \;
find . -type d -exec chmod 755 {} \; -exec chown www-data:www-data {} \;
chmod +x /var/www/html/snep/agi/*
show_message "OK"

# Instalação ODBC
show_message "${green}Instalando ODBC...${nc}"
cd /usr/src && wget https://downloads.mariadb.com/Connectors/odbc/connector-odbc-2.0.19/mariadb-connector-odbc-2.0.19-ga-debian-x86_64.tar.gz
tar -xzf mariadb-connector-odbc-2.0.19-ga-debian-x86_64.tar.gz
cp lib/libmaodbc.so /usr/lib/x86_64-linux-gnu/odbc/
cat << EOF | tee /etc/odbc.ini > /dev/null
[MySQL-snep]
Description = MySQL ODBC Driver
Driver = /usr/lib/x86_64-linux-gnu/odbc/libmaodbc.so
Socket = /var/run/mysqld/mysqld.sock
Server = localhost
User = snep
Password = sneppass
Database = snep
Option = 3
EOF
cat << EOF | tee /etc/odbcinst.ini > /dev/null
[MySQL]
Description = MySQL ODBC MyODBC Driver
Driver = /usr/lib/x86_64-linux-gnu/odbc/libmaodbc.so
FileUsage = 1

[Text]
Description = ODBC for Text Files
Driver = /usr/lib/x86_64-linux-gnu/odbc/libodbctxtS.so
Setup = /usr/lib/x86_64-linux-gnu/odbc/libodbctxtS.so
FileUsage = 1
CPTimeout =
CPReuse =
EOF
show_message "OK"

# Ajustes Snep
show_message "${green}Realizando ajustes no SNEP...${nc}"
sed -i '/^itc_required/c\itc_required = "false"' /var/www/html/snep/includes/setup.conf
sed -i '/^ServerTokens/c\ServerTokens Prod' /etc/apache2/apache2.conf
sed -i '/^ServerSignature/c\ServerSignature Off' /etc/apache2/apache2.conf
show_message "OK"

# Limpa memória do servidor
show_message "${green}Configurando limpeza de memória do servidor...${nc}"
(crontab -l ; echo "30 * * * * sync;echo 1 > /proc/sys/vm/drop_caches;sync") | crontab -
show_message "OK"

# Configura user agent do SIP
show_message "${green}Configurando user agent do SIP...${nc}"
sed -i '/^\[general\]/a\useragent=Asterisk MKPBX - MKTecnologia' /etc/asterisk/sip.conf
show_message "OK"

# Configura Snep Web
show_message "${green}Configurando Snep Web...${nc}"
mv /var/www/html/index.html /root/index.html.OLD
cat << EOF | tee /var/www/html/index.html > /dev/null
<html>
  <body>
    <meta http-equiv="Refresh" content="0; url='snep'">
  </body>
</html>
EOF
show_message "OK"

# Instala EBS Khomp
show_message "${green}Instalando EBS Khomp...${nc}"
apt install linux-headers-$(uname -r) -y && cd ~
chmod 700 PKGSnep3/channel_5.1_002_x86-64.sh && bash PKGSnep3/channel_5.1_002_x86-64.sh
rasterisk // module load chan_khomp.so
show_message "OK"

# Configura URA
show_message "${green}Configurando URA...${nc}"
cat << 'EOF' | tee -a /etc/asterisk/custom/eof.conf > /dev/null
#include /etc/asterisk/custom/uraMK.conf
EOF
show_message "OK"

# Instala Fail2ban
show_message "${green}Instalando Fail2ban...${nc}"
cd ~
wget https://github.com/fail2ban/fail2ban/archive/0.11.1.zip
unzip 0.11.1.zip
cd fail2ban-0.11.1
python setup.py install
cp files/debian-initd /etc/init.d/fail2ban
update-rc.d fail2ban defaults
service fail2ban start
cat << EOF | tee -a /etc/fail2ban/jail.local > /dev/null
[DEFAULT]
bantime = 72h
banaction = iptables-allports
bantime.increment = true
ignoreip = 127.0.0.1

[sshd]
enabled = true
maxretry = 4

[asterisk]
enabled = true
maxretry = 4
EOF
show_message "OK"

# Finalização
show_message "${green}Instalação concluída. Acesse o SNEP em: http://seu_ip/ ${nc}"

