PROFITTRAILER_USER="profittrailer"
PROFITTRAILER_HOME="/var/opt/${PROFITTRAILER_USER}"
PROFITTRAILER_DOWNLOAD="https://github.com/taniman/profit-trailer/releases/download/v1.2.6.24/ProfitTrailer.zip"

# Install and update packages
sudo apt-get -y update && sudo apt-get -y install default-jre zip nodejs npm
npm install pm2@latest -g

# Download and set up ProfitTrailer
useradd --system --user-group --create-home -K UMASK=0022 --home $PROFITTRAILER_HOME $PROFITTRAILER_USER;
curl -L -o /tmp/ProfitTrailer.zip $PROFITTRAILER_DOWNLOAD;
unzip -j /tmp/ProfitTrailer.zip "ProfitTrailer/*" -d $PROFITTRAILER_HOME
rm -rf /tmp/ProfitTrailer.zip
chown -R $PROFITTRAILER_USER:$PROFITTRAILER_USER $PROFITTRAILER_HOME
chmod +x $PROFITTRAILER_HOME/ProfitTrailer.jar

# (OPTIONAL) Allocate 1GB of SWAP memory
# sudo fallocate -l 1G /swapfile
# sudo chmod 600 /swapfile
# sudo mkswap /swapfile
# sudo swapon /swapfile
# echo '/swapfile none swap sw 0 0'