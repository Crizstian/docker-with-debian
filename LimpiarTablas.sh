#!/bin/bash
#Politica
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
#Limpieza de cadenas
iptables -F INPUT
iptables -F OUTPUT
iptables -F FORWARD
iptables -t nat -F PREROUTING
iptables -t nat -F POSTROUTING
iptables -F VALIDA_TCP_O
iptables -F VALIDA_TCP_I
iptables -F DOCKER
iptables -X DOCKER
iptables -X VALIDA_TCP_O
iptables -X VALIDA_TCP_I
