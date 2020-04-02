#!/bin/sh
# Shortcut script to start a Java Minecraft server.

if [ ! -s "server.jar" ]; then
	echo server missing
	exit 1
fi

java -Xmx1024M -Xms1024M -jar server.jar nogui 
