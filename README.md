# Obsidian Notes with git-crypt

## Instructions

### Prerequisites
- `git-crypt` (install via `brew install git-crypt`)
- Obsidian app installed ( [download](https://obsidian.md/))
- folder created for your Obsidian vault (i.e `~/ObsidianVault`)

### Initialize git repo and setup git-crypt
- initialize git repository ([as you normally would](https://docs.github.com/en/get-started/quickstart/create-a-repo))
```shell
$ cd YourVaultFolder
# delete existing git repo
# let's not expose cleartext history!
$ rm -fr .git/
$ git init
```
 - initialize `git-crypt`
```shell
$ git-crypt init
```
- copy the generated secret key to `~/git-crypt-key` (you will need this `git-crypt-key` to decrypt your vault on other devices so might wanna back it up 🤙)
```shell
git-crypt export-key ../git-crypt-key
```

### Set up .gitignore and .gitattributes

Here is sample `.gitignore`, you may want to put the entire `.obsidian` directory into there, but I like keep my plugins/extensions/etc as well:
```shell
.obsidian/workspace
.obsidian/cache
```

#### Here is sample `.gitattributes`:
- i'm basically encrypting everything including my plugins  `*/**`, but this can be fined tuned later as you please (all markdown files, all obsidian canvas files, all other files)
```shell
*.md filter=git-crypt diff=git-crypt
*/** filter=git-crypt diff=git-crypt
*.canvas filter=git-crypt diff=git-crypt
BrainPad/** filter=git-crypt diff=git-crypt
BrainPad.md filter=git-crypt diff=git-crypt
```

#### (Optional for ZSH) Improve terminal performance
If you’re using `oh-mz-zsh`, the following two commands will prevent it from slowing down your command line (this will modify your vault repo's git config, not the global config):
```shell
$ git config --add oh-my-zsh.hide-status 1
$ git config --add oh-my-zsh.hide-dirty 1
```
- FYI - this results in your vault's `.git/config` to be updated with this...
```shell
[oh-my-zsh]
hide-status = 1
hide-dirty = 1
```

#### Verify and test YOUR .gitattributes
- run this command
```shell
git ls-files -z |xargs -0 git check-attr filter |grep unspecified
```
- you should only see non critical files like `.gitattributes` be reported as unspecified
- if any file is mentioned here that you want to be encrypted, tweak your `.gitattributes` further

### Testing Encryption
- you should see all your encrypted files listed in the output (might take a while)
```shell
git-crypt status -e
```

### Unlocking your Vault
To unlock your Vault's git repo, run this (using `../git-crypt-key` backed up earlier):
```shell
git-crypt unlock ../git-crypt-key
```

### Push your notes to Github
- create **private** empty repository on GitHub (follow the instructions about how to push an existing repository that come up upon creation)
> replace `YourGithubUsername/YourVaultRepo` with your own
```shell
$ git remote add origin \
      git@github.com:YourGithubUsername/YourVaultRepo.git

$ git branch -M master   # ...
$ git push -u origin master
```


>**Note:** From now on, you can add, commit, push from this repository, and `git-crypt` will transparently encrypt and de-crypt your files.

### Locking Your Vault
- if you want, you can lock your vault once you are done (don't have to)
```shell
git-crypt lock
```

---
### Obsidian
- install the  `Obsidian Git` plugin
	- configure the plugin: Make sure, `Disable push` is deactivated.
	- do this on all your desktop/laptop machines

Now, every time you want to sync your changes, press `ctrl+p` and search for “Obsidian Git : commit …”

The plugin will automatically pull all remote changes when you start Obsidian.
If you leave it running for days, you might want to pull recent changes manually: `ctrl+p` and search for “Obsidian Git: Pull”.


---
### Common Issues

#### Git related
- if you get errors on `git push` and it gets stuck on 100% but not finishing, considering increasing your `httpBuffer` in your global git config and retry (this may be the first time you are pushing something bigger, if you decided to backup your plugins/extensions etc like me)
```shell
git config --global http.postBuffer 524288000
```

#### Obsidian Git plugin (desktop)
If you are seeing `git-crypt` related errors in Obsidian on your desktop, it is most likely unable to find `git-crypt` in your path. Instead, tell your `.git/config` the explicit path to `git-crypt` executable (modify it manually):
```shell
[filter "git-crypt"]
        smudge = \"/opt/homebrew/bin/git-crypt\" smudge
        clean = \"/opt/homebrew/bin/git-crypt\" clean
        required = true
[diff "git-crypt"]
        textconv = \"/opt/homebrew/bin/git-crypt\" diff
```

If you get any `gpg` errors, add the path of your gpg executable to your global git config as well.
- first check the full path to the `gpg` installed
```shell
type gpg
gpg is /usr/local/bin/gpg
```
- then configure git to use that full path
```shell
git config --global gpg.program /usr/local/bin/gpg
```
- FYI - this results in your global `.gitconfig` to be updated with this...
```shell
[gpg]
program = /usr/local/bin/gpg
```

---
## BONUS: Android Sync
### Requirements
- install latest Termux from F-Droid
- install Termux Widget 0.13+

### Setup your Termux for Git
- upgrade packages
```shell
pkg upgrade
```
- install required packages
```shell
pkg install git git-crypt
```
- make storage available in Termux (`/storage/shared/*`)
```shell
termux-setup-storage
```
- generate new SSH key (press enter for empty passphrase)
```shell
ssh-keygen -t ed25519 -C "your_email@example.com"
```
- add your new SSH key to your github account ([see here](https://docs.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account))

### Setup your vault in Termux
#### Vault repository setup
- clone the vault repository into Termux home (for now)
> replace `YourGithubUsername/YourVaultRepo` with your own
```shell
git clone git@github.com:YourGithubUser/YourVaultRepo.git
```
- copy the `git-crypt-key` file into termux (you can zip it to `git-crypt-key.zip` and transfer to your device using your favorite method)
- unlock the vault repository (this might take a while)
```shell
# go inside
cd YourVaultRepo
# unlock your vault
git-crypt unlock ../git-crypt-key
```
  - once unlock is finished, move this github vault repo to the shared folder; this is because Obsidian app needs to be able see it:
```shell
# go back home
cd
# move to your storage
mv YourVaultRepo storage/shared/
```

#### Android scripts setup (Termux):
>To take this up a notch further, this gives us very handy commit and push and a pull shortcut that we can launch directly from the comfort of our homescreen

Clone the repository, then copy the `pull.sh, push.sh, log.sh` , `repo.conf` into your termux .shortcuts directory to be able to trigger them from homescreen widget.

- clone the repo containing `.sh` scripts and `.conf` file
```shell
git clone git@github.com:snazzybytes/obsidian-scripts.git
```
- copy all files from `android` folder to Termux's `.shortcuts` directory (needed to get Termux Widget working)
```shell
cp obsidian-scripts/android/* .shortcuts/
```
- update `repo.conf` file with your github vault repo name (this is used by the push/pull/log `.sh` scripts)
```shell
GH_REPO=YourVaultRepo
```
- make sure they are executable
```shell
# go inside and change permissions
cd obsidian-scripts
chmod +x pull.sh push.sh log.sh
# go back to home directory
cd
```
- drop Termux:Widget on your homescreen and you should now see the scripts from `.shortcuts` show up on the list
![alt text](https://imgur.com/hAsT4a1.png "Termux Widget")


BOOM 🚀🔥! Now you can access your encrypted vault on android too and push encrypted changes to github. [see here for demo](https://nostr.build/av/nostr.build_6db2328d571d45977cd81bb65170c82d325fe5280c346c7980ab39ec1d3e731d.mp4)


#### Scripts Documented (same as the repo ones)
>per latest Termux Widget version 0.13+ all custom scripts in Termux `.shortcuts` directory need proper shebangs `#!/data/data/com.termux/files/usr/bin/bash`

pull.sh (allows to pull remote changes)
```shell
#!/data/data/com.termux/files/usr/bin/bash
source repo.conf
cd ~/storage/shared/$GH_REPO
git pull
cd ~
bash -c "read -t 3 -n 1"
```
push.sh (allows to commit and push note changes)
```shell
#!/data/data/com.termux/files/usr/bin/bash
source repo.conf
cd ~/storage/shared/$GH_REPO
git add .
git commit -m "android on $(date)"
git push
cd ~
bash -c "read -t 3 -n 1"
```
log.sh (allows you to check which version you are on with `git log`)
```shell
#!/data/data/com.termux/files/usr/bin/bash
source repo.conf
cd /data/data/com.termux/files/home/storage/shared/$GH_REPO
git log
cd ~
bash -c "read -t 5 -n 1"
```

### Resources and references
- https://willricketts.com/obsidian-changed-everything-for-me/
- https://github.com/AGWA/git-crypt
- https://buddy.works/guides/git-crypt
- https://medium.com/@dianademco/writing-in-obsidian-a-comprehensive-guide-58a1306ed293
- https://renerocks.ai/blog/obsidian-encrypted-github-android/#checking-it-out-on-a-different-machine
- https://publish.obsidian.md/git-doc/Start+here
- https://github.com/denolehov/obsidian-git/issues/21