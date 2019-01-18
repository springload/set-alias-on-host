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
set-alias-on-host.sh /path/to/host/machine/etc/hosts/file www.test.domain optimal-command-to-start-after
```

### Docker setup

Add script to your docker image 

Dockerfile example
```
ADD https://raw.githubusercontent.com/springload/set-alias-on-host/master/set-alias-on-host.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/set-alias-on-host.sh
```

#### Option 1:

docker-compose example within the same container as your service
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

#### Option 2:

create service to run set-alias-on-host script for all services of interest

full docker-compose example
```
version: '3.7'

services:
  set_host_alias:
    image: springload/set-alias-on-host
    volumes:
      - "/etc/hosts:/host/etc/hosts"
    environment:
      HOST_ALIAS: "db.web.test www.web.test"  # separate aliases by space or comma
    depends_on:
      - database   # database has to be running to find IP for db.web.test
      - webserver  # webserver has to be running to find IP for www.web.test
    networks:
      web:
        # container has to have access to proper network
      
  database:
    image: postgres
    volumes:
      - "./database/initial-scripts:/docker-entrypoint-initdb.d/:ro"
    environment:
      POSTGRES_DB "user"
      POSTGRES_USER "postgres"
      POSTGRES_PASSWORD "public-secret"
    networks:
      web:
        aliases:
          - db.web.test  # set service alias 
          
  webserver:
    build:
      context: .  
      dockerfile: Dockerfile
    depends_on:
      - database
    networks:
      web:
        aliases:
          - www.web.test  # set service alias

networks:
  web:
    # define network to be able to set host aliases

```

> On MacOs you may need to allow a group write permission for `/private/etc/hosts` file

Start your project with `docker-compose up` and you should see message similar to 
> www.web.test entry added to hosts file

Check your system `hosts` file for new entry for `www.web.test` domain
Access your service wia `www.web.test` domain in your local browser