#!/usr/bin/env bash
#####################################################
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by cryptopool.builders for crypto use...
#####################################################

source /etc/functions.sh
source /etc/multipool.conf

message_box "Ultimate Crypto-Server NOMP Installer" \
"You have choosen to install NOMP Single Server!
\n\nThis will install NOMP and help setup your first coin for the server.
\n\n
\n\nAfter answering the following questions, setup will be mostly automated, until the coin build.
\n\nNOTE: If installing on a system with less then 2 GB of RAM you may experience system issues!"


# Begin user inputted responses for auto install

dialog --title "Using Domain Name" \
--yesno "Are you using a domain name? Example: example.com?
Make sure the DNS is updated!" 7 60
response=$?
case $response in
   0) UsingDomain=yes;;
   1) UsingDomain=no;;
   255) echo "[ESC] key pressed.";;
esac

if [[ ("$UsingDomain" == "yes") ]]; then

dialog --title "Using Sub-Domain" \
--yesno "Are you using a sub-domain for the main website domain? Example pool.example.com?
Make sure the DNS is updated!" 7 60
response=$?
case $response in
   0) UsingSubDomain=yes;;
   1) UsingSubDomain=no;;
   255) echo "[ESC] key pressed.";;
esac

if [ -z "${DomainName:-}" ]; then
DEFAULT_DomainName=example.com
input_box "Domain Name" \
"Enter your domain name. If using a subdomain enter the full domain as in pool.example.com
\n\nDo not add www. to the domain name.
\n\nMake sure the domain is pointed to this server before continuing!
\n\nDomain Name:" \
${DEFAULT_DomainName} \
DomainName

if [ -z "${DomainName}" ]; then
# user hit ESC/cancel
exit
fi
fi

if [ -z "${StratumURL:-}" ]; then
DEFAULT_StratumURL=stratum.${DomainName}
input_box "Stratum URL" \
"Enter your stratum URL. It is recommended to use another subdomain such as stratum.${DomainName}
\n\nDo not add www. to the domain name.
\n\nStratum URL:" \
${DEFAULT_StratumURL} \
StratumURL

if [ -z "${StratumURL}" ]; then
# user hit ESC/cancel
exit
fi
fi

dialog --title "Install SSL" \
--yesno "Would you like the system to install SSL automatically?" 7 60
response=$?
case $response in
   0) InstallSSL=yes;;
   1) InstallSSL=no;;
   255) echo "[ESC] key pressed.";;
esac
else

# If user is not using a domain and is just using the server IP these fileds can be automatically detected.

# Sets server IP automatically
DomainName=$(get_publicip_from_web_service 4 || get_default_privateip 4)
StratumURL=$(get_publicip_from_web_service 4 || get_default_privateip 4)
UsingSubDomain=no
InstallSSL=no
fi

if [ -z "$AdminPass" ]; then
DEFAULT_AdminPass=$(openssl rand -base64 8 | tr -d "=+/")
input_box "Admin Password" \
"Enter your new Admin password or use this randomly system generated one.
\n\nUnfortunatley dialog doesnt let you copy. So you have to write it down.
\n\nAdmin password:" \
$DEFAULT_AdminPass \
AdminPass

if [ -z "$AdminPass" ]; then
# user hit ESC/cancel
exit
fi
fi

if [ -z "$SupportEmail" ]; then
DEFAULT_SupportEmail=root@localhost
input_box "System Email" \
"Enter an email address for the system to send alerts and other important messages.
\n\nSystem Email:" \
$DEFAULT_SupportEmail \
SupportEmail

if [ -z "$SupportEmail" ]; then
# user hit ESC/cancel
exit
fi
fi

# Get the coind info they want to build during install.

if [ -z "$coinname" ]; then
DEFAULT_coinname=Bitcoin
input_box "Coin Name" \
"Enter your first coins name..
\n\nCoin Name:" \
$DEFAULT_coinname \
coinname

if [ -z "$coinname" ]; then
# user hit ESC/cancel
exit
fi
fi

