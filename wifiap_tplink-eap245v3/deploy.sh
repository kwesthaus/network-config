#!/bin/bash

TARGET=homewifiap
DEVICE=wifiap_tplink-eap245v3

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
    TRUSTED=`cat /root/wifi-trusted_password`
    sed -i -e "s/option key \'<REDACTED:trusted>\'/option key \'$TRUSTED\'/1" /etc/config/wireless
    GUEST=`cat /root/wifi-guest_password`
    sed -i -e "s/option key \'<REDACTED:guest>\'/option key \'$GUEST\'/1" /etc/config/wireless
    IOT=`cat /root/wifi-iot_password`
    sed -i -e "s/option key \'<REDACTED:iot>\'/option key \'$IOT\'/1" /etc/config/wireless
EOF

echo ""
echo "*********************************************************************************"
echo "*                                                                               *"
echo "* don't forget to run /etc/init.d/network restart!                              *"
echo "*                                                                               *"
echo "*********************************************************************************"
echo ""

