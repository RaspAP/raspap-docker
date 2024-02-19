#!/bin/bash
declare -A aliases=(
    [RASPAP_SSID]=RASPAP_hostapd_ssid
    [RASPAP_SSID_PASS]=RASPAP_hostapd_wpa_passphrase
    [RASPAP_COUNTRY]=RASPAP_hostapd_country_code
)

# Files that follow a predictable key=value format
declare -A conf_files=(
    [raspap]=/etc/dnsmasq.d/090_raspap.conf
    [wlan0]=/etc/dnsmasq.d/090_wlan0.conf
    [hostapd]=/etc/hostapd/hostapd.conf
)

raspap_auth=/etc/raspap/raspap.auth
lighttpd_conf=/etc/lighttpd/lighttpd.conf

function main() {
    alias_env_vars
    update_webgui_auth $RASPAP_WEBGUI_USER $RASPAP_WEBGUI_PASS
    update_webgui_port $RASPAP_WEBGUI_PORT
    update_confs
}

function alias_env_vars() {
    for alias in "${!aliases[@]}"
    do
        if [ ! -z "${!alias}" ]
        then
            declare -g ${aliases[$alias]}="${!alias}"
            export ${aliases[$alias]}
        fi
    done
}

# $1 - Username
# $2 - Password
function update_webgui_auth() {
    declare user=$1
    declare pass=$2
    if [ -z $user ]
    then
        # If not set, keep existing value
        user=$(head $raspap_auth -n+1)
    fi

    if [ -z "${pass}" ]
    then
        # If not set, keep existing value
        pass=$(tail $raspap_auth -n+2)
    else
        # Hash password
        pass=$(php /home/password-generator.php ${pass})
    fi

    echo "$user" > "$raspap_auth"
    echo "$pass" >> "$raspap_auth"
}

# $1 - Port
function update_webgui_port() {
    port=$1
    if [ ! -z "${!port}" ]
    then
        # Only update if env var is set
        return
    fi
    old="server.port                 = [0-9]*"
    new="server.port                 = ${port}"
    sudo sed -i "s/$old/$new/g" ${lighttpd_conf}
}

update_confs() {
    for conf in "${!conf_files[@]}"
    do
        path=${conf_files[$conf]}
        prefix=RASPAP_${conf}_
        vars=$(get_prefixed_env_vars ${prefix})
        for var in ${vars}
        do
            key=${var#"$prefix"}
            replace_in_conf $key ${!var} $path
        done
    done
}

# $1 - Prefix
function get_prefixed_env_vars() {
    prefix=$1
    matches=$(printenv | grep -o "${prefix}[^=]*")
    echo $matches
}

# $1 - Target key
# $2 - New value
# $3 - conf path
function replace_in_conf() {
    key=$1
    val=$2
    path=$3

    old="$key"=".*"
    new="$key"="$val"

    if [ -z "$(grep "$old" $path)" ]
    then
        # Add value
        echo $new >> $path
    else
        # Value exists in conf
        sudo sed -i "s/$old/$new/g" $path
    fi
}

main
