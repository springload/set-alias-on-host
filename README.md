# set-alias-on-host
`set-alias-on-host.sh` is a shell script to set docker network alias on host machine by overwriting 
host `/etc/hosts` file. It enables domain name resolved on host machine to point to docker container IP. 
Intention of `set-alias-on-host.sh` is to help local development without overhead of configuring host DNS subsystem.

### !!! Script is not intended to be used on production in any way !!!

`set-alias-on-host.sh` implemented in a way it shall work as a docker-compose entrypoint (optional)

Better use however is as a command before actual web server application command.
So if you run the same service container with some service commands (that doesn't run web server) the 
script will register IP address of the web server container only

## Usage

### !!! Create a backup of your hosts file before you let this script to play with it !!!

Script usage
```
set-alias-on-host.sh /path/to/host/machine/etc/hosts/file www.test.domain command-to-start-after
```

Dockerfile usage
```
ADD https://raw.githubusercontent.com/springload/set-alias-on-host/master/set-alias-on-host.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/set-alias-on-host.sh
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
    # run script first, then your specific web server app
    command: ["set-alias-on-host.sh", "/host/etc/hosts", "www.web.test", "nginx", "-g", "daemon off;"]
```

On MacOs you may need to allow a group write permission for `/private/etc/hosts` file