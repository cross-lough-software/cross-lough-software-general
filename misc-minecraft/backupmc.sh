#!/bin/bash
# lordfeck's basic mc backup script.
# authored: 02/04/2020

# 1. Configuration.
user="admin"          # Remote server username
server="mc.example.net"    # Remote server address or domain name
mcworld="world"         # MC world directort. default is likely
errorLog="/home/${user}/backupmc.log"   # local path to backup log
localDestination="/home/${user}/mcbackups/" # where to copy backups
backupName="worldmap"     # name of tar.gzip backup file
clearDestination="yes"      # set to yes to delete all old backups

# 2. Calculation
today=$(date -I)

echo "Checking if variables have been set via the command line."

# 3. Check command line arguments.
for arg in "$@"
do
	case $arg in
		-h|--help)
		# Display Help
		echo
    echo "This script is designed to help back up a java Minecraft world that is running on on a server."
		echo "It can be used with cron to make the process completely automated."
		echo
    echo "Short Syntax: [-U|S|MCW|EL|LD|BN|CD]"
		echo
    echo "Different Options:"
    echo "-U=<usename> or --user=<username>     Used to set remote server username. Default = admin"
		echo "-S=<server> or --server=<serverName>  Remote server address or domain name. Default = mc.example.net"
		echo "-MCW=<minecraftWorldName> or --mcworld=<minecraftWorldName>     MC world directort. Default is likely to be Ok. Default = world"
		echo
		echo "-EL=<localPathToBackUpLog> or --errorLog=<localPathToBackUpLog>     Local path to backup log including log file name. Default = /home/${user}/backupmc.log"
		echo "-LD=<PathToCopyTo> or --localDestination=<PathToCopyTo>     Where to copy backups to. Default = /home/${user}/mcbackups/"
		echo "-BN=<backupName> or --backupName=<backupName>     Name of tar.gzip backup file. Default = worldmap"
		echo "-CD=<YesOrNo> or --clearDestination=<YesOrNo>     Set to yes to delete all old backups. Default is Yes"
    shift # Remove --help from processing
		exit 0
    ;;
		-U=*|--user=*)
  	user="${arg#*=}"
  	shift # Remove --user= from processing...
  	;;
		-S=*|--server=*)
  	server="${arg#*=}"
  	shift # Remove --server= from processing...
  	;;
		-MCW=*|--mcworld=*)
  	mcworld="${arg#*=}"
  	shift # Remove --mcworld= from processing...
  	;;
		-EL=*|--errorLog=*)
  	errorLog="${arg#*=}"
  	shift # Remove --errorLog= from processing...
  	;;
		-LD=*|--localDestination=*)
  	localDestination="${arg#*=}"
  	shift # Remove --localDestination= from processing...
  	;;
		-BN=*|--backupName=*)
  	backupName="${arg#*=}"
  	shift # Remove --backupName= from processing...
  	;;
		-CD=*|--clearDestination=*)
  	clearDestination="${arg#*=}"
  	shift # Remove --clearDestination= from processing...
  	;;
		*)
     echo "Non valid option used."
     ;;
	esac
done

echo "Output of all the variable values:"
echo
echo "User chosen = $user"
echo "Server Name = $server"
echo "mcworld name = $mcworld"
echo "errorLog Destination = $errorLog"
echo "local Destination = $localDestination"
echo "backupName = $backupName"
echo "clearDestination = $clearDestination"
echo


# 4. exeCution
echo "Backup MC. Run as CRON. Assumes SSH key is authorised by the server."
echo "Also assumes that minecraft server runs from ${user}'s home directory."
echo "Run me from CRON or run to backup now. Beginning in 2 seconds..."
echo
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
