#!/bin/bash
if [ "$1" == "1" ] ; then
	echo ---------- Quitando repo chrome
	if [ -f /etc/apt/sources.list.d/google-chrome.list ] ; then
		rm /etc/apt/sources.list.d/google-chrome.list
	fi
	echo ---------- Quitando tonterias ubuntu-pro
	if [ -f /etc/apt/apt.conf.d/20apt-esm-hook.conf ] ; then
		rm /etc/apt/apt.conf.d/20apt-esm-hook.conf
	fi
	echo ---------- Actualizando
	apt update
	apt --fix-broken install -y
	apt upgrade -y
	echo ---------------------hay que reiniciar!!!
	exit
fi
if [ "$1" == "2" ] ; then 
	echo ---------- Chequeando si estamos en 20.04
	grep 20.04 /etc/os-release > /dev/null
	if [ "$?" == "0" ] ; then
		echo --------- upgrade to 22.04
		apt autoremove -y
		apt clean
		apt dist-upgrade -y
		do-release-upgrade
	else
		echo no hace falta actualizar
	fi
fi
if [ "$1" == "3" ] ; then
	KERNEL=6.5.0-35
	echo --------- Instalando ultimo kernel $KERNEL
	apt install linux-headers-$KERNEL-generic \
	    linux-hwe-6.5-headers-$KERNEL \
	    linux-image-$KERNEL-generic \
	    linux-modules-$KERNEL-generic \
	    linux-modules-extra-$KERNEL-generic -y
	echo -------------finalizando en la version------------
		grep 04 /etc/os-release
	echo ---------hay que reiniciar-------------
	exit
fi
if [ "$1" == "4" ] ; then 
	echo ----------- Volando snap!!
	which snap > /dev/null
	if [ "$?" == "0" ] ; then 
		for i in $(snap list| grep -vE "Name|snapd|core|bare" | awk '{print $1}'); do sudo snap remove $i ; done
		for i in $(snap list| grep -vE "Name|snapd" | awk '{print $1}'); do sudo snap remove $i ; done
		for i in $(snap list| grep -vE "Name" | awk '{print $1}'); do sudo snap remove $i ; done
		apt remove snapd -y
	fi

	echo ---------- Limpiando basura 
	apt remove --purge ubuntu-advantage-tools distro-info ubuntu-pro-client firefox snapd plasma-discover-backend-snap -y
	apt -f install
        apt remove --purge $(dpkg -l | grep "^rc" | awk '{print $2}') -y
	apt autoremove -y
	apt clean

	if [ -f /etc/systemd/system/var-snap-firefox-common-host\\x2dhunspell.mount ] ; then
		systemctl stop var-snap-firefox-common-host\\x2dhunspell.mount
		systemctl disable var-snap-firefox-common-host\\x2dhunspell.mount
		mv /etc/systemd/system/var-snap-firefox-common-host\\x2dhunspell.mount \
		  /etc/systemd/system/var-snap-firefox-common-host\\x2dhunspell.mount.disabled
	fi
	exit
fi

if [ "$1" == "5" ] ; then 
	#https://linuxconfig.org/switching-to-firefoxs-deb-installation-on-ubuntu-22-04-a-guide-to-avoiding-snap-packages
	#https://support.mozilla.org/en-US/kb/install-firefox-linux#w_install-firefox-deb-package-for-debian-based-distributions
	echo --------- Instalando firefox como la gente
	apt update
	apt remove firefox -y
	apt autoremove -y
	apt clean -y
        apt --fix-broken install -y

	echo ------firefox deb
	install -d -m 0755 /etc/apt/keyrings
	wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
	gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); print "\n"$0"\n"}'
	echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null
# quito la tabulacion sino la preferencia no sirve
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla 
	sudo apt-get update && sudo apt-get install firefox firefox-l10n-es-es -y

	echo -----firefox-esr
	BASE=http://ppa.launchpadcontent.net/mozillateam/ppa/ubuntu/pool/main/f/firefox-esr/ 
	curl -s $BASE | cut -d \" -f 8 | grep -E "firefox-esr_|firefox-esr-locale-es" | grep amd64 | grep "22.04" \
		| while read line 
		   do echo $line 
		      wget -qO $line $BASE/$line 
		   done
	echo -------- Instalando
	sudo dpkg -i $(ls firefox*.deb)
	
	find /home -type f -name '*mimeapps.list' -exec sed 's/firefox.desktop/firefox-esr.desktop/g' -i {} \;
fi
