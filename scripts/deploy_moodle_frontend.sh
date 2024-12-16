#!/bin/bash

set -ex

# Variables de entorno - asume que ya has configurado las variables en tu archivo .env
source .env

# Eliminamos las descargas previas de Moodle en /tmp
rm -rf /tmp/moodle-latest-405.tgz*

# Descargamos la última versión estable de Moodle
wget https://download.moodle.org/download.php/direct/stable405/moodle-latest-405.tgz -P /tmp

# Extraemos el archivo descargado
tar -xzf /tmp/moodle-latest-405.tgz -C /tmp

# Preparamos el directorio de instalación de Moodle
sudo mkdir -p $MOODLE_DIRECTORY
# Eliminamos cualquier archivo o instalación previa en el directorio de Moodle
sudo rm -rf $MOODLE_DIRECTORY/*

# Movemos los archivos extraídos al directorio de instalación de Moodle
mv /tmp/moodle/* "$MOODLE_DIRECTORY"

# Cambiar los permisos de Moodle
chown -R www-data:www-data "$MOODLE_DIRECTORY"
chmod -R 755 "$MOODLE_DIRECTORY"

# Copiamos el archivo .htaccess para configurar el acceso y seguridad en el servidor web
cp ../htaccess/.htaccess "$MOODLE_DIRECTORY"

# Copiamos el archivo de configuración de Apache
cp ../conf/000-default.conf /etc/apache2/sites-available/000-default.conf

# Crear el directorio de datos de Moodle
chown -R www-data:www-data /var/www/moodledata
chmod -R 755 /var/www/moodledata

# Instalamos las extensiones php requeridas para Moodle
sudo apt remove -y php-curl php-zip php-xml php-mbstring php-gd
sudo apt install -y php-curl php-zip php-xml php-mbstring php-gd

# Reiniciamos Apache para aplicar las nuevas extensiones PHP
systemctl restart apache2


# Ejecutar la instalación de Moodle sin interacción
sudo -u www-data php "$MOODLE_DIRECTORY/admin/cli/install.php" \
  --lang="$MOODLE_LANG" \
  --wwwroot="$MOODLE_URL" \
  --dataroot="$MOODLE_DATAROOT" \
  --dbtype="$MOODLE_TYPE" \
  --dbname="$MOODLE_DB_NAME" \
  --dbuser="$MOODLE_DB_USER" \
  --dbpass="$MOODLE_DB_PASSWORD" \
  --dbhost="$MOODLE_DB_HOST" \
  --fullname="$MOODLE_FULLNAME" \
  --shortname="$MOODLE_SHORTNAME" \
  --summary="$MOODLE_SUMMARY" \
  --adminuser="$MOODLE_ADMIN" \
  --adminpass="$MOODLE_ADMINPASS" \
  --adminemail="$MOODLE_ADMINemail" \
  --non-interactive \
  --agree-license

# Configuración de PHP max_input_vars
sudo sed -i 's/^;*max_input_vars\s*=.*/max_input_vars = 5000/' /etc/php/8.3/apache2/php.ini
sudo sed -i 's/^;*max_input_vars\s*=.*/max_input_vars = 5000/' /etc/php/8.3/cli/php.ini

# Reiniciamos Apache para aplicar las configuraciones de PHP
systemctl restart apache2

# Cambiar los permisos del directorio web
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

# Verificar configuración de Apache
sudo apachectl configtest

# Reiniciar Apache para aplicar los cambios de SSL y redirección
sudo systemctl restart apache2

# Verificar estado de Apache
sudo systemctl status apache2

echo "Instalación y configuración completa. Moodle debería estar funcionando correctamente en $MOODLE_URL"

sed -i "/\$CFG->admin/a \$CFG->reverseproxy=1;\n\$CFG->sslproxy=1;" /var/www/html/wp-config.php

# Reiniciar el servicio de Apache 
systemctl restart apache2 
