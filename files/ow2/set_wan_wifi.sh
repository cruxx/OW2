#!/bin/sh

# usage set_wan_wifi.sh wifi_sta_secret wifi_ap_secret

WIFI_STA_SSID=$(cat $1 | grep ssid)
WIFI_STA_KEY=$(cat $1 | grep key)
WIFI_AP_SSID=$(cat $2 | grep ssid)
WIFI_AP_KEY=$(cat $2 | grep key)
TMP_CFG_PATH="/tmp/config"

NETWRK_TEXT="
config interface 'loopback'
	option ifname 'lo'
	option proto 'static'
	option ipaddr '127.0.0.1'
	option netmask '255.0.0.0'

config globals 'globals'
        option ula_prefix 'fd96:5429:d3dd::/48'

config interface 'wilan'
        option ifname 'eth0'
        option type 'bridge'
	option proto 'static'
	option ipaddr '192.168.241.1'
	option netmask '255.255.255.0'
	option ip6assign '60'

config interface 'wan'
	option proto	'dhcp'
"

WIRELESS_TEXT="
config wifi-device  radio0
	option type     mac80211
#	option channel  11
	option hwmode	11ng
	option path	'platform/ar933x_wmac'
	list ht_capab	SHORT-GI-20
	list ht_capab	SHORT-GI-40
	list ht_capab	RX-STBC1
	list ht_capab	DSSS_CCK-40
	option htmode	HT20
	option txpower	'10'
# REMOVE THIS LINE TO ENABLE WIFI:
#	option disabled 1

config wifi-iface
	option device   'radio0'
	option network  'wan'
	option mode     'sta'
	option encryption 'psk2'
	option $WIFI_STA_SSID
	option $WIFI_STA_KEY

config wifi-iface
	option device   'radio0'
	option network  'wilan'
	option mode     'ap'
	option encryption 'psk2'
	option $WIFI_AP_SSID
	option $WIFI_AP_KEY
"

if [ -d $TMP_CFG_PATH ]; then
	false
else 
	mkdir $TMP_CFG_PATH
fi

#ln -s -b $TMP_CFG_PATH/network /etc/config/network
#ln -s -b $TMP_CFG_PATH/wireless /etc/config/wireless

echo "$NETWRK_TEXT" > $TMP_CFG_PATH/network
echo "$WIRELESS_TEXT" > $TMP_CFG_PATH/wireless
