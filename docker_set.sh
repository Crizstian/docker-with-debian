###########################################################################################
#	 Instalando Docker y configurando   	   																								#
#	 el entorno virtual para ecosistemas   																									#
#																																													#
#	 Script creado por: Cristian Ramirez Rosas																							#
#  Contacto: cristiano.rosetti@gmail.com																									#
#	 Fecha de creacion: 14 de Septiembre del 2015																						#
#																																													#
#	 Insitituo Tecnológico de Morelia: 																											#
# 	Asesor Interno: M.C. Brenda Gomez Gonzalez																						#
#																																													#
#	Instituto de Investigaciones en Ecosistemas y Sustentabilidad de la UNAM Campus Morelia	#
# 	Asesor Externo: Ing. Atzimba Graciela López Maldonado																	#
#																																													#
###########################################################################################
#!/bin/bash
d_machine_v="v0.3.0"
d_compose_v="1.4.0"
vbox_v="4.3"
maquina="ecosistemas"
directorio="/home/ecosistemas/Docker"
compose="docker-compose.yml"
REPO="deb http://download.virtualbox.org/virtualbox/debian jessie contrib"
#########################################################
#	Actualizar Servidor																		#
#########################################################
rm /var/lib/dpkg/updates/*
apt-get update
apt-get -y upgrade
if dpkg-query -W sudo; then
	echo "sudo instalado";
else
	echo "instalando curl";
	apt-get -y install sudo
	adduser ecosistemas sudo
fi
if dpkg-query -W curl; then
	echo "curl instalado";
else
	echo "instalando curl";
	apt-get -y install curl
fi
#########################################################
#	Instalar Docker Engine																#
#########################################################
if dpkg-query -W docker-engine; then
	echo "Docker Engine instalado";
else
	apt-get -y purge docker-engine
	apt-get -y autoremove --purge docker-engine
	rm -rf /var/lib/docker
	echo "Instalado Docker Engine";
	curl -sSL https://get.docker.com/ | sh
	curl -sSL https://get.docker.com/gpg | sudo apt-key add -
fi
#########################################################
#	Instalar Docker Machine 															#
#########################################################
curl -L https://github.com/docker/machine/releases/download/${d_machine_v}/docker-machine_linux-amd64 > /usr/local/bin/docker-machine
chmod +x /usr/local/bin/docker-machine
echo "Docker Machine Instalado"
docker-machine -v
#################################################################
#	Instalando virtualbox para linux basado en debian							#
#################################################################
kill $(ps -ax | grep virtualbox | awk '{ print $1 }')
if dpkg-query -W virtualbox-5.0; then
 echo "Eliminando virtualbox-5 por incopatibilidad";
 apt-get -y remove --purge virtualbox-5.0
fi
if dpkg-query -W virtualbox-${vbox_v}; then
 echo "virtualbox-4.3 instalado";
else
 apt-get -y remove --purge virtualbox-${vbox_v}
 if ! grep -q "$REPO" /etc/apt/sources.list; then
  echo "$REPO" | tee -a /etc/apt/sources.list
 else
  echo "Repositario ya existe";
 fi
 apt-get update
 apt-key add oracle_vbox.asc
 wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | apt-key add -
 echo "Instalado Virtualbox";
 apt-get -y install virtualbox-${vbox_v}
 apt-get -y install dkms
fi
#################################################################
#	Creando entorno virtual para el servidor de Ecosistemas				#
#################################################################
machine=$(docker-machine ls | grep "ecosistemas" | cut -c1-11)
if [ $maquina == $machine ]; then
 docker-machine rm -f ${maquina}
fi
docker-machine create --driver "virtualbox" --virtualbox-cpu-count "1" \
--virtualbox-disk-size "30000" --virtualbox-memory "2560" \
ecosistemas
docker-machine start ${maquina}
eval `docker-machine env ${maquina}`
#####################################################################
#       Instalando Docker Compose                      							#
#####################################################################
rm /usr/local/bin/docker-compose
curl -L https://github.com/docker/compose/releases/download/${d_compose_v}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
echo "Docker Compose Instalado"
docker-compose --version
###################################################################
#	Preparamos los contenedores																			#
###################################################################
if [ ! -d "$directorio" ]; then
  echo "Creando Carpeta";
	cd /home/ecosistemas/
	mkdir -p Docker
	cd /home/ecosistemas/Docker
	mkdir -p backup
	cd /home/ecosistemas/Docker/
	if [ ! -f ${compose} ]; then
	    echo "no existe archivo para inicializar el servicio de docker-compose";
			echo "copiando archivos ...";
			mv /tmp/Dockerfile /tmp/${compose} /tmp/iptables-Docker.sh /tmp/LimpiarTablas.sh /tmp/docker_set.sh /tmp/web/ .
			mv /tmp/docker_backup.sh /tmp/start_docker_ecosistemas_service /tmp/docker_start.sh .
			chmod -R 775 /home/ecosistemas/Docker/
			chmod -R 777 web/
	fi
else
	echo "Ya existe Carpeta Docker"
	ls /home/ecosistemas/Docker
fi
#################################################################
#	Creando volumes para datos	e inicializando contenedores			#
#################################################################
sh ./docker_start.sh
#################################################################
#	Creamos la base de datos y permisos para web									#
#################################################################
docker exec -it docker_eco_db_1 sh -c 'exec mysql -uroot -pecosistemas -e"create database if not exists drupal"'
docker exec -it docker_eco_web_1 sh -c 'chown -R www-data:www-data /var/www/html/sites'
