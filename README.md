![raspap-docker-repository](https://user-images.githubusercontent.com/229399/111151581-edb7df00-858f-11eb-8e3a-3ac11c3c04b7.png)


# raspap-docker
A community-led docker container for RaspAP

# Usage
```
docker run --name raspap -it -d --privileged --network=host -v /sys/fs/cgroup:/sys/fs/cgroup:ro --cap-add SYS_ADMIN jrcichra/raspap-docker
docker exec -it raspap bash
$ ./setup.sh
docker restart raspap
Web GUI should be accessible on http://localhost by default
```
## Workaround for arm devices
To use this container on arm devices you have to make cgroups writable:
```
docker run --name raspap -it -d --privileged --network=host --cgroupns host -v /sys/fs/cgroup:/sys/fs/cgroup:rw --cap-add SYS_ADMIN jrcichra/raspap-docker
docker exec -it raspap bash
$ ./setup.sh
docker restart raspap
Web GUI should be accessible on http://localhost by default
```
