#!/bin/sh
# Shared configuration parser for nlbwmon.

nlbwmon_append() {
	NLBWMON_ARGS="$NLBWMON_ARGS $*"
}

nlbwmon_add_subnet() {
	local network="$1"
	local range ranges

	case "$network" in
		*.*|*:*)
			nlbwmon_append -s "$network"
		;;
		*)
			if network_get_subnets ranges "$network"; then
				for range in $ranges; do
					nlbwmon_append -s "$range"
				done
			fi

			if network_get_subnets6 ranges "$network"; then
				for range in $ranges; do
					nlbwmon_append -s "$range"
				done
			fi
		;;
	esac
}

nlbwmon_add_option() {
	local cfg="$1"
	local flag="$2"
	local option="$3"
	local default="$4"
	local value

	config_get value "$cfg" "$option" "$default"
	[ -n "$value" ] && nlbwmon_append "$flag" "$value"
}

nlbwmon_add_bool() {
	local cfg="$1"
	local flag="$2"
	local option="$3"
	local default="$4"
	local value

	config_get_bool value "$cfg" "$option" "$default"
	[ "$value" -eq 1 ] && nlbwmon_append "$flag"
}

nlbwmon_parse_section() {
	local cfg="$1"
	local dir

	config_get dir "$cfg" database_directory /var/lib/nlbwmon

	mkdir -p "$dir"
	nlbwmon_append -o "$dir"

	nlbwmon_add_option "$cfg" -b netlink_buffer_size 524288
	nlbwmon_add_option "$cfg" -i commit_interval 24h
	nlbwmon_add_option "$cfg" -r refresh_interval 30s
	nlbwmon_add_option "$cfg" -p protocol_database /usr/share/nlbwmon/protocols
	nlbwmon_add_option "$cfg" -G database_generations 10
	nlbwmon_add_option "$cfg" -I database_interval 1
	nlbwmon_add_option "$cfg" -L database_limit 10000

	nlbwmon_add_bool "$cfg" -P database_prealloc 0
	nlbwmon_add_bool "$cfg" -Z database_compress 1

	config_list_foreach "$cfg" local_network nlbwmon_add_subnet
}

nlbwmon_resolve_args() {
	. /lib/functions.sh
	. /lib/functions/network.sh
	NLBWMON_ARGS=""
	config_load nlbwmon
	config_foreach nlbwmon_parse_section nlbwmon
}

nlbwmon_match_network() {
	case "$1" in
		*.*|*:*) ;;
		"$requested_interface") interface_selected=1 ;;
	esac
}

nlbwmon_match_section() {
	config_list_foreach "$1" local_network nlbwmon_match_network
}

nlbwmon_match_dhcp() {
	local interface ignore
	config_get interface "$1" interface
	config_get_bool ignore "$1" ignore 0
	[ "$ignore" -eq 0 ] && [ "$interface" = "$requested_interface" ] && interface_selected=1
}

nlbwmon_interface_selected() {
	requested_interface="$1"
	interface_selected=0
	. /lib/functions.sh
	config_load nlbwmon
	config_foreach nlbwmon_match_section nlbwmon
	if [ "$interface_selected" -ne 1 ]; then
		config_load dhcp
		config_foreach nlbwmon_match_dhcp dhcp
	fi
	[ "$interface_selected" -eq 1 ]
}
