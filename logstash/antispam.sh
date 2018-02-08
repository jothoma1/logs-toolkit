#!/bin/bash
# J.THOMAS / 05/02/2018
# Logs Antispam RENATER
# Recup via FTP et utilisation dans logstash qui renvoie dans Graylog

DATE=$(date '+%Y%m%d')
INIT="FTPSERVER"
RENATERPWD="USER:PASS"

#valider cas rajout domaine

if [ ! -d "./$INIT" ]; then
        wget -A $DATE.log -q --passive-ftp -r ftp://$RENATERPWD@$INIT
        DOMAINS=$(find ./$INIT -mindepth 1 -maxdepth 1 -not -empty -type d | sed -e '1,$s/\.\/log-ftpserver.renater.fr\///')
        for DOMAIN in $DOMAINS; do
                if [ -f "./$INIT/$DOMAIN/$DATE.log" ]; then
                        cat "./$INIT/$DOMAIN/$DATE.log"
                fi
        done
else
        DOMAINS=$(find ./$INIT -mindepth 1 -maxdepth 1 -not -empty -type d | sed -e '1,$s/\.\/log-ftpserver.renater.fr\///')
        for DOMAIN in $DOMAINS; do
                if [ ! -f "./$INIT/$DOMAIN/$DATE.log" ]; then
                        wget -q --passive-ftp -r ftp://$RENATERPWD@$INIT/$DOMAIN/$DATE.log
                        if [ -f "./$INIT/$DOMAIN/$DATE.log" ]; then
                                cat "./$INIT/$DOMAIN/$DATE.log"
                        fi
                else
                        mv "./$INIT/$DOMAIN/$DATE.log" "./$INIT/$DOMAIN/$DATE.log.0"
                        wget -q --passive-ftp -r ftp://$RENATERPWD@$INIT/$DOMAIN/$DATE.log
                        diff --unchanged-line-format= ./$INIT/$DOMAIN/$DATE.log.0 ./$INIT/$DOMAIN/$DATE.log
                fi
        done
fi
