#!/bin/sh

SWAP_ENABLED=false
SWAP_SIZE=1G

DISABLE_ROOT_LOGIN=false
ADMIN_USERNAME=admin

DISABLE_PASSWORD_LOGIN=false
SSH_PORT=22

PROFITTRAILER_USER=profittrailer
PROFITTRAILER_HOME=/var/opt/profittrailer
PROFITTRAILER_DOWNLOAD=https://github.com/taniman/profit-trailer/releases/download/v2.0.2/ProfitTrailer.zip

# ------------------------------------------------
# (OPTIONAL) Allocate SWAP Memory
# ------------------------------------------------

# This step is optional, but may be necessary if your server is
# running out of memory. Set SWAP_ENABLED to true if you think SWAP
# is necessary for your setup
# ------------------------------------------------

if [[ "${SWAP_ENABLED}" == "true" ]]; then
    echo "Allocating swap"
    fallocate -l $SWAP_SIZE /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' |  tee -a /etc/fstab
fi

# ------------------------------------------------
# (OPTIONAL) Disable login with password
# ------------------------------------------------

# This step is optional, but adds an additional layer of security
# To ssh into server, you MUST authenticate with an authorised SSH key
# ------------------------------------------------

if [[ "${DISABLE_PASSWORD_LOGIN}" == "true" ]]; then
    echo "Disabling logging in with passwords"
    sed -i 's|#PasswordAuthentication yes|PasswordAuthentication no|' /etc/ssh/sshd_config
    service sshd restart
fi

# ------------------------------------------------
# (OPTIONAL) Disable root login
# ------------------------------------------------

# This step is optional, but adds an additional layer of security
# To ssh into server, you MUST authenticate with $ADMIN_USERNAME
# ------------------------------------------------

if [[ "${DISABLE_ROOT_LOGIN}" == "true" ]]; then
    echo "Disabling root login"
    useradd $ADMIN_USERNAME --create-home --shell /bin/bash
    cp /root/.ssh /home/$ADMIN_USERNAME/.ssh -R
    chown -R $ADMIN_USERNAME:$ADMIN_USERNAME /home/$ADMIN_USERNAME/.ssh
    usermod -aG sudo $ADMIN_USERNAME
    sed -i 's|'$ADMIN_USERNAME':!:|'$ADMIN_USERNAME':'$(sed -n 's|^root:\([^:]*\):.*|\1|p' /etc/shadow)':|' /etc/shadow
    sed -i 's|PermitRootLogin yes|PermitRootLogin no|' /etc/ssh/sshd_config
    service sshd restart
fi

# ------------------------------------------------
# (OPTIONAL) Change SSH port
# ------------------------------------------------

# This step is optional, but adds an additional layer of security
# To ssh into server, you MUST specify your custom port "-p SSH_PORT"
# ------------------------------------------------

if [[ "$SSH_PORT" -ne "22" ]]; then
    echo "Changing SSH port"
    sed -i 's|Port 22|Port '$SSH_PORT'|' /etc/ssh/sshd_config
    sed -i 's|#Port '$SSH_PORT'|Port '$SSH_PORT'|' /etc/ssh/sshd_config
    service sshd restart
fi

echo "Running ProfitTrailer install script"
useradd --system --user-group --create-home -K UMASK=0022 --home $PROFITTRAILER_HOME $PROFITTRAILER_USER

if [[ "${DISABLE_ROOT_LOGIN}" == "true" ]]; then
    usermod -a -G $PROFITTRAILER_USER $ADMIN_USERNAME
fi

ln -s /tmp/firstboot.log ${PROFITTRAILER_HOME}/install-in-progress

# ------------------------------------------------
# Download ProfitTrailer
# ------------------------------------------------

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
        apt-get -y install default-jre unzip nodejs npm fail2ban
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
unzip /tmp/ProfitTrailer.zip -d /tmp
mv /tmp/ProfitTrailer/* $PROFITTRAILER_HOME

echo "Updating PM2 configuration"
sed -i 's|"cwd": "."|"cwd": "'$PROFITTRAILER_HOME'"|' $PROFITTRAILER_HOME/pm2-ProfitTrailer.json
sed -i 's|"autorestart": false|"autorestart": true,\n      "error_file": "'$PROFITTRAILER_HOME'/logs/error.log",\n      "out_file": "'$PROFITTRAILER_HOME'/logs/out.log"|' $PROFITTRAILER_HOME/pm2-ProfitTrailer.json

echo "Adjusting file permissions"
chown -R $PROFITTRAILER_USER:$PROFITTRAILER_USER $PROFITTRAILER_HOME
chmod +x $PROFITTRAILER_HOME/ProfitTrailer.jar
chmod g+w $PROFITTRAILER_HOME -R

echo "Install complete"
cp /tmp/firstboot.log $PROFITTRAILER_HOME/install.log
rm -rf /tmp/ProfitTrailer /tmp/ProfitTrailer.zip $PROFITTRAILER_HOME/install-in-progress
