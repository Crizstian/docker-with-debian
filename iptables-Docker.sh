#!/bin/bash
#Obtener valor de variables
ip_eth0=$(ifconfig | grep -A 1 'eth0' | tail -1 | cut -d ':' -f 2  | cut -d ' ' -f 1)
ip_eth1=$(ifconfig | grep -A 1 'vboxnet0' | tail -1 | cut -d ':' -f 2  | cut -d ' ' -f 1)
ip_interna="192.168.99.0/24"
ip_docker="172.17.0.0/16"
ip_servidor=$(docker-machine ip ecosistemas)
#ip_dns="189.194.248.231"
echo "Externa"
echo $ip_eth0
echo "Interna"
echo $ip_eth1
echo "Docker network"
echo $ip_docker
echo "Servidor web"
echo $ip_servidor

#Activar comunicacion entre interfaces
echo 1 > /proc/sys/net/ipv4/ip_forward
#Politica
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
#Permitir accesos a localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -i docker0 -j ACCEPT
iptables -A OUTPUT -o docker0 -j ACCEPT
#Retiene Ataque DoS
iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
#Establecimiento de Conexion
iptables -N VALIDA_TCP_O
iptables -A VALIDA_TCP_O -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -N VALIDA_TCP_I
iptables -A VALIDA_TCP_I -m state --state ESTABLISHED -j ACCEPT
########################################################################################
#Procesos locales
########################################################################################
## so dns lookups are already allowed for your other rules
iptables -A OUTPUT -p udp -d 0/0 --dport 53 -j VALIDA_TCP_O
iptables -A INPUT  -p udp -s 0/0 --sport 53 -j VALIDA_TCP_I
#Permitir solo entrada de SSH
iptables -A OUTPUT -p tcp -s $ip_eth0 -d 0/0 --sport 22 -j VALIDA_TCP_I
iptables -A INPUT -p tcp -s 0/0 -d $ip_eth0 --dport 22 -j VALIDA_TCP_O
#Permite acceder a internet en el firewall
iptables -A OUTPUT -p tcp -s $ip_eth0 -d 0/0 -m multiport --dport 21,80,443 -j VALIDA_TCP_O
iptables -A INPUT -p tcp -s 0/0 -d $ip_eth0 -m multiport --sport 21,80,443 -j VALIDA_TCP_I
iptables -A INPUT -p tcp -s 0/0 -d $ip_eth0 -m multiport --dport 21,80,443 -j VALIDA_TCP_O
iptables -A OUTPUT -p tcp -s $ip_eth0 -d 0/0 -m multiport --sport 21,80,443 -j VALIDA_TCP_I
#Procesos Docker
iptables -N DOCKER
iptables --wait -t filter -A DOCKER ! -i docker0 -o docker0 -d $ip_docker -p tcp -m multiport --dport 80,443,2376,3306 -j ACCEPT
iptables -A INPUT -p tcp --sport 2376 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 2376 -j ACCEPT
##################################################################################################
#       Acceso Servidor Web de la Red Externa                                                    #
##################################################################################################
iptables -t nat -A PREROUTING -p tcp -i eth0 -s 0/0 -d $ip_eth0 --dport 80 -j DNAT --to-destination $ip_servidor:8080
iptables -t nat -A POSTROUTING -p tcp -o eth0 -s $ip_servidor -d 0/0 -j MASQUERADE
iptables -t nat -A PREROUTING -p tcp -i vboxnet0 -s 0/0 -d $ip_eth0 --dport 80 -j DNAT --to-destination $ip_servidor:8080
iptables -t nat -A POSTROUTING -o vboxnet0 -s 0/0 -d $ip_servidor -j MASQUERADE
##################################################################################################
#       Establecimiento Uso y Cierre                                                             #
#################################################################################################
iptables -A FORWARD -i eth0 -o vboxnet0 -s 0/0 -d $ip_servidor -p tcp --dport 8080 -j VALIDA_TCP_O
iptables -A FORWARD -i vboxnet0 -o eth0 -s $ip_servidor -d 0/0 -p tcp --sport 8080 -j VALIDA_TCP_I
iptables -A FORWARD -i eth0 -o vboxnet0 -s 0/0 -d $ip_servidor -p tcp --dport 8080 -j VALIDA_TCP_O
iptables -A FORWARD -i vboxnet0 -o eth0 -s $ip_servidor -d 0/0 -p tcp --sport 8080 -j VALIDA_TCP_I
##################################################################################################
# Cerramos cualquier otra entrada o salida
##################################################################################################
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP
