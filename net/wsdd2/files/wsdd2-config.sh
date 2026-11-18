#!/bin/sh
# Shared SMB/ksmbd discovery and CLI argument helper for wsdd2.

wsdd2_find_conf() {
	WS_CONF=""

	if [ -e /etc/ksmbd/ksmbd.conf ] && [ -e /etc/init.d/ksmbd ] && /etc/init.d/ksmbd running; then
		WS_CONF="/etc/ksmbd/ksmbd.conf"
	fi

	if [ -z "$WS_CONF" ] && [ -e /etc/samba/smb.conf ]; then
		if [ -z "${IPKG_INSTROOT:-}" ] && [ -d /run/systemd/system ] &&
		   [ -f /usr/lib/systemd/system/samba4.service ]; then
			if systemctl is-active --quiet samba4.service; then
				WS_CONF="/etc/samba/smb.conf"
			fi
		elif [ -e /etc/init.d/samba4 ] && /etc/init.d/samba4 running; then
			WS_CONF="/etc/samba/smb.conf"
		elif [ -e /etc/init.d/samba ] && /etc/init.d/samba running; then
			WS_CONF="/etc/samba/smb.conf"
		fi
	fi

	[ -n "$WS_CONF" ]
}

wsdd2_resolve_params() {
	local smb_conf nb_name nb_option wg_name
	local board_vendor board_model board_sku

	WS_NB="$(sed 's/\..*//' /proc/sys/kernel/hostname)"
	WS_WG="WORKGROUP"
	WS_BI=""
	WS_IFNAME=""

	smb_conf="$(grep '^[[:blank:]]*[^[:blank:]#;]' "$WS_CONF")"

	nb_name="$(echo "$smb_conf" | grep -i 'netbios name' | awk -F'=' '{print $2}' | tr -d ' \n')"
	[ -n "$nb_name" ] && WS_NB="$nb_name"

	# use uppercase for none mdns option
	nb_option="$(echo "$smb_conf" | grep -i 'mdns name' | awk -F'=' '{print $2}' | tr -d ' \n')"
	[ "$nb_option" != "mdns" ] && WS_NB="$(echo "$WS_NB" | awk '{print toupper($0)}')"

	wg_name="$(echo "$smb_conf" | grep -i 'workgroup' | awk -F'=' '{print $2}' | tr -d ' \n')"
	[ -n "$wg_name" ] && WS_WG="$wg_name"

	. /lib/functions.sh
	. /lib/functions/network.sh
	network_get_device WS_IFNAME lan

	[ -e /tmp/sysinfo/board_name ] && {
		board_vendor="$(awk -F',' '{print $1}' /tmp/sysinfo/board_name | tr ' ' '_' | tr ',' '-' | tr -d ' \n')"
		board_sku="$(awk -F',' '{print $2}' /tmp/sysinfo/board_name | tr ' ' '_' | tr ',' '-' | tr -d ' \n')"
	}

	[ -e /tmp/sysinfo/model ] && {
		board_model="$(awk -F':' '{print $1}' /tmp/sysinfo/model | tr ' ' '_' | tr ',' '-' | tr -d ' \n')"
	}

	[ -n "$board_vendor" ] && [ -n "$board_model" ] && {
		if [ -n "$board_sku" ]; then
			WS_BI="vendor:$board_vendor,model:$board_model,sku:$board_sku"
		else
			WS_BI="vendor:$board_vendor,model:$board_model"
		fi
	}
}
