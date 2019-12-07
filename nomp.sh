#!/usr/bin/env bash
#####################################################
# Created by cryptopool.builders for crypto use...
#####################################################

source /etc/functions.sh
source /etc/multipool.conf
source $STORAGE_ROOT/nomp/.nomp.conf

# Create function for random unused port
function EPHYMERAL_PORT(){
    LPORT=32768;
    UPORT=60999;
    while true; do
        MPORT=$[$LPORT + ($RANDOM % $UPORT)];
        (echo "" >/dev/tcp/127.0.0.1/${MPORT}) >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo $MPORT;
            return 0;
        fi
    done
}

echo -e " Making the NOMPness Monster...$COL_RESET"
echo -e " Script will seem to hang for several minutes...$COL_RESET"
cd $STORAGE_ROOT/nomp/core/

# NPM install and update, user can ignore errors
npm install >/dev/null 2>&1
echo -e " Still working on it...$COL_RESET"
npm update >/dev/null 2>&1
echo -e " Almost done...$COL_RESET"
npm i npm@latest -g >/dev/null 2>&1
echo -e " Almost there...$COL_RESET"
npm install -g pm2@latest >/dev/null 2>&1
echo -e " Are we there yet...$COL_RESET"
npm install -g npm@latest >/dev/null 2>&1
echo -e " We have successfully hacked the NSA using this server...$COL_RESET"
echo -e " Just kidding, we hacked the White House...$COL_RESET"

# SED config file
sudo sed -i 's/domain_name/'$Domain_Name'/g' $STORAGE_ROOT/nomp/configuration/config.json
sudo sed -i 's/Stratum_URL/'$Stratum_URL'/g' $STORAGE_ROOT/nomp/configuration/config.json
sudo sed -i 's/PASSWORD/'$Admin_Pass'/g' $STORAGE_ROOT/nomp/configuration/config.json
sudo sed -i 's/coin_name/'$coin_name'/g' $STORAGE_ROOT/nomp/configuration/config.json

# Create the coin json file
sudo cp -r $STORAGE_ROOT/nomp/configuration/pool_configs/base_samp.json.x $STORAGE_ROOT/nomp/configuration/pool_configs/$coin_name.json

# Generate our random ports
randportlow=$(EPHYMERAL_PORT)
randportvar=$(EPHYMERAL_PORT)
randporthigh=$(EPHYMERAL_PORT)

# Generate new wallet address
if [[ ("$ifcoincli" == "y" || "$ifcoincli" == "Y") ]]; then
wallet="$("${coind::-1}-cli" -datadir=$STORAGE_ROOT/wallets/."${coind::-1}" -conf="${coind::-1}.conf" getnewaddress)"
else
wallet="$("${coind}" -datadir=$STORAGE_ROOT/wallets/."${coind::-1}" -conf="${coind::-1}.conf" getnewaddress)"
fi

# SED the pool_config with our variables.
sudo sed -i 's/coin_name/'$coin_name'/g' $STORAGE_ROOT/nomp/configuration/pool_configs/$coin_name.json
sudo sed -i 's/wallet/'$wallet'/g' $STORAGE_ROOT/nomp/configuration/pool_configs/$coin_name.json
sudo sed -i 's/daemon_port/'$rpc_port'/g' $STORAGE_ROOT/nomp/configuration/pool_configs/$coin_name.json
sudo sed -i 's/rpc_user/NOMPrpc/g' $STORAGE_ROOT/nomp/configuration/pool_configs/$coin_name.json
sudo sed -i 's/rpc_pass/'$rpc_password'/g' $STORAGE_ROOT/nomp/configuration/pool_configs/$coin_name.json
sudo sed -i 's/rand_port_low/'$rand_port_low'/g' $STORAGE_ROOT/nomp/configuration/pool_configs/$coin_name.json
sudo sed -i 's/rand_port_var/'$rand_port_var'/g' $STORAGE_ROOT/nomp/configuration/pool_configs/$coin_name.json
sudo sed -i 's/rand_port_high/'$rand_port_high'/g' $STORAGE_ROOT/nomp/configuration/pool_configs/$coin_name.json

# Change to the coins config folder and SED those with our variables.
sudo cp -r $STORAGE_ROOT/nomp/configuration/coins/default.json $STORAGE_ROOT/nomp/configuration/coins/$coin_name.json
sudo sed -i 's/coin_name/'$coin_name'/g' $STORAGE_ROOT/nomp/configuration/coins/$coin_name.json
sudo sed -i 's/coin_symbol/'$coin_symbol'/g' $STORAGE_ROOT/nomp/configuration/coins/$coin_name.json
sudo sed -i 's/coin_algo/'$coin_algo'/g' $STORAGE_ROOT/nomp/configuration/coins/$coin_name.json
sudo sed -i 's/get_block_api/'$get_block_api'/g' $STORAGE_ROOT/nomp/configuration/coins/$coin_name.json
sudo sed -i 's/block_explorer/'$block_explorer'/g' $STORAGE_ROOT/nomp/configuration/coins/$coin_name.json
sudo sed -i 's/get_block_tx/'$get_block_tx'/g' $STORAGE_ROOT/nomp/configuration/coins/$coin_name.json
sudo sed -i 's/coin_time/'$coin_time'/g' $STORAGE_ROOT/nomp/configuration/coins/$coin_name.json

# SED the website files with our variables.
sudo sed -i 's/sed_domain/'$Domain_Name'/g' $STORAGE_ROOT/nomp/site/web/index.html
sudo sed -i 's/sed_domain/'$Domain_Name'/g' $STORAGE_ROOT/nomp/site/web/pages/dashboard.html
sudo sed -i 's/sed_stratum/'$Stratum_URL'/g' $STORAGE_ROOT/nomp/site/web/pages/getting_started.html
sudo sed -i 's/sed_domain/'$Domain_Name'/g' $STORAGE_ROOT/nomp/site/web/pages/home.html
sudo sed -i 's/sed_stratum/'$Stratum_URL'/g' $STORAGE_ROOT/nomp/site/web/pages/pools.html

echo -e "$GREEN Done with the NOMP...$COL_RESET"
cd $HOME/multipool/nomp
