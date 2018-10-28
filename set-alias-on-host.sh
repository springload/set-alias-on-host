#!/usr/bin/env sh

HOST_FILE=$1
HOST_ALIAS=$2
shift 2  # remove first two script parameters
TMP_FILE=/tmp/host-hosts
if [ ! -f "${HOST_FILE}" ] ; then
    echo "Host \"${HOST_FILE}\" file doesn't exists"
    exit 2
fi

if [ -z "${HOST_ALIAS}" ] ; then
    echo "HOST_ALIAS not set"
    exit 1
fi

HOST_ENTRY=$(getent hosts ${HOST_ALIAS} | awk '{ print $1"\t"$2 }') # get alias IP
if [ -z "${HOST_ENTRY}" ]; then
    echo "Can't find IP for ${HOST_ALIAS}"
    exit 3
fi

# using tmp file and cat > because docker volume mount doesn't allow file replace
cat ${HOST_FILE} | grep -Fv "${HOST_ALIAS}" > ${TMP_FILE} # remove all lines with host alias
echo "${HOST_ENTRY}" >> /tmp/hosts  # add new host alias entry to the end of the file
cat ${TMP_FILE} > ${HOST_FILE};  # replace content of the host hosts file
rm ${TMP_FILE}
echo "${HOST_ENTRY} entry added to hosts file"

exec "$@"
