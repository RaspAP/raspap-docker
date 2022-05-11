#FROM balenalib/raspberrypi3:bullseye-20220415
FROM balenalib/raspberrypi3:buster-20220415
WORKDIR /app
RUN install_packages ansible git supervisor
# TODO: use production ansible repo, not my fork
RUN ls -lrt
RUN git clone --single-branch --branch jrcichra/docker https://github.com/jrcichra/raspap-ansible
RUN /bin/bash -c 'cd raspap-ansible && ansible-playbook docker.yaml --connection=local -e skip_systemd=yes  -e hostapd_country_code=US'
RUN mkdir -p /var/run/lighttpd && chmod 777 /var/run/lighttpd
COPY supervisord.conf wpa_supplicant.conf /app/
ENTRYPOINT ["/usr/bin/supervisord","-n","-c","/app/supervisord.conf"]

