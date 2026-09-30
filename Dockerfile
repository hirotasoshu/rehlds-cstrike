FROM debian:bookworm-slim

ARG rehlds_build=3.15.0.896
ARG metamod_version=1.3.0.149
ARG amxmod_version=1.9.0-git5303
ARG regamedll_version=5.30.0.814
ARG reapi_version=5.29.0.358
ARG reunion_version=0.2.0.25
ARG revoice_version=0.1.0.34
ARG maps_commit=9275947472f28606ac72e92ef35ce31d9bc804e8
ARG steamcmd_url=https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
ARG rehlds_url="https://github.com/dreamstalker/rehlds/releases/download/$rehlds_build/rehlds-bin-$rehlds_build.zip"
ARG metamod_url="https://github.com/theAsmodai/metamod-r/releases/download/$metamod_version/metamod-bin-$metamod_version.zip"
ARG amxmod_url="https://github.com/alliedmodders/amxmodx/releases/download/1.9.0.5303/amxmodx-$amxmod_version-base-linux.tar.gz"
ARG regamedll_url="https://github.com/s1lentq/ReGameDLL_CS/releases/download/$regamedll_version/regamedll-bin-$regamedll_version.zip"
ARG reapi_url="https://github.com/s1lentq/reapi/releases/download/$reapi_version/reapi-bin-$reapi_version.zip"

ENV LANG en_US.utf8
ENV LC_ALL en_US.UTF-8
ENV CPU_MHZ=2300

