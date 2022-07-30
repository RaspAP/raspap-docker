![raspap-docker-repository](https://user-images.githubusercontent.com/229399/111151581-edb7df00-858f-11eb-8e3a-3ac11c3c04b7.png)


# raspap-docker
A community-led docker container for RaspAP

# Usage
Copy `dhcpcd.conf` over your `/etc/dhcpcd.conf` file. We're using the `dhcpcd` binary on the host system, but disabling it from managing `wpa_supplicant`. `wpa_supplicant` is managed inside the RaspAP container.
`docker run --name raspap -it -d --privileged jrcichra/raspap-docker`

The Web GUI should be accessible on http://localhost with the default credentials.

# Known issues
+ No persistence, so settings will be lost if the container is destroyed.
+ The default install configuration works, but many options may not. The container does not run systemd.

