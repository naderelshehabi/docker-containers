A great inspiration for the elastic stack deployment is the following repo
https://github.com/elastic/stack-docker

Another updated repo for the same objective is
https://github.com/elastic/stack-docs/tree/master/docs/en/getting-started/docker


# Mounting docker directory for filebeat for Docker Windows Desktop

First, in windows command, you need to run
```
net use h: \\wsl$\docker-desktop-data
``

This will create a network shortcut for the docker data folder that we can use in WSL.

Then create a folder in WSL:
```
sudo mkdir /mnt/docker
```

Finally, mount the network shortcut to the folder we created by adding the folowing line to `/etc/fstab`
```
H: /mnt/docker drvfs defaults 0 0
```

This is used in the `docker-compose` for prometheus stack:
```
- /mnt/docker/version-pack-data/community/docker:/rootfs/var/lib/docker:ro
```

if it's not working automatically for any reason, you can also manually mount the network point using
```
sudo mount -t drvfs h: /mnt/docker -o gid=1001
```