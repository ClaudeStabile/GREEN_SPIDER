#!/bin/bash 
#
# Création de clé Free-Solutions OS bash
#
# Nécesssite curl, pv, dialog, unzstd
# Gain 1623MB de moins 
# 

# Valid usb key brands
KEYS=$(echo -e "Corsair\nSanDisk")

if [ $(id -u) -ne 0 ]; then
        echo "Ce programme nécessite des accès privilégiés."
        echo "Redémarrez ce programme avec sudo ou en temps qu'utilisateur 'root'"
        exit
fi
if [ "X${XDG_RUNTIME_DIR}" = "X" ]; then
        if [ ! -d /tmp/runtime-root ]; then
                mkdir  /tmp/runtime-root
        fi
        export XDG_RUNTIME_DIR=/tmp/runtime-root
fi

clear

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
if dpkg -l | grep "zstd" | grep -v libzstd1 >/dev/null; then
	echo "Le package zstd est installé :)"
else
	echo "INSTALLATION du package zstd" && apt install -y zstd
fi

#
# Detect the key to be created ...
#
echo "Recherche de la clé ..."
NBUSB=$(lsusb | grep -e "${KEYS}" | wc -l)
while [ ${NBUSB} -ne 1 ]; do
	if [ ${NBUSB} -gt 1 ]; then
		echo "Trouvé plusieurs clés USB ! Retirez la(les) clé(s) en trop svp"
	else
		echo "Branchez une clé USB Sandisk Ultrafit ou une clé Corsair Padlock svp"
	fi
	sleep 1
	NBUSB=$(lsusb | grep -e "${KEYS}" | wc -l)
done
sleep 2		# Key found, leave a bit of time for the key to be reachable !

#
# Find the drive where the key is inserted
#
MANUFACTURER=$(lsblk -o NAME,VENDOR | grep -e "${KEYS}" | awk '{ print $2 }')
DEVUSB=/dev/$(lsblk -o NAME,VENDOR 2>/dev/null | grep -e "${KEYS}" | awk '{ print $1 }')

#
# Find details about the key
#
PRODUCT=$(lsblk -o MODEL ${DEVUSB} | sed '/^$/d' | grep -v MODEL)
SECTORS=$(fdisk -l ${DEVUSB} 2>/dev/null | grep ${DEVUSB} | awk '{ print $7 }' | head -1)

DETECTEDTYPE="Inconnu"
case "${MANUFACTURER}" in
	"SanDisk")
		case ${SECTORS} in
		60062500)
			DETECTEDTYPE="ultra32_old";;
		60063744)
			DETECTEDTYPE="ultra32";;
		60088320)
			DETECTEDTYPE="Ultra 32 GB";;
		120127488)
			DETECTEDTYPE="Ultra 64 GB";;
		240353280)
			DETECTEDTYPE="Ultra 128 GB";;
		242614272)
			DETECTEDTYPE="Ultra 128 GB";;
		488374272)
			DETECTEDTYPE="Ultra 256 GB";;
		esac;;
	"Corsair")
		case ${SECTORS} in
		60518400)
			DETECTEDTYPE="32 GB";;
		120913920)
			DETECTEDTYPE="64 GB";;
		esac;;
esac

echo "Périphérique USB : "${DEVUSB}
echo "Fabricant        : "${MANUFACTURER}
echo "Produit          : "${PRODUCT}
echo "Modèle           : "${DETECTEDTYPE}

#
# Discard old key models, they don't have enough capacity ...
# Il nous faut au minimum 60088320 secteurs de 512, les anciennes clés Sandisk 32GB ne fonctioneront pas
#
if [ "${DETECTEDTYPE}" = "Inconnu" ]; then
	echo "Modèle de clé inconnu : merci d'utiliser un modèle supporté par le programme"
	exit
fi
if [ "${DETECTEDTYPE}" = "ultra32_old" ] || [ "${DETECTEDTYPE}" = "ultra32" ]; then
	echo "Clé Sandisk ancienne : merci d'utiliser un modèle plus récent de Sandisk Ultra 32GB"
	exit
fi

printf "\nVous allez démarrer la création de votre clef USB Free-Solutions OS"
printf "\nVous avez besoin d'une très bonne connection Internet, sans interruptions"
printf "\nAUCUN FICHIER n'est chargé sur votre machine, le code est directement écrit depuis Internet sur la clé USB\n\n"

read -p "Continuer et effacer intégralement ${DEVUSB} (O/N) ? "
if [ "$REPLY" != "O" ]; then
	echo "Abandon de la procédure de création de clé"
	exit
fi
	
echo "Creation de votre clé Free-Solutions OS..."
echo "Attention le temps d'execution est long, voire très long..."
echo ""
curl -N -s https://www.free-solutions.ch/GREEN_SPIDER/GREEN_SPIDER_RELEASE/GREEN_SPIDER.dd.zst | unzstd -c | (pv -B32M -n - >${DEVUSB} conv=notrunc,noerror) 2>&1 | dialog --title "Creation de Free-Solutions OS sur votre clé USB" --gauge "\nCréation Clé Free-Solutions OS en cours Veuillez patienter...\n\nBien attendre jusqu'au message :\n Votre clé Bootable Free-Solutions OS est prête à être bootée !!! ENJOY" 10 75 0 

sync
dialog --msgbox "Votre clé Bootable Free-Solutions OS est prête à être bootée !!! ENJOY.\nAppuyer sur 'return' pour terminer le programme" 0 0
clear
