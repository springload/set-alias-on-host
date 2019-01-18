FROM alpine:latest

COPY set-alias-on-host.sh run-in-docker.sh /usr/local/bin/

CMD ["run-in-docker.sh"]