
# ------------------------------------ install vue

sudo npm install -g @vue/cli

# ------------------------------------ install angular

sudo npm install -g @angular/cli

# ------------------------------------ react native

#sudo npm install -g react-native-cli
#npm i -g @react-native-community/cli
#npx react-native init AwesomeProject

# ------------------------------------ cordova

sudo npm install -g cordova
sudo apt install openjdk-8-jdk -y

echo '
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
' >> $HOME/.bashrc
source $HOME/.bashrc

sudo add-apt-repository ppa:cwchien/gradle
sudo apt-get update
sudo apt-get install gradle -y

# change java
# sudo update-alternatives --config javac

# ------------------------------------ flutter

sudo snap install flutter --classic
flutter doctor
flutter doctor --android-licenses 

flutter config --android-sdk="$HOME/Android/Sdk"
flutter config --android-studio-dir="/snap/android-studio/current/android-studio"

# ------------------------------------ php composer

sudo apt install php -y
sudo curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
composer

