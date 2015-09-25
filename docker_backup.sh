#!/bin/bash
###########################################################################################
#	 Script creado por: Cristian Ramirez Rosas																							#
#  Contacto: cristiano.rosetti@gmail.com																									#
###########################################################################################
maquina="ecosistemas"
fecha=`date +%Y-%m-%d`
#####################################
# setting environment               #
#####################################
docker-machine start ${maquina}
eval `docker-machine env ${maquina}`
#####################################
# Backing up database and web files #
#####################################
cd /home/ecosistemas/Docker/backup
docker exec -it docker_eco_db_1 sh -c "mysqldump -u root -pecosistemas drupal > /backup/${fecha}-bd.sql"
docker exec -it docker_eco_web_1 tar cvf /backup/${fecha}-archivos_web.tar /var/www/html
