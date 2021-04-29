FROM debian:buster

RUN apt-get update && apt-get -y install \
    iw \
    sudo \
    procps \
    rfkill \
    net-tools \
    wpasupplicant \
    wireless-tools

RUN apt-get -y install \
    git \
    vnstat \
    dhcpcd5 \
    hostapd \
    dnsmasq \
    lighttpd \
    qrencode \
    php7.3-cgi && \
    rm -rf /var/lib/apt/lists/*

RUN rm -rf /var/www/html && \
    git clone --depth 1 -b 2.6.5 https://github.com/billz/raspap-webgui /var/www/html

#RUN awk "{gsub(\"/REPLACE_ME\",\"/var/www/html\")}1" /var/www/html/config/50-raspap-router.conf > /tmp/50-raspap-router.conf && \
#    mv /tmp/50-raspap-router.conf /etc/lighttpd/conf-available/

RUN lighttpd-enable-mod fastcgi-php && \
#    ln -s /etc/lighttpd/conf-available/50-raspap-router.conf /etc/lighttpd/conf-enabled/50-raspap-router.conf && \
    /etc/init.d/lighttpd restart

RUN cp /var/www/html/installers/raspap.sudoers /etc/sudoers.d/090_raspap

#    mv /var/www/html/app/icons/* /var/www/html && \
#    chown -R www-data:www-data /var/www/html && \

WORKDIR /var/www/html

RUN mkdir /etc/raspap /etc/raspap/backups /etc/raspap/networking /etc/raspap/hostapd /etc/raspap/lighttpd && \
#    cat /etc/dhcpcd.conf | sudo tee -a /etc/raspap/networking/defaults > /dev/null && \
    cp raspap.php /etc/raspap/ && \
    chown -R www-data:www-data /etc/raspap && \
    chown -R www-data:www-data /var/www/html

RUN mv installers/*log.sh /etc/raspap/hostapd && \
    mv installers/service*.sh /etc/raspap/hostapd && \
    cp installers/configport.sh /etc/raspap/lighttpd && \
    chown -c root:www-data /etc/raspap/hostapd/*.sh /etc/raspap/lighttpd/*.sh && \
    chmod 750 /etc/raspap/hostapd/*.sh

RUN mv config/hostapd.conf /etc/hostapd/hostapd.conf && \
    mv config/090_raspap.conf /etc/dnsmasq.d/090_raspap.conf && \
    mv config/090_wlan0.conf /etc/dnsmasq.d/090_wlan0.conf && \
    mv config/dhcpcd.conf /etc/dhcpcd.conf && \
    mv config/config.php /var/www/html/includes/ && \
    mv config/defaults.json /etc/raspap/networking/

# TODO sed /etc/hostapd/hostapd.conf
# TODO sed /etc/dhcpcd.conf for pihole?
# TODO sed -i "s/^\(server\.port *= *\)[0-9]*/\1$server_port/g" "$lighttpd_conf"  # to change port (capa NBS)

RUN sed -i -E 's/^session\.cookie_httponly\s*=\s*(0|([O|o]ff)|([F|f]alse)|([N|n]o))\s*$/session.cookie_httponly = 1/' /etc/php/7.3/cgi/php.ini && \
    sed -i -E 's/^;?opcache\.enable\s*=\s*(0|([O|o]ff)|([F|f]alse)|([N|n]o))\s*$/opcache.enable = 1/' /etc/php/7.3/cgi/php.ini && \
    phpenmod opcache

ENTRYPOINT [ "lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf" ]
