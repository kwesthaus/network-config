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

ssh $TARGET << EOF
    mkdir /etc/deploy
    mv /etc/config.tar.gz /etc/deploy/config.tar.gz
    cd /etc/deploy
    tar -xvzf config.tar.gz
    rm -r /etc/config
    cp -r /etc/deploy/openwrt/etc/config /etc/
    cd /
    rm -r /etc/deploy
EOF

echo ""
echo "*********************************************************************************"
echo "*                                                                               *"
echo "* don't forget to edit the wifi passwords then run /etc/init.d/network restart! *"
echo "*                                                                               *"
echo "*********************************************************************************"
echo ""

