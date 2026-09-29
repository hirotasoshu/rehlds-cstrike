#!/bin/sh
set -eu

if [ ! -s /opt/steam/state/reunion-salt ]; then
    umask 077
    od -An -N32 -tx1 /dev/urandom | tr -d ' \n' > /opt/steam/state/reunion-salt
fi

salt=$(cat /opt/steam/state/reunion-salt)
sed -e 's/^AuthVersion = .*/AuthVersion = 4/' \
    -e "s/^SteamIdHashSalt =.*/SteamIdHashSalt = $salt/" \
    /opt/steam/reunion.cfg.default > /opt/steam/hlds/cstrike/reunion.cfg

if [ -n "${FASTDL_URL:-}" ]; then
    printf 'sv_downloadurl "%s"\n' "$FASTDL_URL" > /opt/steam/hlds/cstrike/config/fastdl.cfg
else
    : > /opt/steam/hlds/cstrike/config/fastdl.cfg
fi

cd /opt/steam/hlds
exec ./hlds_run -timeout 3 -pingboost 1 -game cstrike -console -port 27015 +map de_dust2 "$@"
