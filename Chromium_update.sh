#!/bin/bash
# Install de Chromium Free-Solutions
# This script upgrade to latest Free-Solutions chromium version
#
# Go in Download Folder / Free-Solutions OS only
#
kdialog --title "Mise à jour du Browser Chromium Free-Solutions" --warningyesno "VOULEZ VOUS METTRE A JOUR CHROMIUM FREE-SOLUTIONS"
cd /home/kubuntu/Downloads
link="https://www.free-solutions.ch/GREEN_SPIDER/GREEN_SPIDER_RELEASE/chromium-browser-stable.deb" # Download latest chromium package
    a=$(kdialog --progressbar "W-Get will  download: Nowardev GitHub Master stuff " 100);sleep 2
    qdbus $a  showCancelButton true

    while read line ;do
    read -r p t <<< "$line"
    echo $p 
    echo $t 
    qdbus $a Set org.kde.kdialog.ProgressDialog value $p

        while [[  $(qdbus  $a wasCancelled) != "false" ]] ; do
            echo "KILLING THE PROCESS AND KDIALOG"
            qdbus $a  org.kde.kdialog.ProgressDialog.close 

            exit
        done


qdbus $a org.kde.kdialog.ProgressDialog.setLabelText "W-Get télécharge: Free-Solutions OS Chromium Browser  time left : $t" 


done< <(wget "$link" 2>&1 |mawk -W interactive '{ gsub(/\%/," "); print int($7)" "$9 }')
# Kill progress bar
pid=`ps -ef | grep /usr/bin/kdialog_progress_helper | grep -v grep | awk '{print $2 }'` && if [ $pid ] ; then kill -9 $pid ; fi
# Installing
echo "Installing Chromium"
cd /home/kubuntu/Downloads
#dpkg -i chromium-browser-stable.deb
sudo gdebi-gtk chromium-browser-stable.deb
