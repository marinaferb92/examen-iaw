#!/bin/bash

# Configuramos para mostrar los comandos y finalizar
set -ex

#Importamos el archivo .env

source .env

#Instalamos el NFS Server
apt install nfs-kernel-server -y

#Creamos el directorio que vamos a compartir
mkdir -p /var/www/html

#Modificamos el porpietario y el grupo del directorio
sudo chown nobody:nogroup /var/www/html

#Creamos el directorio que vamos a compartir
mkdir -p /var/moodledata

#Modificamos el porpietario y el grupo del directorio
sudo chown nobody:nogroup /var/moodledata

#Copiamos el archivo de configuracion de NFS
cp ../nfs/exports /etc/exports

#Reemplazamos el valor de la plantilla de /etc/exports
sed -i "s#FRONTEND_NETWORK#$FRONTEND_NETWORK#" /etc/exports

#Reiniciamos el servicio NFS
systemctl restart nfs-kernel-server


