#!/bin/bash

## yum install ftp zip -y
## dar permisao para o script chmod +x caminho do script
## colocar no crontab da seguinte forma:     0 23 * * *  root bash caminhodoscript
## restaurando cp grafana.data.db /var/lib/grafana/grafana.db
## dar permisao chown grafana:grafana grafana.db

DATAHORA="date +%d-%m-%Y-%H-%M"

#DADOS DO FTP
FTPHOST="ip_ftp"
FTPUSER="usuario_ftp"
FTPPASS="senha_ftp"
FOLDER="caminho da pasta no ftp"

#DIRETORIO
LOCALDIR="/opt/grafana"
COMPRESSEDFILENAME="grafana-$DATAHORA"
mkdir $LOCALDIR
cd $LOCALDIR

#REALIZANDO O BACKUP
zip "$LOCALDIR/$COMPRESSEDFILENAME.zip" /var/lib/grafana/grafana.db

#ENVIANDO PARA O FTP
echo "
 verbose
 open $FTPHOST
 user $FTPUSER $FTPPASS
cd $FOLDER
 bin
 put $(ls -Art | tail -n 1)
 bye
" | ftp -n
rm $LOCALDIR -rf
