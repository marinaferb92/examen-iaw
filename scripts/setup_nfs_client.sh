#!/bin/bash

# Configuramos para mostrar los comandos y finalizar
set -ex

#Importamos el archivo .env

source .env

# Actualizamos el sistema
apt update

#instalar el cliente nfs
apt install nfs-common -y

sudo mount $NFS_SERVER_IP:/var/www/html /var/www/html  #comprobamos con df -h
sudo mount $NFS_SERVER_IP:/var/moodledata /var/moodledata

echo "$NFS_SERVER_IP:/var/www/html /var/www/html nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab
echo "$NFS_SERVER_IP:/var/moodledata /var/moodledata /var/www/html nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab