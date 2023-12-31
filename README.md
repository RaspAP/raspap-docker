![raspap-docker-repository](https://user-images.githubusercontent.com/229399/111151581-edb7df00-858f-11eb-8e3a-3ac11c3c04b7.png)

# raspap-docker

A community-led docker container for RaspAP

## Setting up using Docker

### Debian 12

1. Start the container with `ghcr.io/raspap/raspap-docker:bookworm` image

```
docker run --name raspap -it -d --privileged --network=host -v /sys/fs/cgroup:/sys/fs/cgroup:rw --cap-add SYS_ADMIN ghcr.io/raspap/raspap-docker:bookworm
```

2. Enter the container

```
docker exec -it raspap bash
```

3. Change user to raspap

```
su raspap && cd ~
```

4. Run the script

```
curl -sL https://install.raspap.com | bash
```

5. Restart the container after installation

```
docker restart raspap
```

6. Web GUI should be accessible on [http://localhost](http://localhost) by default

### Debian 11

1. Start the container with `ghcr.io/raspap/raspap-docker:bullseye` image

```
docker run --name raspap -it -d --privileged --network=host -v /sys/fs/cgroup:/sys/fs/cgroup:rw --cap-add SYS_ADMIN ghcr.io/raspap/raspap-docker:bullseye
```

2. Enter the container

```
docker exec -it raspap bash
```

3. Change user to raspap

```
su raspap && cd ~
```

4. Run the script

```
curl -sL https://install.raspap.com | bash
```

5. Restart the container after installation

```
docker restart raspap
```

6. Web GUI should be accessible on [http://localhost](http://localhost) by default
