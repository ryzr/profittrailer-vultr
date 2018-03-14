# Profit Trailer Vultr Startup Script

1. [Create Startup Script in Vultr](https://my.vultr.com/startup/manage/?SCRIPTID=new)

Configuration:
- Name: ProfitTrailer
- Type: Boot
- Contents: See [install.sh](https://raw.githubusercontent.com/ryzr/profittrailer-vultr/master/install.sh)

You may uncomment lines 18 - 22 if you wish to allocate swap memory, which may be useful if your server does not have a lot of RAM already.

2. [Deploy A New Server](https://my.vultr.com/deploy/)

Configuration
- Location: Tokyo/Sydney/Dallas
- Type: Ubuntu 16.04 x64
- Server Size: 1 CPU 512MB Memory
- Startup Script: Choose script created above (ProfitTrailer)

3. SSH into server and [configure ProfitTrailer as per their documentation](https://wiki.profittrailer.com/doku.php?id=instructions#create_an_exchange_account_get_your_api_keys).

Notes:
- The bot can be located in `/var/opt/profittrailer`
- You can do this via the commandline with something like `scp ~Downloads/ProfitTrailer/application.properties root@YOUR_SERVER_IP:/var/opt/profittrailer/application.properties`

4. Run ProfitTrailer bot `pm2 start /var/opt/profittrailer/pm2-ProfitTrailer.json`

5. Save the current configuration to apply on reboot `pm2 save && pm2 startup`