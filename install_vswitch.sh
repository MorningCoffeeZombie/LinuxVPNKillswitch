#!/bin/bash


# Set common variables
DISTRO="solus"
PROTOCOL="udp"
VPNHOST="nord"
TUNNEL=tun0
TODAYISO=`date '+%Y%m%d-%H%M'`


# Questionaire: offer a more secure hosts file
while true; do
	read -p "Install a new hosts file to increase security and prevent ads? (y/n) " yn
	case $yn in
		[Yy]* ) INSTALLHOSTS="install"; break;;
		[Nn]* ) INSTALLHOSTS="skip"; break;;
		* ) echo "Please answer yes or no.";;
	esac
done

# Questionaire: what protocol to connect via
PS3='What protocol would you like to connect via? '
options=("UDP" "TCP" "Either" "Quit")
select connect in "${options[@]}"
do
	case $connect in
	"UDP")
		PROTOCOL=$connect; echo "$connect entered"; break;;
	"TCP")
		PROTOCOL=$connect; echo "$connect entered"; break;;
	"Either")
		PROTOCOL="udp"; echo "$connect entered"; break;;
	"Quit")
		echo "Quiting program"; exit; break;;
	*) echo "invalid option $REPLY";;
	esac
done

# Make package management agnostic
# Supporting Ubuntu + derivatives, Mint, Debian, Pure, Kali, Parrot and Tails
if [ $(uname -s) = *solus* ]; then
	alias 'apt-get'=eopkg
	DISTRO="solus"
elif [ $(uname -s) = *ubuntu* ] ||  [ $(uname -s) = *mint* ] ||  [ $(uname -s) = *debian* ] || [ $(uname -s) = *pure* ] || [ $(uname -s) = *kali* ] || [ $(uname -s) = *parrot* ] || [ $(uname -s) = *tails* ]; then
        alias eopkg="apt-get"
	DISTRO="debian"
fi

# Check for dependencies, install if absent
if [ $(sudo eopkg check ufw) != "Checking integrity of ufw*OK" ] || [ $(dpkg -s ufw) != "*not installed*" ]; then
	sudo eopkg install ufw
fi
if [ $(sudo eopkg check openvpn) != "Checking integrity of openvpn*OK" ] || [ $(dpkg -s openvpn) != "*not installed*" ]; then
        sudo eopkg install openvpn
fi

# Saving known VPNs
# Taken from:	https://nordvpn.com/tutorials/linux/openvpn/
cd  /etc/openvpn
sudo wget https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip
sudo eopkg install ca-certificates
sudo unzip ovpn.zip
sudo rm ovpn.zip
cd ovpn_${PROTOCOL,,}	# Sets ovpn_ to declared variable in lower case

# Saving original host file as a .BAK with today's date in ISO format and then installing modified verson
if [ $INSTALLHOSTS = "install" ]; then
	sudo cp /etc/hosts /etc/hosts.BAK$TODAYISO
	if [ -f /etc/hosts.BAK$TODAYISO ]l then
		if [ $DISTRO = "solus" ]; then
			sudo cp solus_hosts /etc/hosts
		elif [ $DISTRO = "debian" ]; then
			sudo cp debian_hosts /etc/hosts
		fi
		echo "Your /etc/hosts file has been backed up and replaced"
	fi
fi

# Install shell commands and man page
cp vswitch /usr/bin/vswitch
sudo chmod +x /usr/bin/vswitch
sudo cp vswitch.1 /usr/share/man/man1/

# Adding call for custom functions to ~/.bashrc
sudo echo "# Added by \"LinuxVPNKillswitch\": ">>/etc/skel/.bashrc
sudo echo "# git clone https://github.com/MorningCoffeeZombie/LinuxVPNKillswitch.git">>/etc/skel/.bashrc
sudo echo "source /etc/openvpn/vswitch">>/etc/skel/.bashrc



echo "Installation complete!"
echo "Use the \"vswitch\" command to engage killswitch"

##################
# UNUSED RESOURCES
##################








