# raspap-docker
A community-led docker container for RaspAP

# Usage
```
docker run --name raspap -it -d --privileged --network=host -v /sys/fs/cgroup:/sys/fs/cgroup:ro --cap-add SYS_ADMIN billz/raspap-docker
docker exec -it raspap bash
$ ./setup.sh
docker restart raspap
Web GUI should be accessible on http://localhost by default
```
