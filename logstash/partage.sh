#!/bin/bash
userPartageServer="user_30"
homePrivateKeyPath="/data/.ssh/partage-key-rsa"
homePrivateKeyDistantPath=".ssh/partage-key-rsa"
sshPartageServer="ssh.XXX.fr"
logPartageServer="syslog.XXX.fr"

execSSHCommande="ssh -q -i ${homePrivateKeyPath} -l ${userPartageServer} ${sshPartageServer} ssh -q -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile /dev/null' -i ${homePrivateKeyDistantPath} -l ${userPartageServer} ${logPartageServer}"

DATE=$(date '+%Y%m%d')
pathLogPartage=/data/RECUP

if [ ! -d "$pathLogPartage" ];then
        mkdir -p $pathLogPartage
fi


listeLog=$($execSSHCommande ls -nl *.log | awk -F " " '{print $9}')

for log in $listeLog; do
        if [ -f $pathLogPartage/$DATE-$log ]; then
                mv $pathLogPartage/$DATE-$log $pathLogPartage/$DATE-$log.0
                $execSSHCommande cat $log > $pathLogPartage/$DATE-$log
                diff --unchanged-line-format= $pathLogPartage/$DATE-$log.0 $pathLogPartage/$DATE-$log
        else
                $execSSHCommande cat $log > $pathLogPartage/$DATE-$log
                cat $pathLogPartage/$DATE-$log
        fi
    find $pathLogPartage -type f -not -name "*$DATE-*.*" -exec rm -f {} \;

done
