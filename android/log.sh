#!/data/data/com.termux/files/usr/bin/bash
source /data/data/com.termux/files/home/repo.conf
cd /data/data/com.termux/files/home/storage/shared/$GH_REPO
git log
cd ~
bash -c "read -t 5 -n 1"