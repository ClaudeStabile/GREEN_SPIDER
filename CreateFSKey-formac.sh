#!/bin/bash
if [ -e ./GREEN_SPIDER_5.0.3.dd.gz ]
then
    echo "La distribution a été détectée sur votre disque dur."
else
    echo "La distribution n'a pas été détectée sur votre disque dur."
    echo "Téléchargement de la distribution ( environ 9 Go). Merci de patienter"
    curl -N -s https://www.free-solutions.ch/GREEN_SPIDER/4.0/GREEN_SPIDER_5.0.3.dd.gz --output GREEN_SPIDER_5.0.3.dd.gz
    echo "Fin du téléchargement."
fi

i=1
while read -r Output; do
if [ "$Output" != "/Volumes" ] ; then
    DriveChoice[$i]=$Output
    echo "$i=${DriveChoice[$i]}"
    i=$(( i+1 ))
fi
done < <( find /Volumes -maxdepth 1 -type d)

echo "Source Drive Number?"
read DriveNumber

if [ $DriveNumber -lt $i ] && [ $DriveNumber -gt 0 ]; then
    Source=${DriveChoice[$DriveNumber]}"/"

echo "Vous avez sélectionné le disque suivant:"
df -Hl | grep "${DriveChoice[$DriveNumber]}" | awk '{ print $1,$2,$9 }'
echo "Ce volume va être formaté, toutes les données seront supprimées."
echo "Vous validez ? : Y/N"
read Validation
if [ $Validation == "N" ]
then
    exit
else
    echo "Creation de votre clé Free-Solutions OS..."
	echo "Attention le temps d'execution est long voire très long..."
	echo ""
    
    AbsPath=$(df -P $Source | awk 'END{print $1}' | rev | cut -d"s" -f2-3 | rev)
    Optim_AbsPath=${AbsPath/disk/rdisk}
    diskutil quiet unmountDisk $Optim_AbsPath
    gunzip -c ./GREEN_SPIDER_5.0.3.dd.gz | dd bs=32m of=$Optim_AbsPath
    sync
    diskutil quiet unmountDisk $AbsPath
    echo "Votre clé Bootable Free-Solutions OS est prête à être bootée !!! ENJOY"
echo ""
fi

else
    echo "Drive selection error!"
fi

#### CREDIT
#### La détection des volumes est tirée de cet article :
#### https://stackoverflow.com/questions/15274269/bash-user-drive-selection
#### Merci https://stackoverflow.com/users/1126841/chepner
