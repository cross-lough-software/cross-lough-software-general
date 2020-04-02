#!/bin/bash
# lordfeck's basic mc backup script.
# authored: 02/04/2020

# 1. Configuration.
user="admin"          # Remote server username
server="mc.example.net"    # Remote server address or domain name
mcworld="world"         # MC world directort. default is likely
errorLog="/home/myuser/backupmc.log"   # local path to backup log
localDestination="/home/myuser/mcbackups/" # where to copy backups
backupName="worldmap"     # name of tar.gzip backup file
clearDestination="yes"      # set to yes to delete all old backups

# 2. Calculation
today=$(date -I)

# 3. exeCution
echo "Backup MC. Run as CRON. Assumes SSH key is authorised by the server."
echo "Also assumes that minecraft server runs from ${user}'s home directory."
echo "Run me from CRON or run to backup now. Beginning in 2..."
sleep 2

echo "Beginning backup for $(date)" >> $errorLog

if [ "$clearDestination" = "yes" ]; then
#	echo "Clearing destination first." >> $errorLog
	2>> $errorLog rm ${localDestination}/*.tgz
fi

2>> $errorLog ssh "$user@$server" "tar -czf ${backupName}-${today}.tgz $mcworld/" 

if [ "$?" -ne "0" ]; then
    echo "Problem using SSH or Tar." >> $errorLog
    exit 1
fi

echo "Now fetching backup from the server."
2>> $errorLog scp "$user@$server:/home/$user/${backupName}-${today}.tgz" "${localDestination}"

if [ "$?" -ne "0" ]; then
    echo "Problem fetching backup from server or copying to destination." >> $errorLog
    exit 1
fi

echo "Now removing backup on remote server."
2>> $errorLog ssh "$user@$server" "rm ~${user}/${backupName}-${today}.tgz" 

echo "Backup complete!" >> $errorLog
