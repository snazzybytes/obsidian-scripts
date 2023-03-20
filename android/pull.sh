#!/data/data/com.termux/files/usr/bin/bash
source ~/repo.conf
cd ~/storage/shared/$GH_REPO
git pull
cd ~
bash -c "read -t 3 -n 1"