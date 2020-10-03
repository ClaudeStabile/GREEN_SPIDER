#!/bin/bash 
# Creation de clé Free-Solutions OS bash
#
# Necesssite curl, pv , gunzip
# 
if [ $(id -u) -ne 0 ]; then
        echo "Ce programme nécessite des accès privilégiés."
        echo "Redémarrez ce programme avec sudo ou en temps qu'utilisateur 'root'"
        exit
fi
#
#
echo "Branchez un Clé USB Sandisk Ultrafit 32GB ou Plus"
while [ ! -e /dev/sd[a-z] ] ; do echo "VEUILLEZ BRANCHEZ UNE CLEF USB ULTRAFIT 32GB ou +" && sleep 1 ; done
#time curl -N -s https://www.free-solutions.ch/GREEN_SPIDER/4.0/GREEN_SPIDER_5.0.3.dd.gz | gunzip -c | pv -B32M >
DRIVEUSB=`lsblk | grep disk | awk '{ print $1 }' | grep sd | tail -1l`
DEVUSB=/dev/$DRIVEUSB
MANUFACTURER=`dmesg | grep usb | grep Manufacturer | grep -v Linux | awk '{ print $5" "$6 }' | tail -1l`
PRODUCT=`dmesg | grep usb | grep Product: | grep -v Linux | awk '{ print $5" "$6 }' | tail -1l `
SECTORS=`fdisk -l /dev/sda | head -1l | awk '{ print $6 }' | grep -o -E '[0-9]+'`
DETECTEDTYPE="INCONNU"
# Test du type de clé 32GB Sandisk
#if [ $MANUFACTURER = "SanDisk" ]
if [ `lsusb | grep 0781 | awk '{ print $6}' | tail -1l` ]
then echo "SANDISK KEY DETECTED" && echo "SECTEURS "$SECTORS
if [ $SECTORS = 60062500 ]
then DETECTEDTYPE="sandisk_ultra32_old"
fi
if [ $SECTORS = 60063744 ]
then DETECTEDTYPE="sandisk_ultra32"
fi
if [ $SECTORS = 60088320 ]
then DETECTEDTYPE="sandisk_ultra32_usb31"
fi
if [ $SECTORS = 242614272 ]
then DETECTEDTYPE="sandisk_ultra128_old"
fi
if [ $SECTORS = 240353280 ]
then DETECTEDTYPE="sandisk_ultra128"
fi
fi
echo "Device USB: "$DEVUSB
echo "MANUFACTURER: "$MANUFACTURER
echo "PRODUCT: " $PRODUCT
echo "Modéle de clé détecté :" $DETECTEDTYPE
if [ $DETECTEDTYPE = "sandisk_ultra32_old" ] || [ $DETECTEDTYPE = "sandisk_ultra32" ]
# Il nous faut au minimum 60088320 secteurs de 512, les anciennes clés Sandisk 32GB ne fonctioneront pas
then echo "Clé Sandisk ancienne : MODELE INCORRECT Merci d'utiliser le sernier modèle Sandisk Ultra 32GB !!!"  && exit
fi
printf "\nVous pouvez tenter de créer votre clef USB Free-Solutions OS"
printf "\nVous avez besoin d'une très bonne connection Internet, sans interruptions"
printf "\nAUCUN FICHIER n'est chargé sur votre machine, le code est directement écrit depuis Internet sur la clé USB\n\n"

#echo "ETES VOUS SUR et CERTAIN de VOULOIR EFFACER :" $DEVUSB ?
read -p "Continuer et effacer intégralement $DEVUSB (O/N)?"
if [ "$REPLY" != "O" ]; then
   echo "Sortie - Abandon " exit
else
	echo "Creation de votre clé Free-Solutions OS..."
	echo "Attention le temps d'execution est long voire très long..."
	echo ""
	curl -N -s https://www.free-solutions.ch/GREEN_SPIDER/4.0/GREEN_SPIDER_5.0.3.dd.gz | gunzip -c | pv -B32M > $DEVUSB
fi
sync
echo "Votre clé Bootable Free-Solutions OS est prête à être booté !!! ENJOY"
echo ""
