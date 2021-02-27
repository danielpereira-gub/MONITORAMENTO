#!bin/bash


##MACROS###

URL_ZABBIX=https://repo.zabbix.com/zabbix/5.3/rhel/8/x86_64/zabbix-release-5.3-1.el8.noarch.rpm
URL_GRAFANA=https://dl.grafana.com/oss/release/grafana-7.4.3-1.x86_64.rpm

###INICIAL###
TIME=1
clear
yum install epel-release -y
yum install figlet -y
clear
echo " "
echo "SEJA BEM VINDO AO PROGRAMA DE INSTALACAO CRIADO POR DANIEL SILVA"
echo " "			

###MENSAGEM A SER EXIBIDA###
figlet -c GUBIT

###MENU###
echo "ESCOLHA UMA DAS OPÇÕES ABAIXO:
		
		1- INSTALAR BANCO DE DADOS PARA O ZABBIX
		2- INSTALAR ZABBIX WEB E ZABBIX SERVER
		3- INSTALAR O GRAFANA
		4- INSTALAR ZABBIX PROXY
		5- INSTALAR ZABBIX AGENT
		0- SAIR DO PROGRAMA"
echo " "
echo -n "OPÇÃO ESCOLHIDA: "
read opcao
case $opcao in

####OPÇÕES###		
		
		1)
      ###VARIAVEIS###
			MYSQL="mysql -uroot"
            
			#MENSAGEM A SER EXIBITA
			figlet -c GUBIT
			echo INICIANDO A INSTALAÇÃO...
			sleep 15

			###UTILITARIOS###
			yum install net-snmp net-snmp-utils net-tools nano sendmail snmp snmp-mibs-downloader ftp zip -y
			systemctl start snmpd
			systemctl enable snmpd

			###DESABILITANDO O FIREWALL###
			setenforce 0
			systemctl stop firewalld
			systemctl disable firewalld
			sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
			sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

			###BANCO DE DADOS###

			#BAIXANDO O PACOTE
			rpm -ivh https://repo.mysql.com/mysql80-community-release-el8.rpm

			#INSTALANDO
			yum install mysql-server -y
			systemctl start mysqld

			#CRIANDDO BANCO DE DADOS, USUARIO E TROCANDO A SENHA DE ROOT
			${MYSQL} -e "CREATE DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin";
			${MYSQL} -e "create user 'zabbix'@'$dbhost' identified by 'uNNXKrLMHKRo'";
			${MYSQL} -e "grant all on zabbix.* to 'zabbix'@'%'";
			${MYSQL} -e "flush privileges";
			${MYSQL} -e "set password for 'root'@'localhost' = 'qkoMVoFjUwqMGbqR'";

			### ABRINDO PORTA PARA ACESSO REMOTO ###
			iptables -A INPUT -i eht0 -p tcp --destination-port 3306 -j ACCEPT

			systemctl restart mysqld
			systemctl start mysqld
			systemctl enable mysqld
			
			###SCRIPTS DE BACKUP###
			mkdir backup_zabbix
			cd backup_zabbix
			wget https://raw.githubusercontent.com/danielpereira-gub/ZABBIX_GRAFANA/main/INSTALADORES/BACKUPS_SCRIPTS/backup-bd-ftp.sh
			wget https://raw.githubusercontent.com/danielpereira-gub/ZABBIX_GRAFANA/main/INSTALADORES/BACKUPS_SCRIPTS/backup-bd-local.sh

			clear

			echo================================================
			echo "SENHA USUARIO ROOT MYSQL = qkoMVoFjUwqMGbqR"
			echo "SENHA USUARIO ZABBIX MYSQL = uNNXKrLMHKRo"
			echo================================================
			;;

		2)
			###UTILITARIOS###
			yum install net-snmp net-snmp-utils net-tools nano sendmail snmp snmp-mibs-downloader ftp zip -y
			systemctl start snmpd
			systemctl enable snmpd

			###DESABILITANDO O FIREWALL###
			setenforce 0
			systemctl stop firewalld
			systemctl disable firewalld
			sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
			sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
            
            ###BANCO DE DADOS###

			#BAIXANDO PACOTE#
			rpm -ivh https://repo.mysql.com/mysql80-community-release-el8.rpm

			#INSTALANDO#
			yum install mysql-server -y
			systemctl start mysqld

			###ZABBIX FRONT END E ZABBIX SERVER###

			#BAIXANDO PACOTE#
			rpm -Uvh $URL_ZABBIX

			#INSTALANDO ZABBIX WEB#
			dnf clean all
			dnf install zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-agent -y
            
            echo "DIGITE O IP DO BANCO DE DADOS"

			read dbip

			#IMPORTANDO AS TABELAS#
				zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -h $dbip -uzabbix -p"uNNXKrLMHKRo" zabbix

			#CONFIGURANDO ZABBIX & TUNNING#
			sed -i "s/# DBPassword=/DBPassword=uNNXKrLMHKRo/g" /etc/zabbix/zabbix_server.conf
			sed -i "s/# DBHost=localhost/DBHost=$dbip/g" /etc/zabbix/zabbix_server.conf
			sed -i "s/# StartPingers=1/StartPingers=10/g" /etc/zabbix/zabbix_server.conf
			sed -i "s/# CacheSize=8M/CacheSize=128M/g" /etc/zabbix/zabbix_server.conf
			sed -i "s/# HistoryCacheSize=16M/HistoryCacheSize=128M/g" /etc/zabbix/zabbix_server.conf
			sed -i "s/# HistoryIndexCacheSize=4M/HistoryIndexCacheSize=32M/g" /etc/zabbix/zabbix_server.conf
			sed -i "s/# TrendCacheSize=4M/TrendCacheSize=32M/g" /etc/zabbix/zabbix_server.conf
			sed -i "s/# ValueCacheSize=8M/ValueCacheSize=64M/g" /etc/zabbix/zabbix_server.conf
			sed -i "s/# StartPollers=5/StartPollers=20/g" /etc/zabbix/zabbix_server.conf
			sed -i "s/# StartPollersUnreachable=1/StartPollersUnreachable=10/g" /etc/zabbix/zabbix_server.conf
			sed -i "s/# StartDiscoverers=1/StartDiscoverers=10/g" /etc/zabbix/zabbix_server.conf


			#ALTERANDO TIMEZONE#
			echo  "php_value[date.timezone] = America/Sao_Paulo" >> /etc/php-fpm.d/zabbix.conf

			###DEFININDO O ZABBIX PARA PAGINA PADRAO###
			cp -r /usr/share/zabbix/* /var/www/html/
			rm -r /etc/httpd/conf.d/zabbix.conf
			cd /etc/httpd/conf.d/
			wget https://raw.githubusercontent.com/danielpereira-gub/ZABBIX_GRAFANA/main/INSTALADORES/PHP_FILE/zabbix.conf

			###ESTARTANDO OS SERVIÇOS###
			systemctl stop mysqld
			systemctl disable mysqld
			systemctl restart httpd php-fpm zabbix-server 
			systemctl start httpd php-fpm zabbix-server 
			systemctl enable httpd php-fpm zabbix-server 
			;;
		3) 	
			clear

			###DESABILITANDO O FIREWALL###
			setenforce 0
			systemctl stop firewalld
			systemctl disable firewalld
			sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
			sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

			###BAIXANDO E INSTALANDO###
			yum install -y adduser libfontconfig1
			wget $URL_GRAFANA
			um install grafana-7.4.3-1.x86_64.rpm -y

			###HABILITANDO####
			systemctl start grafana-server
			systemctl enable grafana-server

			###PLUGINS###
			grafana-cli plugins install alexanderzobnin-zabbix-app
			grafana-cli plugins install grafana-piechart-panel
			grafana-cli plugins install grafana-clock-panel
			
			###BACKUP###
			mkdir backup_grafana
			cd backup_grafana 
			wget https://raw.githubusercontent.com/danielpereira-gub/ZABBIX_GRAFANA/main/INSTALADORES/BACKUPS_SCRIPTS/backup-grafana-ftp.sh

			####RESTARTANDO####
			systemctl restart grafana-server
			;;

		4)
			###VARIAVEIS###
			LOG="zabbixproxy.log"

			###DESABILITANDO O FIREWALL###
			setenforce 0
			systemctl stop firewalld
			systemctl disable firewalld
			sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
			sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
			clear

			###QUESTIONANDO PAR AO USUARIO AS INFORMAÇÕES###
			echo "DIGITE O IP DO ZABBIX-SERVER:"

			read zbxip

			echo "DIGITE UM NOME PARA O ZABBIX PROXY (Hostname, devera ser utilizado na interface web para cadastramento):"

			read zbxname

			clear

			###ZABBIX PROXY###

			#BAIXANDO PACOTE
			rpm -ivh $URL_ZABBIX

			#INSTALANDO
			yum install zabbix-proxy-sqlite3 zabbix-agent -y

			###ENVIANDO PARA O ARQUIVO DE LOG###
			echo "IP DO ZABBIX SERVER: $zbxip" >> $LOG
			echo "NOME DO ZABBIX PROXY: $zbxname" >> $LOG

			sleep 5

			###BANCO DE DADOS###

			#INSTALANDO
			dfn install sqlite -y

			#CRIANDO DIRETORIO
			mkdir /var/lib/sqlite/

			#DESCOMPACTANDO
			cd /usr/share/doc/zabbix-proxy-sqlite/
			gzip -d schema.sql.gz

			#IMPORTANDO AS TABELAS
			sqlite3 /var/lib/sqlite/zabbix.db < schema.sql 

			#DANDO PERMISSAO
			chown -R zabbix:zabbix /var/lib/sqlite/

			###CONFIGURANDO O ARQUIVO ZABBIX PROXY###
			sed -i "s/# ProxyMode=0/ProxyMode=0/g" /etc/zabbix/zabbix_proxy.conf
			sed -i "s/Server=127.0.0.1/Server=$zbxip/g" /etc/zabbix/zabbix_proxy.conf
			sed -i "s/Hostname=Zabbix proxy/Hostname=$zbxname/g" /etc/zabbix/zabbix_proxy.conf
			sed -i "s/# ConfigFrequency=3600/ConfigFrequency=60/g" /etc/zabbix/zabbix_proxy.conf
			sed -i "s/# DataSenderFrequency=1/DataSenderFrequency=10/g" /etc/zabbix/zabbix_proxy.conf
			sed -i "s/# ProxyOfflineBuffer=1/ProxyOfflineBuffer=24/g" /etc/zabbix/zabbix_proxy.conf

			###ESTARTANDO OS SERVIÇOS###
			clear
			systemctl restart zabbix-proxy
			systemctl start zabbix-proxy
			systemctl enable zabbix-proxy
			;;
			
		5) 	###ZABBIX AGENT###
			rpm -i $URL_ZABBIX

			#INSTALANDO
			yum install zabbix-agent -y

			###PERGUNTA NA TELA###
			echo "DIGITE O IP DO SEU ZABBIX-SERVER"
			read ip

			###CONFIGURANDO O ZABBIX AGENT###
			sed -i "s/Server=127.0.0.1/Server=$ip/g" /etc/zabbix/zabbix_agentd.conf

			###ESTARTANDO SERVIÇO####
			systemctl restart zabbix-agent
			systemctl start zabbix-agent
			systemctl enable zabbix-agent
			;;
		0) 
			echo SAINDO DO PROGRAMA...
			sleep $TIME
			exit 0
			;;
			
		*)
			echo OPÇAO INVALIDA, TENTE NOVAMENTE.
			;;
esac
		