# Fix warning:
# WARNING: setlocale('en_US.UTF-8') failed, using locale: 'C'.
# International characters may not work.
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
 && rm -rf /var/lib/apt/lists/* \
 && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Fix error:
# Unable to determine CPU Frequency. Try defining CPU_MHZ.
# Exiting on SPEW_ABORT

RUN groupadd -r steam && useradd -r -g steam -m -d /opt/steam steam

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    ca-certificates curl lib32gcc-s1 lib32stdc++6 unzip patch \
 && rm -rf /var/lib/apt/lists/*

USER steam
WORKDIR /opt/steam
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
COPY ./lib/hlds.install /opt/steam

RUN curl -fsSL "$steamcmd_url" | tar xzvf - \
    && ./steamcmd.sh +runscript hlds.install

RUN curl -fsSL "$rehlds_url" -o rehlds.zip \
    && unzip -o -j rehlds.zip "bin/linux32/*" -d "/opt/steam/hlds" \
    && unzip -o -j rehlds.zip "bin/linux32/valve/*" -d "/opt/steam/hlds"

# Fix error that steamclient.so is missing
RUN mkdir -p "$HOME/.steam" \
    && ln -s /opt/steam/linux32 "$HOME/.steam/sdk32"

# Fix warnings:
# couldn't exec listip.cfg
# couldn't exec banned.cfg
RUN touch /opt/steam/hlds/cstrike/listip.cfg
RUN touch /opt/steam/hlds/cstrike/banned.cfg

# Install Metamod-R
RUN mkdir -p /opt/steam/hlds/cstrike/addons/metamod \
    && touch /opt/steam/hlds/cstrike/addons/metamod/plugins.ini
RUN curl -fsSL "$metamod_url" -o tmp.zip
RUN unzip -j tmp.zip "addons/metamod/metamod*" -d /opt/steam/hlds/cstrike/addons/metamod
RUN chmod -R 755 /opt/steam/hlds/cstrike/addons/metamod
RUN sed -i 's/dlls\/cs\.so/addons\/metamod\/metamod_i386.so/g' /opt/steam/hlds/cstrike/liblist.gam

# Install AMX mod X
RUN curl -fsSL "$amxmod_url" | tar -C /opt/steam/hlds/cstrike/ -zxvf - \
    && echo 'linux addons/amxmodx/dlls/amxmodx_mm_i386.so' >> /opt/steam/hlds/cstrike/addons/metamod/plugins.ini
RUN curl -fsSL "https://github.com/alliedmodders/amxmodx/releases/download/1.9.0.5303/amxmodx-$amxmod_version-cstrike-linux.tar.gz" \
    | tar -C /opt/steam/hlds/cstrike/ -zxvf -
RUN cat /opt/steam/hlds/cstrike/mapcycle.txt >> /opt/steam/hlds/cstrike/addons/amxmodx/configs/maps.ini

# Install ReGameDLL_CS
RUN curl -fsSL "$regamedll_url" -o regamedll.zip \
 && unzip -o -j regamedll.zip "bin/linux32/cstrike/*" -d "/opt/steam/hlds/cstrike" \
 && unzip -o -j regamedll.zip "bin/linux32/cstrike/dlls/*" -d "/opt/steam/hlds/cstrike/dlls"

# Install ReAPI
RUN curl -fsSL "$reapi_url" -o reapi.zip \
 && unzip -o reapi.zip -d "/opt/steam/hlds/cstrike"

RUN mkdir -p /opt/steam/hlds/cstrike/addons/reunion /opt/steam/state \
 && curl -fsSL "https://github.com/rehlds/ReUnion/releases/download/$reunion_version/reunion-$reunion_version.zip" -o reunion.zip \
 && unzip -p reunion.zip bin/Linux/reunion_mm_i386.so > /opt/steam/hlds/cstrike/addons/reunion/reunion_mm_i386.so \
 && unzip -p reunion.zip reunion.cfg > /opt/steam/reunion.cfg.default \
 && echo 'linux addons/reunion/reunion_mm_i386.so' >> /opt/steam/hlds/cstrike/addons/metamod/plugins.ini

RUN mkdir -p /opt/steam/hlds/cstrike/addons/revoice \
 && curl -fsSL "https://github.com/rehlds/ReVoice/releases/download/$revoice_version/revoice_$revoice_version.zip" -o revoice.zip \
 && unzip -p revoice.zip bin/linux32/revoice_mm_i386.so > /opt/steam/hlds/cstrike/addons/revoice/revoice_mm_i386.so \
 && unzip -p revoice.zip revoice.cfg > /opt/steam/hlds/cstrike/revoice.cfg \
 && echo 'linux addons/revoice/revoice_mm_i386.so' >> /opt/steam/hlds/cstrike/addons/metamod/plugins.ini

# Map and plugin sources are pinned to the author's repository revision.
RUN mkdir -p /opt/steam/hlds/cstrike/maps \
 && for map in 35hp_2 aim_headshot aim_map awp_india cs_deathmatch-final cs_deathmatch_2005c de_dust2_2x2 fy_pool_day fy_snow; do \
      curl -fsSL "https://raw.githubusercontent.com/ars-anosov/docker-hlds16/$maps_commit/share/docker_images/counter-strike-docker/maps/$map.bsp" \
        -o "/opt/steam/hlds/cstrike/maps/$map.bsp" || exit 1; \
    done
RUN for plugin in Blue_Fade amx_parachute damager map_chooser; do \
      curl -fsSL "https://raw.githubusercontent.com/ars-anosov/docker-hlds16/$maps_commit/cstrike/addons/amxmodx/scripting/$plugin.sma" \
        -o "/opt/steam/hlds/cstrike/addons/amxmodx/scripting/$plugin.sma" || exit 1; \
    done
COPY plugins/map_chooser.patch /opt/steam/map_chooser.patch
COPY --chown=steam:steam plugins/auto_ammo.sma /opt/steam/hlds/cstrike/addons/amxmodx/scripting/auto_ammo.sma
RUN patch -l /opt/steam/hlds/cstrike/addons/amxmodx/scripting/map_chooser.sma < /opt/steam/map_chooser.patch \
 && cd /opt/steam/hlds/cstrike/addons/amxmodx/scripting \
 && for plugin in Blue_Fade amx_parachute damager map_chooser auto_ammo; do \
      ./amxxpc "$plugin.sma" -o"../plugins/$plugin.amxx" || exit 1; \
    done

WORKDIR /opt/steam/hlds

# Copy default config
COPY --chmod=0755 --chown=steam:steam cstrike cstrike
COPY --chown=steam:steam plugins/plugins.ini /opt/steam/hlds/cstrike/addons/amxmodx/configs/plugins.ini
COPY --chmod=0755 --chown=steam:steam start.sh /opt/steam/start.sh

RUN chmod +x hlds_run hlds_linux

RUN echo 10 > steam_appid.txt

EXPOSE 27015
EXPOSE 27015/udp

# Start server
ENTRYPOINT ["/opt/steam/start.sh"]