if [ -z "$coinrepo" ]; then
DEFAULT_coinrepo="github"
input_box "Default Coin Repo" \
"Enter your coins repo to use..
\n\nIf you are using a private repo and do not specify the user name and password here, you will be promted
\n\nfor it during the installation. Instalaltion will not continue until you enter that information.
\n\nWhen pasting your link CTRL+V does NOT work, you must either SHIFT+RightMouseClick or SHIFT+INSERT!!
\n\nDefault Coin Repo:" \
$DEFAULT_coinrepo \
coinrepo

if [ -z "$coinrepo" ]; then
# user hit ESC/cancel
exit
fi
fi

if [ -z "$coinsymbol" ]; then
DEFAULT_coinsymbol=BTC
input_box "Coin Symbol" \
"Enter your coins symbol..
\n\nCoin Symbol:" \
$DEFAULT_coinsymbol \
coinsymbol

if [ -z "$coinsymbol" ]; then
# user hit ESC/cancel
exit
fi
fi

if [ -z "$coinalgo" ]; then
DEFAULT_coinalgo=sha256
input_box "Coin Algorithm" \
"Enter your coins algorithm.. Enter as all lower case...
\n\nCoin Algorithm:" \
$DEFAULT_coinalgo \
coinalgo

if [ -z "$coinalgo" ]; then
# user hit ESC/cancel
exit
fi
fi

if [ -z "$cointime" ]; then
DEFAULT_cointime=120
input_box "Coin Block Time" \
"Enter your coins block time in seconds..
\n\nCoin Block Time:" \
$DEFAULT_cointime \
cointime

if [ -z "$cointime" ]; then
# user hit ESC/cancel
exit
fi
fi

RESULT=$(dialog --stdout --title "Select the correct build option below" --menu "Choose one" -1 60 4 \
1 "Build coin with Berkeley 4.x" \
2 "Build coin with Berkeley 5.x" \
3 "Build coin with makefile.unix" \
4 Exit)
if [ $RESULT = ]
then
exit ;
fi

if [ $RESULT = 1 ]
then
clear;
echo '
autogen=true
berkeley="4.8"
' | sudo -E tee $HOME/multipool/daemon_builder/.first_build.cnf >/dev/null 2>&1;
fi

if [ $RESULT = 2 ]
then
clear;
echo '
autogen=true
berkeley="5.3"
' | sudo -E tee $HOME/multipool/daemon_builder/.first_build.cnf >/dev/null 2>&1;
fi

if [ $RESULT = 3 ]
then
clear;
echo '
autogen=false
' | sudo -E tee $HOME/multipool/daemon_builder/.first_build.cnf >/dev/null 2>&1;
fi

if [ $RESULT = 4 ]
then
clear;
exit;
fi

# Save the global options in $STORAGE_ROOT/yiimp/.yiimp.conf so that standalone
# tools know where to look for data.
echo 'STORAGE_USER='"${STORAGE_USER}"'
STORAGE_ROOT='"${STORAGE_ROOT}"'
PRIMARY_HOSTNAME='"${DomainName}"'

UsingDomain='"${UsingDomain}"'
UsingSubDomain='"${UsingSubDomain}"'
DomainName='"${DomainName}"'
StratumURL='"${StratumURL}"'
InstallSSL='"${InstallSSL}"'
SupportEmail='"${SupportEmail}"'
AdminPass='"'"''"${AdminPass}"''"'"'

coinname='"'"''"${coinname}"''"'"'
coinsymbol='"'"''"${coinsymbol}"''"'"'
coinalgo='"'"''"${coinalgo}"''"'"'
cointime='"'"''"${cointime}"''"'"'
coinrepo='"'"''"${coinrepo}"''"'"'

# Unless you do some serious modifications this installer will not work with any other repo of nomp!
' | sudo -E tee $STORAGE_ROOT/nomp/.nomp.conf >/dev/null 2>&1

cd $HOME/multipool/nomp
