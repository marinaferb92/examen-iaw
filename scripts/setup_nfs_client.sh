#!/bin/bash

# Configuramos para mostrar los comandos y finalizar
set -ex

#Importamos el archivo .env

source .env

# Actualizamos el sistema
apt update

#instalar el cliente nfs
apt install nfs-common -y

sudo mount $IP_NFS_SERVER:/var/www/html /var/www/html  #comprobamos con df -h
sudo mount $IP_NFS_SERVER:/var/moodledata /var/moodledata
