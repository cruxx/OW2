#!/bin/sh

# usage set_wan_usbmodem.sh 3g_opts wifi_secret

USB_MOD_DEV=$(grep -e 'device' $1)
USB_MOD_APN=$(cat $1 | grep apn)
USB_MOD_UNAME=$(cat $1 | grep username)
USB_MOD_PASSW=$(cat $1 | grep password)

WIFI_SSID=$(cat $2 | grep ssid)
WIFI_KEY=$(cat $2 | grep key)

TMP_CFG_PATH="/tmp/config"

NETWRK_TEXT="
config interface 'loopback'
	option ifname 'lo'
	option proto 'static'
	option ipaddr '127.0.0.1'
	option netmask '255.0.0.0'

config globals 'globals'
	option ula_prefix 'fd73:59f5:25d8::/48'

       
config interface 'wilan'
        option ifname 'eth0'
        option type 'bridge'
	option proto 'static'
	option ipaddr '192.168.241.1'
	option netmask '255.255.255.0'
	option ip6assign '60'

config interface 'wan'
	option proto	'3g'
	option $USB_MOD_DEV
	option $USB_MOD_APN
	option $USB_MOD_UNAME
	option $USB_MOD_PASSW
"

WIRELESS_TEXT="
config wifi-device  radio0
	option type     mac80211
	option channel  11
	option hwmode	11ng
	option path	'platform/ar933x_wmac'
	list ht_capab	SHORT-GI-20
	list ht_capab	SHORT-GI-40
	list ht_capab	RX-STBC1
	list ht_capab	DSSS_CCK-40
	option htmode	HT20
	option txpower	'12'
# REMOVE THIS LINE TO ENABLE WIFI:
#	option disabled 1

config wifi-iface
	option device   'radio0'
	option network  'wilan'
	option mode     'ap'
	option encryption 'psk2'
	option $WIFI_SSID
	option $WIFI_KEY
"

if [ -d $TMP_CFG_PATH ]; then
	false
else 
	mkdir $TMP_CFG_PATH
fi

# if not (ls -l | grep "--> /etc/config") then
#ln -s -b $TMP_CFG_PATH/network /etc/config/network
#ln -s -b $TMP_CFG_PATH/wireless /etc/config/wireless

echo "$NETWRK_TEXT" > $TMP_CFG_PATH/network
echo "$WIRELESS_TEXT" > $TMP_CFG_PATH/wireless

