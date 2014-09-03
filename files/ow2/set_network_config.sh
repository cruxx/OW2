#!/bin/sh

# usage set_network_config.sh settings.pvt [3G,WISP,AP]

TMP_CFG_PATH="/tmp/config"

if [ ! -d $TMP_CFG_PATH ]; then
	mkdir $TMP_CFG_PATH
fi

# function usage: get_option settings.pvt options_section
get_option() { sed -n -e "/^"$2"/!b;n;:x;/^[[:space:]]*option/p;n;/^[[:space:]]*$/b;bx" $1; }

NETWRK_COMMON="
config interface 'loopback'
	option ifname 'lo'
	option proto 'static'
	option ipaddr '127.0.0.1'
	option netmask '255.0.0.0'

config globals 'globals'
        option ula_prefix 'fd96:5429:d3dd::/48'

config interface 'lan'
	option ip6assign '60'
	option proto 'static'
	option netmask '255.255.255.0'
$(get_option $1 lan_options)\n"

if [ "$2" != "AP" ]; then
NETWRK_COMMON=$NETWRK_COMMON"        option type 'bridge'
        option ifname 'eth0'\n"
fi

if [ "$2" = "3G" ]; then 
NETWRK_WAN="
config interface 'wan'
	option proto	'3g'
$(get_option $1 3g_options)\n"
else
NETWRK_WAN="
config interface 'wan'
	option proto	'dhcp'\n"
fi

echo "$NETWRK_COMMON $NETWRK_WAN" > $TMP_CFG_PATH/network

WRLSS_COMMON="
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
	option network  'lan'
	option mode     'ap'
	option encryption 'psk2'
$(get_option $1 ap_wifi_options)\n"

if [ "$2" = "WISP" ]; then
WRLSS_STA="
config wifi-iface
	option device   'radio0'
	option network  'wan'
	option mode     'sta'
	option encryption 'psk2'
$(get_option $1 sta_wifi_options)\n"
fi

echo "$WRLSS_COMMON $WRLSS_STA" > $TMP_CFG_PATH/wireless

if [ ! -h "/etc/config/network" ]; then
ln -s -b $TMP_CFG_PATH/network /etc/config/network
fi

if [ ! -h "/etc/config/wireless" ]; then
ln -s -b $TMP_CFG_PATH/wireless /etc/config/wireless
fi
