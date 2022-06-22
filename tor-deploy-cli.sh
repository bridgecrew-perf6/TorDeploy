#!/bin/bash
#By Gomidee
#Tor Relay/Bridge deploy made easy

##Bridge

bridgeSetup() {

echo "Please run as root"

#Auto-updates

apt-get install unattended-upgrades apt-listchanges

rm /etc/apt/apt.conf.d/50unattended-upgrades
cat << "EOF" >> /etc/apt/apt.conf.d/50unattended-upgrades
Unattended-Upgrade::Origins-Pattern {
    "origin=Debian,codename=${distro_codename},label=Debian-Security";
    "origin=TorProject";
};
Unattended-Upgrade::Package-Blacklist {
};
EOF

rm /etc/apt/apt.conf.d/20auto-upgrades

cat << "EOF" >> /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::AutocleanInterval "5";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Verbose "1";
EOF

unattended-upgrade -d

#Tor Repository

apt install apt-transport-https -y

echo "What Debian/Ubuntu Distribuition are you using"
read input

if [[ $input == "bullseye" | $input == "Bullseye" ]]

	cat << "EOF" >> /etc/apt/sources.list.d/tor.list

deb     [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org bullseye main

deb-src [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org bullseye main

EOF

else

	if [[$input == "bionic" | $input == "Bionic"]]; then

	cat << "EOF" >> /etc/apt/sources.list.d/tor.list

deb     [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org bionic main
deb-src [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org bionic main

EOF

fi
fi

apt install gnupg -y
wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/tor-archive-keyring.gpg >/dev/null
apt update
apt install tor deb.torproject.org-keyring -y
apt install nyx -y


#Bridge Setup

apt-get install obfs4proxy -y
rm /etc/tor/torrc

cat << "EOF" >> /etc/tor/torrc
BridgeRelay 1

# Replace "TODO1" with a Tor port of your choice.
# This port must be externally reachable.
# Avoid port 9001 because it's commonly associated with Tor and censors may be scanning the Internet for this port.
ORPort TODO1

ServerTransportPlugin obfs4 exec /usr/bin/obfs4proxy

# Replace "TODO2" with an obfs4 port of your choice.
# This port must be externally reachable and must be different from the one specified for ORPort.
# Avoid port 9001 because it's commonly associated with Tor and censors may be scanning the Internet for this port.
ServerTransportListenAddr obfs4 0.0.0.0:TODO2

# Local communication port between Tor and obfs4.  Always set this to "auto".
# "Ext" means "extended", not "external".  Don't try to set a specific port number, nor listen on 0.0.0.0.
ExtORPort auto

# Replace "<address@email.com>" with your email address so we can contact you if there are problems with your bridge.
# This is optional but encouraged.
ContactInfo <address@email.com>

# Pick a nickname that you like for your bridge.  This is optional.
Nickname PickANickname

EOF

vi /etc/tor/torrc


#Start service

echo "To start the Tor service use the argument -s"
}




relaySetup() {

echo "Run this script as Root"

#Auto-updates

apt-get install unattended-upgrades apt-listchanges

rm /etc/apt/apt.conf.d/50unattended-upgrades
cat << "EOF" >> /etc/apt/apt.conf.d/50unattended-upgrades
Unattended-Upgrade::Origins-Pattern {
    "origin=Debian,codename=${distro_codename},label=Debian-Security";
    "origin=TorProject";
};
Unattended-Upgrade::Package-Blacklist {
};
EOF

rm /etc/apt/apt.conf.d/20auto-upgrades

cat << "EOF" >> /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::AutocleanInterval "5";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Verbose "1";
EOF

unattended-upgrade -d

#Tor Repository

apt install apt-transport-https -y

echo "What Debian/Ubuntu Distribuition are you using(bullseye or bionic)"
read input

if [[ $input == "bullseye" || $input == "Bullseye" ]]; then

	cat << "EOF" >> /etc/apt/sources.list.d/tor.list

deb     [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org bullseye main

deb-src [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org bullseye main

EOF

else

	if [[$input == "bionic" || $input == "Bionic"]]; then

	cat << "EOF" >> /etc/apt/sources.list.d/tor.list

deb     [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org bionic main
deb-src [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org bionic main

EOF

fi
fi

apt install gnupg -y
wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/tor-archive-keyring.gpg >/dev/null
apt update
apt install tor deb.torproject.org-keyring -y
apt install nyx -y

#Relay setup

rm /etc/tor/torrc

cat << "EOF" >> /etc/tor/torrc

Nickname    myNiceRelay  # Change "myNiceRelay" to something you like
ContactInfo your@e-mail  # Write your e-mail and be aware it will be published
ORPort      443          # You might use a different port, should you want to
ExitRelay   0
SocksPort   0

EOF

vi /etc/tor/torrc
}

startSystemD() {
/etc/init.d/tor_start
}

DisplayLogs() {
journalctl -fu tor@default
}

#Options

case "$1" in
  -b | --bridge)
   bridgeSetup 
  ;;
-r | --relay)
  relaySetup
  ;;
-s | --start)
 startSystemD 
  ;;
 -l | --logs)
  DisplayLogs 
 ;;
*)

#Usage

echo -e "

-b --bridge      Deploy obfs4 Tor bridge
-r --relay       Deploy middle/guard Relay
-s --start       Run Tor systemD service
-l --logs        Display Tor logs"
;;
esac
