FROM balenalib/raspberrypi3:bullseye-20220714
WORKDIR /app
RUN mkdir -p /etc/wpa_supplicant/
COPY wpa_supplicant.conf /etc/wpa_supplicant/
RUN install_packages ansible git supervisor
# Use different git branch for development
#RUN git clone --single-branch --branch jcichra/docker2 https://github.com/jrcichra/raspap-ansible
RUN git clone https://github.com/RaspAP/raspap-ansible
RUN /bin/bash -c 'cd raspap-ansible && ansible-playbook docker.yaml'
RUN mkdir -p /var/run/lighttpd && chmod 777 /var/run/lighttpd
COPY supervisord.conf /app/
ENTRYPOINT ["/usr/bin/supervisord","-n","-c","/app/supervisord.conf"]

