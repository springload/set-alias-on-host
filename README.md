# set-alias-on-host
`set-alias-on-host.sh` is a bash script to set docker network alias on host machine by overwriting 
host `/etc/hosts` file. It enables domain name resolved on host machine to point to docker container IP. 
Intention of `set-alias-on-host.sh` is to help local development without overhead of configuring host DNS subsystem.

Script is **not** intended to be used on production in any way.

`set-alias-on-host.sh` implemented in a way to work as a docker-compose entrypoint 

## Usage
Script usage
```
set-alias-on-host.sh /path/to/host/machine/etc/hosts/file www.test.domain command-to-start-after
```
docker-compose usage
```
web:
    build:
      context: .
      dockerfile: Dockerfile
    networks:
      fronend:
        aliases:
          - www.web.test  # define alias on docker network
    volumes:
      - "/etc/hosts:/host/etc/hosts"  # for linux based host
      - "/private/etc/hosts:/host/etc/hosts" # for macOS based host
    entrypoint: ["set-route-in-hosts.sh", "/host/etc/hosts", "www.web.test"]
    command: ["nginx", "-g", "daemon off;"]  # your app specific
```