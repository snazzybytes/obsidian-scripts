#!/data/data/com.termux/files/usr/bin/bash
source repo.conf
cd ~/storage/shared/$GH_REPO
git reset --hard origin/master
cd ~
bash -c "read -t 5 -n 1"