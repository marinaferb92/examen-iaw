#!/bin/bash

set -ex

# Variables de entorno - asume que ya has configurado las variables en tu archivo .env
source .env

sudo chown -R www-data:www-data /var/www/html
sudo chown -R www-data:www-data /var/moodledata
sudo chmod -R 755 /var/www/html
sudo chmod -R 755 /var/moodledata

# Configuración recomendada de PHP
sudo sed -i 's/^;*max_execution_time\s*=.*/max_execution_time = 300/' /etc/php/8.3/apache2/php.ini
sudo sed -i 's/^;*memory_limit\s*=.*/memory_limit = 256M/' /etc/php/8.3/apache2/php.ini
sudo sed -i 's/^;*post_max_size\s*=.*/post_max_size = 50M/' /etc/php/8.3/apache2/php.ini
sudo sed -i 's/^;*upload_max_filesize\s*=.*/upload_max_filesize = 50M/' /etc/php/8.3/apache2/php.ini

# Hacer lo mismo para la configuración de PHP CLI
sudo sed -i 's/^;*max_execution_time\s*=.*/max_execution_time = 300/' /etc/php/8.3/cli/php.ini
sudo sed -i 's/^;*memory_limit\s*=.*/memory_limit = 256M/' /etc/php/8.3/cli/php.ini
sudo sed -i 's/^;*post_max_size\s*=.*/post_max_size = 50M/' /etc/php/8.3/cli/php.ini
sudo sed -i 's/^;*upload_max_filesize\s*=.*/upload_max_filesize = 50M/' /etc/php/8.3/cli/php.ini

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
  --adminemail="$MOODLE_ADMINEMAIL" \
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

echo "Instalación y configuración completa. Moodle debería estar funcionando correctamente en $MOODLE_URL"

# Configuración para el servidor detrás de un proxy inverso
sed -i "/\$CFG->admin/a \$CFG->reverseproxy=1;\n\$CFG->sslproxy=1;" /var/www/html/config.php

# Reiniciar el servicio de Apache
systemctl restart apache2
