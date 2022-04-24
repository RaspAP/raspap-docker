#FROM balenalib/raspberrypi3:bullseye-20220415
FROM balenalib/raspberrypi3:buster-20220415
WORKDIR /app
RUN install_packages ansible git supervisor
RUN git clone https://github.com/RaspAP/raspap-ansible
# do this in ansible step instead long-term
#RUN install_packages lighttpd git hostapd dnsmasq iptables-persistent vnstat qrencode php7.3-cgi openvpn wpasupplicant
#RUN install_packages iw wireless-tools vim dhcpcd5
#RUN mkdir -p /var/run/lighttpd && chmod 777 /var/run/lighttpd
#COPY raspap-ansible /app/
RUN ansible-playbook docker.yaml --connection=local
COPY supervisord.conf wpa_supplicant.conf /app/
ENTRYPOINT ["/usr/bin/supervisord","-n","-c","/app/supervisord.conf"]

