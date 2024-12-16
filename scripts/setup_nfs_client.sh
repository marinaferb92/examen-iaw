#!/bin/bash
# Configuración para mostrar los comandos y detener en caso de error
set -ex

# Importamos el archivo .env
source .env

# Actualizamos el sistema
apt update

# Instalamos el cliente NFS
apt install nfs-common -y

# Creamos los directorios necesarios si no existen
[ ! -d "/var/www/html" ] && sudo mkdir -p /var/www/html
[ ! -d "/var/moodledata" ] && sudo mkdir -p /var/moodledata

# Montamos las carpetas NFS temporalmente para comprobar
sudo mount $NFS_SERVER_IP:/var/www/html /var/www/html
sudo mount $NFS_SERVER_IP:/var/moodledata /var/moodledata

# Verificamos el montaje
df -h | grep /var/www/html || echo "Error al montar /var/www/html"
df -h | grep /var/moodledata || echo "Error al montar /var/moodledata"

# Configuramos las entradas permanentes en /etc/fstab
grep -q "$NFS_SERVER_IP:/var/www/html" /etc/fstab || \
echo "$NFS_SERVER_IP:/var/www/html /var/www/html nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" | sudo tee -a /etc/fstab

grep -q "$NFS_SERVER_IP:/var/moodledata" /etc/fstab || \
echo "$NFS_SERVER_IP:/var/moodledata /var/moodledata nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" | sudo tee -a /etc/fstab

# Aplicamos los cambios de fstab
sudo mount -a

# Verificamos nuevamente los montajes
df -h | grep /var/www/html || echo "Error: /var/www/html no montado correctamente"
df -h | grep /var/moodledata || echo "Error: /var/moodledata no montado correctamente"

echo "Configuración del cliente NFS completada."
