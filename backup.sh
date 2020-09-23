#!/bin/bash
#
# Description:
# Use batch file with SFTP shell script without prompting password
# using SSH-Keys to backup database and assets
#
##################################################################

BACKUP_SERVER=""
DT=$(date +"%d-%b-%Y-%H-%M");
DIR="backup_${DT}";
TAR_DB="${DIR}.tar.gz"
TAR_ASSETS="assets_${DIR}.tar.gz"
ASSETS_PATH=""
MONGO_PATH=""
BACKUP_PATH=""
TELEGRAM_TOKEN=""
CHAT_ID=""

function backup_database()
{
    mongodump --out ${MONGO_PATH}/${DIR};
    tar -czvPf $TAR_DB ${MONGO_PATH}/$DIR;
    check_op=$?
}

function sendTG() {
    curl -s "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendmessage" --data "text=${*}&chat_id=${CHAT_ID}&disable_web_page_preview=true&parse_mode=Markdown" > /dev/null
}

function backup_assets()
{
    cp -r $ASSETS_PATH $MONGO_PATH;
    tar -czvPf $TAR_ASSETS $MONGO_PATH/assets/;
    check_op=$?
}

function send_backup()
{
    echo "cd backups/" > tempfile.txt;
    echo "put /tmp/${TAR_DB}" >> tempfile.txt;
    echo "quit" >> tempfile.txt;
    sftp -b tempfile.txt $BACKUP_SERVER;
    check_op=$?;
}

function send_backup_assets()
{
    echo "cd backups/" > tempfile.txt;
    echo "put /tmp/${TAR_ASSETS}" >> tempfile.txt
    echo "quit" >> tempfile.txt;
    sftp -b tempfile.txt $BACKUP_SERVER;
    check_op=$?;
}

backup_database
if [ $check_op -ne 0 ]
then
    backup_database
    sendTG "Backup failed! %0ADate: $(date +"%d-%b-%Y") %0ATime: $(date + "%H-%M")"
else
    send_backup
    if [ $check_op -eq 0 ]
    then
        backup_assets
        if [ $check_op -eq 0 ]
        then
            send_backup_assets
            mv /root/$TAR_DB /tmp/$TAR_ASSETS $BACKUP_PATH
            rm -rf ${MONGO_PATH}/assets/ ${MONGO_PATH}/$DIR tempfile.txt
            sendTG "Backup successful! %0ADate: $(date +"%d-%b-%Y") %0ATime: $(date +"%H:%M")"
        else
            sendTG "Backup failed! %0ADate: $(date +"%d-%b-%Y") %0ATime: $(date +"%H:%M")"
        fi
    else
        sendTG  "Backup failed! %0ADate: $(date +"%d-%b-%Y") %0ATime: $(date +"%H:%M")"
    fi
fi
