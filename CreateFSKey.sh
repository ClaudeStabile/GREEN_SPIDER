#!/bin/bash 
#
# Création de clé Free-Solutions OS bash
#
# Nécesssite curl, pv, dialog, gzip
# 

# Clear screen and show purpose
clear
cat << !EOF
Ce programme va créer une clé USB de démarrage d'un ordimateur
Après démarrage de l'ordinateur depuis cette clé USB, un environnement
	graphique sous Linux est mis à la disposition de l'utilisateur

!!! N'introduisez la clé USB que lorsque le programme le demande !!!

Merci de suivre les autres instructions à l'écran svp

!EOF

# some testing first : need to be superuser or executed as sudo & check Linux distrib
if [ $(id -u) -ne 0 ]; then
        echo "Ce programme nécessite des accès privilégiés."
        echo "Redémarrez ce programme avec sudo ou en temps qu'utilisateur 'root'"
        exit
fi

if [ -f /etc/os-release ]; then
	LINUX_DISTRIB=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2 | cut -d' ' -f1)
	case ${LINUX_DISTRIB} in
		Ubuntu)	;;
		Debian) ;;
		*)	echo -e "\nCe programme n'est testé que sur Debian, Ubuntu et dérivés (Kubuntu, etc)"
			echo "Merci de communiquer le problème au développeur"
			exit
			;;
	esac
else
	echo -e "\nVersion Linux inconnue. Le programme ne peut s'exécuter correctement)"
	echo "Merci de communiquer le problème au développeur"
	exit
fi

if [ "X${XDG_RUNTIME_DIR}" = "X" ]; then
        if [ ! -d /tmp/runtime-root ]; then
                mkdir  /tmp/runtime-root
        fi
        export XDG_RUNTIME_DIR=/tmp/runtime-root
fi

#
# Check, and if necessary, install packages 'pv', 'dialog', 'curl' and 'gzip'
#
if dpkg -l | grep "pv" | grep "pipeline" >/dev/null; then
	echo "Le package pv est installé :)"
else
	echo "INSTALLATION du package pv" && apt install -y pv
fi
if dpkg -l | grep "user-friendly dialog"  | grep -v whiptail >/dev/null; then
	echo "Le package dialog est installé :)"
else
	echo "INSTALLATION du package dialog" && apt install -y dialog
fi
if dpkg -l | grep "curl"  | grep "command line tool" >/dev/null; then
	echo "Le package curl est installé :)"
else
	echo "INSTALLATION du package curl" && apt install -y curl
fi
if dpkg -l | grep "gzip"  >/dev/null; then
	echo "Le package gzip est installé :)"
else
	echo "INSTALLATION du package gzip" && apt install -y gzip
fi

#
# Detect the key to be created ...
#
(udevadm monitor -u --subsystem-match=block > udev.monitor &)
echo -e "\nIntroduisez une clé USB dans un slot libre svp..."
KEY=$(grep add udev.monitor | sed 's/.*\/block\///' | cut -d'/' -f1 | cut -d' ' -f1 | uniq)
while [ "X${KEY}" == "X" ]; do
	sleep 2
	echo "Introduisez une clé USB dans un slot libre svp..."
	KEY=$(grep add udev.monitor | sed 's/.*\/block\///' | cut -d'/' -f1 | cut -d' ' -f1 | uniq)
done

kill $(ps -ea | grep udevadm | sed 's/^ *//' | cut -d' ' -f1)
rm udev.monitor

NBUSB=$(echo -e "${KEY}" | wc -l)
if [ ${NBUSB} -ne 1 ]; then
	echo "Trouvé plusieurs clés USB !"
	echo "Retirez la(les) clé(s) en trop et recommencez le processus svp"
	exit
fi

#
# Find iand display the details about the inserted USB key
#
DEVUSB=/dev/${KEY}
MANUFACTURER=$(lsblk -o VENDOR,TYPE ${DEVUSB} | grep disk | awk '{ print $1 }')
PRODUCT=$(lsblk -o MODEL,TYPE ${DEVUSB} | grep disk | awk '{ print $1 }')
SIZE=$(lsblk -o SIZE,TYPE ${DEVUSB} | grep disk | awk '{ print $1 }')
SECTORS=$(fdisk -l ${DEVUSB} 2>/dev/null | grep ${DEVUSB} | awk '{ print $7 }' | head -1)

echo -e "\nLes caractéristiques de la clé USB insérée sont les suivantes :"
echo -e "\tPériphérique USB : "${DEVUSB}
echo -e "\tFabricant        : "${MANUFACTURER}
echo -e "\tProduit          : "${PRODUCT}
echo -e "\tCapacité         : "${SIZE}
echo -e "\tSecteurs         : "${SECTORS}

if [ ${SECTORS} -lt 60062500 ]; then
	echo -e "\nCette clé n'a pas la capacité suffisante pour installer Linux dessus"
	echo "La capacité MINIMALE de la clé doit être de 32GB"
	echo "Abandon de la procédure de création de clé"
	exit
fi

cat << !EOF

Vous allez démarrer la création de votre clef USB Free-Solutions OS
Vous avez besoin d'une très bonne connection Internet, sans interruptions
AUCUN FICHIER n'est chargé sur votre machine, le code est directement écrit depuis Internet sur la clé USB

!EOF

read -p "Continuer et effacer intégralement la clé ${MANUFACTURER} ${PRODUCT} ${SIZE} sur ${DEVUSB} (O/N) ? "
if [ "$REPLY" != "O" ]; then
	echo "Abandon de la procédure de création de clé"
	exit
fi
	
echo "Creation de votre clé Free-Solutions OS..."
echo "Attention le temps d'execution est long, voire très long..."
echo ""
curl -N -s https://www.free-solutions.ch/GREEN_SPIDER/GREEN_SPIDER_RELEASE/GREEN_SPIDER.dd.gz | gunzip -c | (pv -B32M -n - >${DEVUSB} conv=notrunc,noerror) 2>&1 | dialog --title "Creation de Free-Solutions OS sur votre clé USB" --gauge "\nCréation Clé Free-Solutions OS en cours Veuillez patienter...\n\nBien attendre jusqu'au message :\n Votre clé Bootable Free-Solutions OS est prête à être bootée !!! ENJOY" 10 75 0 

sync
dialog --msgbox "Votre clé Bootable Free-Solutions OS est prête à être bootée !!! ENJOY.\nAppuyer sur 'return' pour terminer le programme" 0 0
clear
