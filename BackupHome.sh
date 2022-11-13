#!/bin/bash
########################################################################
#                                                                      #
# Nome: BackupHome.sh                                                  #
#                                                                      #
# Autor: Rafael Ferreira (rafa0184@hotmail.com)                        #
# Data: DD/MM/AAAA                                                     #
#                                                                      #
# Descrição: O script fara um backup compactado do diretóro home       #
#            do usuário que estive executando o script.                #
# Uso: ./BackupHome.sh                                                 #
########################################################################
DIRDEST=$HOME/Backup


####Se o diretório /home/.../Backup não existir, cria
if [ ! -d $DIRDEST ]
then
  echo "Criando diretório $DIRDEST..."
  mkdir -p $DIRDEST
fi

####Verificar se o arquivo existe e se é mais velho que 7 dias
DAYS7=$(find $DIRDEST -ctime -7 -name backup_home\*tgz)

if [ "$DAYS7" ]
then
    echo "Já foi gerado um backup no diretório $HOME nos útimos 7 dias."
    echo -n "Deseja continuar? (N/s): "
    read -n1 CONT
    echo ""
    if [ "$CONT" = N -o "$CONT" = n -o "$CONT" = "" ]
    then
        echo "Backup Abortado"
        exit 1
    elif [ "$CONT" = S -o "$CONT" = s ]
    then
        echo "Será criado mais um backup para a mesma semana"
    else
        echo "Opção Inválida"
        exit 2
    fi
fi

####Criação do arquivo compactado
echo "Criando o Backup..."
ARQ="backup_home_$(date +%Y%m%d%H%M).tgz"

tar zcvpf $DIRDEST/$ARQ --absolute-names --exclude="$HOME/Google Drive" --exclude=$HOME/Videos --exclude="$DIRDEST" "$HOME"/* > /dev/null
#tar zcvpf $DIRDEST/$ARQ --exlcude="DIRDEST" "HOME"/* > /dev/null

echo
echo "O backup de nome \""$ARQ"\" foi criado em $DIRTEST"
echo
echo "Backup Concluído!"