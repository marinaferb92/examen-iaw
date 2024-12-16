#!/bin/bash 
# Para mostrar los comandos que se van ejecutando
set -ex

# Cargamos las variables
source .env

# Crear la base de datos y el usuario para Wordpress
mysql -u root <<< "DROP DATABASE IF EXISTS $MOODLE_DB_NAME"
mysql -u root <<< "CREATE DATABASE $MOODLE_DB_NAME"
# Creamos el usuario que será capaz de acceder a la base de datos con todos los permisos
mysql -u root -e "DROP USER IF EXISTS '$MOODLE_DB_USER'@'$FRONTEND_PRIVATE_IP';"
mysql -u root -e "CREATE USER '$MOODLE_DB_USER'@'$FRONTEND_PRIVATE_IP' IDENTIFIED BY '$MOODLE_DB_PASSWORD';"
mysql -u root -e "GRANT ALL PRIVILEGES ON $MOODLE_DB_NAME.* TO '$MOODLE_DB_USER'@'$FRONTEND_PRIVATE_IP';"