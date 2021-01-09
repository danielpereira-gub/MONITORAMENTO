#!/bin/sh

####yum install git gzip dos2unix
####chmod +x backup-bd-ftp.sh
#####dos2unix backup-bd-ftp.sh
#####./backup-bd-ftp.sh
#####colocar no crontab da seguinte forma:     0 23 * * *  root  ./caminhodoscript

#DADOS DO FTP
FTPHOST="IP_FTP"
FTPUSER="USER_FTP"
FTPPASS="SENHA_FTP"
FOLDER="PASTA_DO_FTP"

#ZABBIX
DBNAME=zabbix
DBUSER=zabbix
DBPASS=SENHA_DO_BANCO

#DIRETORIO LOCAL#
BK_DEST="/root/backup"

###REALIZANDO BACKUP SOMENTE DO SCHEMA DO BANCO###
sudo mysqldump --no-data --single-transaction -u$DBUSER -p"$DBPASS" "$DBNAME" > "$BK_DEST/$DBNAME-`date +%Y-%m-%d`-schema.sql"

##REALIZANDO BACKUP DO BANCO ZABBIX###
sudo mysqldump --add-drop-table -u"$DBUSER" -p"$DBPASS" -x -e -B "$DBNAME" > "$BK_DEST/$DBNAME-`date +%Y-%m-%d`-config.sql"

##ENTRANDO NO DIRETORIO##
cd $BK_DEST

#Enviando para o FTP
echo "
 verbose
 open $FTPHOST
 user $FTPUSER $FTPPASS
cd $FOLDER
 bin
 prompt
 mput *.sql
 bye
" | ftp -n
rm $LOCALDIR -rf
