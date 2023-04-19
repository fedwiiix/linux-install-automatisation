#!/bin/bash

# allow to copy prod database to dev server
# clear symfony cache automatically
# connect to server by ssh without ssh key

action=$1
env=$2
showHelp=false

devPass='pass'
devSsh=back@dev.back.example.fr

prodPass='pass'
prodSsh=back@prod.back.example.fr

file='back-save.sql'

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

if [[ $action = "ssh" ]]
then
    # clear cache according env
    if [[ $env = "dev" ]]
    then
        echo -e "${GREEN} - load ssh${NC}"
        sshpass -p $devPass ssh -o StrictHostKeyChecking=no $devSsh
        exit
    elif [[ $env = "prod" ]]
    then
        echo -e "${GREEN} - load ssh${NC}"
        sshpass -p $prodPass ssh -o StrictHostKeyChecking=no $prodSsh 
        exit
    fi

elif [[ $action = "cache:clear" ]]
then
    # clear cache according env
    if [[ $env = "dev" ]]
    then
        echo -e "${GREEN} - clear cache${NC}"
        sshpass -p $devPass ssh -o StrictHostKeyChecking=no $devSsh "cd back/current/ && php bin/console cache:clear"
        echo -e "${GREEN} - done !${NC}"
        exit
    elif [[ $env = "prod" ]]
    then
        echo -e "${GREEN} - clear cache${NC}"
        sshpass -p $prodPass ssh -o StrictHostKeyChecking=no $prodSsh "cd back/current/ && php bin/console cache:clear"
        echo -e "${GREEN} - done !${NC}"
        exit
    fi

elif [[ $action = "update:database" ]]
then

    echo -e "${GREEN} - export prod database${NC}"
    sshpass -p $prodPass ssh -o StrictHostKeyChecking=no $prodSsh "cd back/ && mysqldump -u back -p'$prodPass' back > $file"

    echo -e "${GREEN} - download prod database${NC}"
    sshpass -p $prodPass scp $prodSsh:/home/back/back/$file ./

    echo -e "${GREEN} - check file${NC}"
    if [ -f "./$file" ]
    then 
        echo -e "file exist"
    else
        echo -e "${GREEN} - file not downloaded${NC}"
        exit
    fi

    echo -e "${GREEN} - upload prod database to dev server${NC}"
    sshpass -p $devPass scp ./$file $devSsh:/home/back/back/

    echo -e "${GREEN} - import database to dev${NC}"
    sshpass -p $devPass ssh -o StrictHostKeyChecking=no $devSsh "cd back/ && mysql -u back -p$devPass back < $file"
    echo -e "${GREEN} - clean${NC}"
    rm -f $file
fi

echo -e "
yp-automation.sh [action] [env]
action:
    - ssh
    - cache:clear
    - update:database
env:
    - dev
    - prod"
