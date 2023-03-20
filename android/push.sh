#!/data/data/com.termux/files/usr/bin/bash
source repo.conf
cd ~/storage/shared/$GH_REPO
git add .
git commit -m "android on $(date)"
git push
cd ~
bash -c "read -t 3 -n 1"