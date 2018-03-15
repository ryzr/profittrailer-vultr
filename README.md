# Profit Trailer Vultr Startup Script

## Basic Setup

### 1. [Create Startup Script in Vultr](https://my.vultr.com/startup/manage/?SCRIPTID=new)

Configuration:
- Name: ProfitTrailer
- Type: Boot
- Contents: See [install.sh](https://raw.githubusercontent.com/ryzr/profittrailer-vultr/master/install.sh)

Please also give my [Recommendations](#recommendations) section below a thorough read. This will include security measures that I highly recommend.

### 2. [Deploy A New Server](https://my.vultr.com/deploy/)

Configuration
- Location: Tokyo/Sydney/Dallas
- Type: Ubuntu 16.04 x64
- Server Size: 1 CPU 512MB Memory
- Startup Script: Choose script created above (ProfitTrailer)

Installation can take awhile (hopefully no longer than 5-10 mins). Although Vultr will report your server as "Running", installation scripts may not have completed. You can check the install status with `tail -f /var/opt/profittrailer/install-in-progress`.

### 3. SSH into server and [configure ProfitTrailer as per the documentation](https://wiki.profittrailer.com/doku.php?id=instructions#create_an_exchange_account_get_your_api_keys).

Notes:
- The bot can be located in `/var/opt/profittrailer`
- You can do this via the command-line with something like `scp ~Downloads/ProfitTrailer/application.properties root@YOUR_SERVER_IP:/var/opt/profittrailer/application.properties`

### 4. Run ProfitTrailer bot

`pm2 start /var/opt/profittrailer/pm2-ProfitTrailer.json`

### 5. Save the current configuration to apply on reboot

`pm2 save && pm2 startup`

## Recommendations

### Disable Root Login

"root" is a standard super-user account; bots attempt to exploit this by bruteforcing the account. Disabling root logins allows you to set up a second login with a username of your choosing.

Disable root logins by setting `DISABLE_ROOT_LOGIN` to `true`. This will set up a new admin login with the same password and ssh-key access as the root account.

By default the username for the name admin account is `admin`, but this can be changed by altering the `ADMIN_USERNAME` variable.

### Disable Password Logins

Passwords can be guessed and bruteforced; bruteforcing an ssh-key is much harder. By disabling password logins, you will only be able to access your VPS with a matching private key. You can disable password logins by setting `DISABLE_PASSWORD_LOGIN` to `true`.

### Change the SSH Port

As highlighted earlier, bots exist to bruteforce access to servers using common defaults. Another default that is abused is the standard SSH port, which is 22. You can change this by chaging the `SSH_PORT` variable to an integer between 1 and 65535. 

### [Set up a firewall](https://my.vultr.com/firewall/)

By setting up a firewall, you can restrict access to particular ports on your VPS. You may optionally also limit access to a particular IP address, meaning only your home/work network can SSH into your server. The simplest configuration would be to allow TCP access on Port 22 (or whichever SSH port you may have assigned in the step above).

### Allocate SWAP memory

If your VPS doesn't have a lot of memory, you can enable SWAP memory by setting `SWAP_ENABLED` to `true`. SWAP will use disk space as memory for your server. By default, the amount of space it allocates is 1gb, but you may change the `SWAP_SIZE` variable to increase/decrease this.

## Additional Information

### Installation time

Installation can take awhile (hopefully no longer than 5-10 mins). Although Vultr will report your server as "Running", installation scripts may not have completed. You can check the install status with `tail -f /var/opt/profittrailer/install-in-progress`.

### Compatibility

This script was created for use on Ubuntu 16.04. I have not tested on any other operating system.

### Support/maintenance

This project was created so that I could spin up a consistent environment for many trading bots with ease. I will introduce changes as I require them for my own needs. I will not be offering support, as there are too many factors to account for (VPS provider, OS + version, technical expertise, etc), which I just don't have the time for.

### License

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org/>
