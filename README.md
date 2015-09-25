# docker-with-debian

This code was created to configure a debian 8.2 server, this server will deploy a web docker container and a docker database container

## Configuration of the server

- Instalation of Debian 8.2
- Instalación of Virtualbox 4.3
- Instalation of Docker-Machine 0.3.0

### Configuring virtual environment for Ecosistemas using docker-machine and virtualbox as a provideer 
Docker container configuration:
- web server 
- database server
- data only container for persistence

### Bash scripts for the configuration
- <code>docker_set.sh</code> // script that makes all the configurations 
- <code>Dockerfile</code> // Dockerfile based on Drupal
- <code>docker-compose.yml</code> // the docker-compose file to startup the multicontainer
- <code>docker_backup.sh</code> // script that makes data backups for the docker containers
- <code>iptables-Docker.sh</code> // script that enables the iptables rules for our web application
- <code>LimpiarTablas.sh</code> // script that clean's up our iptables

## Deploying the services

with <code>docker-compose -up -d</code> we start the main purpose for the web application
