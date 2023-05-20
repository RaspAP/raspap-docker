# Base image
FROM debian:latest

RUN debian_frontend=noninteractive

USER root
RUN  echo 'iptables-persistent iptables-persistent/autosave_v4 boolean true' |  debconf-set-selections
RUN  echo 'iptables-persistent iptables-persistent/autosave_v6 boolean true' |  debconf-set-selections


# Update the system
RUN apt-get update && apt-get upgrade -y

# Install dependencies
RUN apt-get install -y \
    git \
    lighttpd \
    php7.4-cgi \
    hostapd \
    dnsmasq \
    vnstat \
    qrencode \
    dhcpcd5 -y \
    iptables-persistent



# Enable PHP for lighttpd
RUN lighttpd-enable-mod fastcgi-php

# Clone RaspAP repository
RUN git clone https://github.com/RaspAP/raspap-webgui /var/www/html/raspap-webgui

# Copy additional lighttpd config file
COPY raspap-webgui/config/50-raspap-router.conf /etc/lighttpd/conf-available/50-raspap-router.conf
RUN ln -s /etc/lighttpd/conf-available/50-raspap-router.conf /etc/lighttpd/conf-enabled/50-raspap-router.conf

# Set up configuration directories
RUN mkdir /etc/raspap/
RUN mkdir /etc/raspap/backups
RUN mkdir /etc/raspap/networking
RUN mkdir /etc/raspap/hostapd
RUN mkdir /etc/raspap/lighttpd

# Copy auth control file
RUN cp /var/www/html/raspap-webgui/raspap.php /etc/raspap/

# Set file ownership
RUN chown -R www-data:www-data /var/www/html
RUN chown -R www-data:www-data /etc/raspap

# Move control scripts
RUN mv /var/www/html/raspap-webgui/installers/*log.sh /etc/raspap/hostapd
RUN mv /var/www/html/raspap-webgui/installers/service*.sh /etc/raspap/hostapd
RUN chown -c root:www-data /etc/raspap/hostapd/*.sh
RUN chmod 750 /etc/raspap/hostapd/*.sh

# Copy default configurations
COPY raspap-webgui/config/hostapd.conf /etc/default/hostapd
COPY raspap-webgui/config/hostapd.conf /etc/hostapd/hostapd.conf
COPY raspap-webgui/config/090_raspap.conf /etc/dnsmasq.d/090_raspap.conf
COPY raspap-webgui/config/090_wlan0.conf /etc/dnsmasq.d/090_wlan0.conf
COPY raspap-webgui/config/dhcpcd.conf /etc/dhcpcd.conf
COPY raspap-webgui/config/config.php /var/www/html/includes/
COPY raspap-webgui/config/defaults.json /etc/raspap/networking/

# Enable IP forwarding
RUN #mkdir /etc/sysctl.d/
RUN #echo "net.ipv4.ip_forward=1" >> /etc/sysctl.d/90_raspap.conf
#RUN sysctl -p /etc/sysctl.d/90_raspap.conf
RUN #/etc/init.d/procps restart
USER root

# Set up iptables masquerade rules
#RUN iptables -t nat -git
# Enable hostapd service
RUN echo "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"" >> /etc/default/hostapd

# Expose port 80
EXPOSE 80

# Start lighttpd service
CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
