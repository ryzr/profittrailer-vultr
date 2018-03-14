#!/bin/sh

PROFITTRAILER_USER=profittrailer
PROFITTRAILER_HOME=/var/opt/profittrailer
PROFITTRAILER_DOWNLOAD=https://github.com/taniman/profit-trailer/releases/download/v1.2.6.24/ProfitTrailer.zip

SWAP_ENABLED=false
SWAP_SIZE=1G

ln -s /tmp/firstboot.log ${PROFITTRAILER_HOME}/install-in-progress

# ------------------------------------------------
# Download ProfitTrailer
# ------------------------------------------------

echo "Adding user"
useradd --system --user-group --create-home -K UMASK=0022 --home $PROFITTRAILER_HOME $PROFITTRAILER_USER

echo "Downloading ProfitTrailer"
curl -L -o /tmp/ProfitTrailer.zip $PROFITTRAILER_DOWNLOAD

# ------------------------------------------------
# Install and update packages
# ------------------------------------------------

# We have to set up a retry-loop here; Ubuntu automatically runs updates
# on first boot, which can lock us out from installing our dependencies
# ------------------------------------------------

UPGRADE_ATTEMPT_COUNT=100
UPGRADE_STATE=1

echo "Installing dependencies"
for i in `seq 1 $UPGRADE_ATTEMPT_COUNT`;
do
    if [[ "$UPGRADE_STATE" -eq "1" ]]; then
        apt-get -y update
        if [[ "`echo $?`" -eq "0" ]]; then
            echo "package list updated."
            UPGRADE_STATE=2;
        fi
    fi

    if [[ "$UPGRADE_STATE" -eq "2" ]]; then
        apt-get -y upgrade
        if [[ "`echo $?`" -eq "0" ]]; then
            echo "packages updated."
            UPGRADE_STATE=3;
        fi
    fi

    if [[ "$UPGRADE_STATE" -eq "3" ]]; then
        sudo apt-get -y update && sudo apt-get -y install default-jre unzip nodejs npm
        npm install pm2@latest -g
        ln -s /usr/bin/nodejs /usr/bin/node
        break
    fi

    sleep 5
done

if [[ "$UPGRADE_STATE" -ne "3" ]]; then
    echo "ERROR: packages failed to update after $UPGRADE_ATTEMPT_COUNT attempts."
fi

# ------------------------------------------------
# Complete Install
# ------------------------------------------------

echo "Unzipping ProfitTrailer"
unzip -j /tmp/ProfitTrailer.zip -d $PROFITTRAILER_HOME

echo "Updating PM2 configuration"
sed -i 's/"cwd": "."/"cwd": "'$PROFITTRAILER_HOME'"/' $PROFITTRAILER_HOME/pm2-ProfitTrailer.json
sed -i 's/"autorestart": false/"autorestart": true,\n      "error_file": "'$PROFITTRAILER_HOME'\/logs\/error.log",\n      "out_file": "'$PROFITTRAILER_HOME'\/logs\/out.log"/' $PROFITTRAILER_HOME/pm2-ProfitTrailer.json

echo "Adjusting file permissions"
chown -R $PROFITTRAILER_USER:$PROFITTRAILER_USER $PROFITTRAILER_HOME
chmod +x $PROFITTRAILER_HOME/ProfitTrailer.jar

# ------------------------------------------------
# (OPTIONAL) Allocate SWAP Memory
# ------------------------------------------------

# This step is optional, but may be necessary if your server is
# running out of memory. Set SWAP_ENABLED to true if you think SWAP
# is necessary for your setup
# ------------------------------------------------

if [[ "${SWAP_ENABLED}" == "true" ]]; then
    echo "Allocating swap"
    sudo fallocate -l $SWAP_SIZE /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

echo "Install complete"
rm -f /tmp/ProfitTrailer.zip $PROFITTRAILER_HOME/install-in-progress