#!/bin/bash
# Configuración para mostrar los comandos y detener en caso de error
set -ex

# Importamos el archivo .env
source .env

# Actualizamos el sistema
apt update

# Instalamos el cliente NFS
apt install nfs-common -y

# Montamos las carpetas NFS temporalmente para comprobar
sudo mount $NFS_SERVER_IP:/var/www/html /var/www/html
sudo mount $NFS_SERVER_IP:/var/moodledata /var/moodledata

# Verificamos el montaje
df -h | grep /var/www/html
df -h | grep /var/moodledata

# Configuramos las entradas permanentes en /etc/fstab
echo "$NFS_SERVER_IP:/var/www/html /var/www/html nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab
echo "$NFS_SERVER_IP:/var/moodledata /var/moodledata nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab