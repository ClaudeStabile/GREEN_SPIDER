#!/bin/bash
# Creation de clé Free-Solutions OS bash
#
# Necesssite curl, pv , gunzip
# 
echo "Branchez un Clé USB Sandisk Ultrafit 32GB ou Plus"
while [ ! -e /dev/sd[a-z] ] ; do echo "VEUILLEZ BRANCHEZ UNE CLEF USB ULTRAFIT 32GB ou +" && sleep 1 ; done
#time curl -N -s https://www.free-solutions.ch/GREEN_SPIDER/4.0/GREEN_SPIDER_5.0.3.dd.gz | gunzip -c | pv -B32M >
DRIVEUSB=$(kdialog --combobox "Free-Solutions installation Disk" `cat listedev.txt`)
MANUFACTURER=`dmesg | grep usb | grep Manufacturer | grep -v Linux | awk '{ print $5" "$6 }' | tail -1l | grep -oE '[^ ]+$'`
PRODUCT=`dmesg | grep usb | grep Product: | grep -v Linux | awk '{ print $5" "$6 }' | tail -1l `
SECTORS=`fdisk -l /dev/$DRIVEUSB | head -1l | awk ' { print $7 }'`
# Test du type de clé 32GB Sandisk
#if [ $MANUFACTURER = "SanDisk" ]
if [ `lsusb | grep 0781 | awk '{ print $7}' | tail -1l` ]
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

echo "Device USB: "$DRIVEUSB
echo "MANUFACTURER: "$MANUFACTURER
echo "PRODUCT: " $PRODUCT

