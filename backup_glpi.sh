#!/bin/bash
  
########################################################################################
#                                                                                      #
# Nome: backup_glpi.sh                                                                 #
#                                                                                      #
# Autor: Rafael Ferreira (rafa0184@hotmail.com)                                        #
# Data: 14/11/2022                                                                     #
#                                                                                      #
# Descrição: Script fará um dump da base de dados GLPI e backup do                     #
#            do diretorio /home/www/html/glpi. Após gerar os arquivos                  #
#            eles são compactados e enviados para um bucket S3                         #
#                                                                                      #
# Uso: ./backup_glpi.sh                                                                #
# Agendamento: 0 16 * * * root  /home/ubuntu/bkp/backup_glpi.sh >/dev/null 2>&1        #
#                                                                                      #
########################################################################################

###Declaração de Variaveis
DATE=$(date +%Y%m%d)

DBUSER="root"
DBPASS="SenhaSuperSecretaESegura"
DATABASE="glpi"

DESTINATION="/home/ubuntu/bkp/glpi/"
GLPIPATH="/var/www/html/glpi/"

FILENAMEDB="$DATE-GLPIDB.sql"
FILENAMEFS="$DATE-GLPIFS.gz"

AWSBUCKET="s3://backup-glpi/glpi/"

LOG="/home/ubuntu/bkp/backup.log"

###Salva Saidas e erros no arquivo de log
exec 1>> $LOG
exec 2>&1

####Se o diretório /home/.../Backup não existir, cria
if [ ! -d $DESTINATION ]
then
  echo "Criando diretório $DESTINATION..."
  mkdir -p $DESTINATION
fi

echo "$(date) - Starting MYSQL DUMP $DATABASE -> $DESTINATION $FILENAMEDB" >> $LOG
mysqldump -u"$DBUSER" -p"$DBPASS"  "$DATABASE" > "$DESTINATION$FILENAMEDB"

echo "$(date) - Starting Backup GLPI FileSystem $GLPIPATH -> $DESTINATION $FILENAMEFS" >> $LOG
tar -czpf "$DESTINATION$FILENAMEFS" "$GLPIPATH" >> $LOG

echo "$(date) - Copy $DATABASE -> $AWSBUCKET" >> $LOG
###Copiar backup do banco de dados para S3 AWS (Somente o gerado no dia)
aws s3 cp "$DESTINATION$FILENAMEDB" "$AWSBUCKET" >> $LOG

###Copiar file system para AWS (Somente o gerado no dia)
echo "$(date) - Copy $FILENAMEFS -> $AWSBUCKET" >> $LOG
aws s3 cp "$DESTINATION$FILENAMEFS" "$AWSBUCKET" >> $LOG

###Apagar arquivos antigos
echo "$(date) - Purge old files" >> $LOG
find "$DESTINATION" -mindepth 1 -mtime +2 -delete >> $LOG
