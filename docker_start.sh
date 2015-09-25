#!/bin/bash
ruta="/home/ecosistemas/Docker"
#################################################################
#	Inicializamos el servidor virtual           									#
#################################################################
docker-machine start ecosistemas
eval `docker-machine env ecosistemas`
#################################################################
#	Preparamos los contenedores                 									#
#################################################################
docker create -v backup:/backup --name respaldo debian bash -c "echo dir respaldo has been started to share"
docker create -v web:/var/www/html --name web_data drupal bash -c "echo dir web has been started to share"
docker create -v /var/lib/mysql:/var/lib/mysql --name db_data mysql bash -c "echo dir database has been started to share"

docker-compose -f ${ruta}/docker-compose.yml up -d
#################################################################
#	Activacion de iptables para el sercidor base									#
#################################################################
sh ${ruta}/LimpiarTablas.sh
sh ${ruta}/iptables-Docker.sh
