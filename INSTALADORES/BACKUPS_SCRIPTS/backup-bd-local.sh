#!/bin/sh
#BACKUP DO SCHEMA E BANCO DE DADOS ZABBIX 

DBNAME=NOME_DO_BANCO_ZABBIX
DBUSER=USUARIO_DO_BANCO
DBPASS=SENHA_DO_BANCO
BK_DEST=/root/backup/

###REALIZANDO BACKUP SOMENTE DO SCHEMA DO BANCO###
sudo mysqldump --no-data --single-transaction -u$DBUSER -p"$DBPASS" "$DBNAME" | /bin/gzip > "$BK_DEST/$DBNAME-`date +%Y-%m-%d`-schema.sql.gz"

##REALIZANDO BACKUP DO BANCO ZABBIX IGNORANDO AS MAIORES TABELAS###
sudo mysqldump -u"$DBUSER"  -p"$DBPASS" "$DBNAME" --single-transaction --skip-lock-tables --no-create-info --no-create-db /bin/gzip > "$BK_DEST/$DBNAME-`date +%Y-%m-%d`-config.sql.gz"
