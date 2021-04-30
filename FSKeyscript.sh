#!/bin/bash
#
#Telecharge et Lance CreateFSZST.sh
cd /etc/FS_SCRIPTS
mv /etc/FS_SCRIPTS/CreateFSKeyZST.sh /etc/FS_SCRIPTS/CreateFSKeyZST.sh.ori
wget https://www.free-solutions.ch/GREEN_SPIDER/GREEN_SPIDER_RELEASE/CreateFSKeyZST.sh -O /etc/FS_SCRIPTS/CreateFSKeyZST.sh
chmod +x /etc/FS_SCRIPTS/CreateFSKeyZST.sh
echo "Insérez un clé USB 32GB Sandisk dernier Modedèle MERCI !!!"
sudo /etc/FS_SCRIPTS/CreateFSKeyZST.sh
