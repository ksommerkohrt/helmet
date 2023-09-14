#!/usr/bin/env bash
set -e

if [[ -z "$HOST_UID" ]]; then
    echo "ERROR: please set HOST_UID" >&2
    exit 1
fi

if [[ -z "$HOST_GID" ]]; then
    echo "ERROR: please set HOST_GID" >&2
    exit 1
fi

if [ "$RUN_VNC" = true ] ; then
  /opt/TurboVNC/bin/vncserver -geometry 1920x1080 -name dream -xstartup /bin/openbox-session :20
fi

if [ "$RUN_ZETH" = true ] ; then
  cd /opt/zeth &&  ./net-setup.sh start
fi

echo running as user: $HOST_UID:$HOST_GID
usermod --uid "$HOST_UID" user
groupmod --gid "$HOST_GID" user

sudo chown -R user:user /home/user

# Drop privileges and execute next container command, or 'bash' if not specified.
sudo -u user -H -i --preserve-env=HOST_GID,HOST_UID,SSH_KEYS,GPG_KEYS -- "$@"
