#!/bin/bash

TARGET=homerouter
DEVICE=router_nanopi-r4se

if [[ $(basename "`pwd`") != $DEVICE ]];
then
    echo "must be run in $DEVICE directory, quitting!"
    exit 1
fi

ssh $TARGET << EOF
    rm /etc/config.tar.gz
    cd /etc/
    tar -cvzf config.tar.gz ./config/
EOF

rm -r ./openwrt/etc/from-device
mkdir ./openwrt/etc/from-device
scp -O $TARGET:/etc/config.tar.gz ./openwrt/etc/from-device/config.tar.gz
cd ./openwrt/etc/from-device
tar -xvzf ./config.tar.gz

echo ""
echo ""
echo "***"
echo ""
diff -r ../from-device/config ../config
echo ""
echo "***"
echo ""
echo ""

cd ../../../
rm -r ./openwrt/etc/from-device

ssh $TARGET << EOF
    rm /etc/config.tar.gz
EOF

