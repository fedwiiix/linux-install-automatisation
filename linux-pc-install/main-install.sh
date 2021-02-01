\#!/bin/sh

if [ "$EUID" -ne 0 ] then echo "Please run as root" exit fi

sudo apt update sudo apt upgrade -y

# ------------------------- apps

sudo apt install curl -y sudo apt install git -y git config --global user.email "fedwiiix@gmail.com" git config --global user.name "fred"

# --- snap

sudo apt-get install snapd -y sudo apt-get install gdebi -y

sudo snap install skype --classic sudo snap install "whatsapp-for-linux" sudo snap install qownnotes #sudo snap install gimp

sudo apt-get install transmission -y sudo apt-get install terminator -y sudo apt install htop -y sudo apt install nmap -y

sudo snap install onlyoffice-desktopeditors

# nmap -T4 -sP 192.168.1.0/24

# --- sudo snap install nextcloud-client

sudo add-apt-repository ppa:nextcloud-devs/client sudo apt update sudo apt install nextcloud-client -y

# --- vivaldi

wget https://downloads.vivaldi.com/stable/vivaldi-stable_3.4.2066.106-1_amd64.deb -O vivaldi.deb sudo gdebi vivaldi.deb #or sudo dpkg -i vivaldi.deb rm vivaldi.deb

# ------------------------- visual studo code

sudo snap install --classic code

# install ext - code --list-extensions

echo " bmewburn.vscode-intelephense-client burkeholland.simple-react-snippets CoenraadS.bracket-pair-colorizer Dart-Code.dart-code Dart-Code.flutter donjayamanne.githistory esbenp.prettier-vscode felixfbecker.php-intellisense gmlewis-vscode.flutter-stylizer jcbuisson.vue mblode.twig-language-2 MehediDracula.php-namespace-resolver ms-python.python ms-toolsai.jupyter ms-vscode-remote.remote-ssh ms-vscode-remote.remote-ssh-edit ms-vscode.cpptools necinc.elmmet octref.vetur ritwickdey.LiveServer VisualStudioExptTeam.vscodeintellicode wmira.react-playground-vscode Wscats.vue xabikos.JavaScriptSnippets " > vscode-extensions.list cat vscode-extensions.list | xargs -L 1 code --install-extension rm vscode-extensions.list

# --- android studio

sudo apt install openjdk-14-jdk -y #sudo apt install default-jdk -y #sudo add-apt-repository ppa:maarten-fonville/android-studio #sudo apt update #sudo apt install android-studio -y

sudo snap install android-studio --classic

echo ' export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 export PATH=$PATH:$JAVA_HOME/bin export ANDROID_HOME=$HOME/Android/Sdk export PATH=$PATH:$ANDROID_HOME/emulator export PATH=$PATH:$ANDROID_HOME/tools export PATH=$PATH:$ANDROID_HOME/tools/bin export PATH=$PATH:$ANDROID_HOME/platform-tools ' >> $HOME/.bashrc source $HOME/.bashrc

# check android studio path before

echo 'export PATH=$PATH:/opt/android-studio/bin' >> $HOME/.bashrc source \~/.bashrc

# --- node js

sudo snap install node --channel=15/stable --classic node -v && npm -v

# --- npm install without Sudo

\#sudo chown -R $(whoami) \~/.npm #mkdir \~/.npm #npm config set prefix \~/.npm #echo ' #export PATH="$PATH:$HOME/.npm/bin" #' >> $HOME/.bashrc #source $HOME/.bashrc

# --------------------------- connexion ssh without password to b@B

ssh-keygen -t rsa ssh fred@sjtm.fr mkdir -p .ssh cat .ssh/id_rsa.pub | ssh fred@sjtm.fr 'cat >> .ssh/authorized_keys' ssh-add ssh fred@sjtm.fr

# ----------------------------- elemenntary apps

# Clipped

sudo apt install com.github.davidmhewitt.clipped -y

# snippetpixie

sudo snap install snippetpixie --classic

# Improve Laptop battery life

sudo apt install tlp tlp-rdw -y

# Install Tweaks

sudo apt install software-properties-common -y sudo add-apt-repository ppa:philip.scott/elementary-tweaks sudo apt update sudo apt install elementary-tweaks -y

# Install Drivers

sudo ubuntu-drivers autoinstall

# ------------------------------------ config

# unable web keychain

sudo chmod a-x /usr/bin/gnome-keyring\* sudo killall gnome-keyring-daemon

sudo apt autoremove -y && sudo apt clean-y

exit