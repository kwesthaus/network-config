#!/bin/bash

TARGET=homerouter
DEVICE=router_nanopi-r4se

if [[ $(basename "`pwd`") != $DEVICE ]];
then
    echo "must be run in $DEVICE directory, quitting!"
    exit 1
fi

tar -cvzf config.tar.gz ./openwrt/etc/config/
scp -O config.tar.gz $TARGET:/etc/config.tar.gz
rm config.tar.gz

ssh $TARGET << 'EOF'
    mkdir /etc/deploy
    mv /etc/config.tar.gz /etc/deploy/config.tar.gz
    cd /etc/deploy
    tar -xvzf config.tar.gz
    rm -r /etc/config
    cp -r /etc/deploy/openwrt/etc/config /etc/
    cd /
    rm -r /etc/deploy
    #
    # replace secret placeholders
    #
    DDNSPASS=`cat /root/ddns_password`
    sed -i -e "s/option password \'<REDACTED:kylewesthaus>\'/option password \'$DDNSPASS\'/g" /etc/config/ddns
    WGPRIV=`cat /root/homerouter.key`
    sed -i -e "s/option private_key \'<REDACTED:in_wg>\'/option private_key \'$WGPRIV\'/g" /etc/config/network
    WGPSK=`cat /root/homerouter-chirripo.psk`
    sed -i -e "s/option preshared_key \'<REDACTED:wgcli_chirripo>\'/option preshared_key \'$WGPSK\'/g" /etc/config/network
EOF

echo ""
echo "*********************************************************************************"
echo "*                                                                               *"
echo "* don't forget to run /etc/init.d/network restart!                              *"
echo "*                                                                               *"
echo "*********************************************************************************"
echo ""

