#!/data/data/com.termux/files/usr/bin/bash
source repo.conf
cd ~/storage/shared/$GH_REPO
git add .
git commit -m "android backup: $(date '+%Y-%m-%d %H:%M:%S%z')"
git push
cd ~
bash -c "read -t 3 -n 1"