#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

timedatectl set-timezone Europe/Paris
echo '
#!/bin/bash
 
### BEGIN INIT INFO
# Provides:          firewall
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Démarre les règles iptables
# Description:       Charge la configuration du pare-feu iptables
### END INIT INFO

# On vide les règles déjà existantes
iptables -t filter -F
iptables -t filter -X

# On refuse toutes les connexions
iptables -t filter -P INPUT DROP
iptables -t filter -P FORWARD DROP
iptables -t filter -P OUTPUT DROP
echo "On interdit tout"

# On autorise les connexions déjà établie
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# On autorise le loop-back (localhost)
iptables -t filter -A INPUT -i lo -j ACCEPT
iptables -t filter -A OUTPUT -o lo -j ACCEPT

# On autorise le ping
iptables -t filter -A INPUT -p icmp -j ACCEPT
iptables -t filter -A OUTPUT -p icmp -j ACCEPT

# On autorise le SSH (à adapter suivant votre cas)
iptables -t filter -A INPUT -p tcp --dport 5675 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 5675 -j ACCEPT
#iptables -t filter -A OUTPUT -p tcp --dport 22 -j ACCEPT


# HTTP
iptables -t filter -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 443 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 443 -j ACCEPT
#iptables -t filter -A INPUT -p tcp --dport 8443 -j ACCEPT
' > /etc/init.d/parefeu

chmod +x /etc/init.d/parefeu
update-rc.d parefeu defaults