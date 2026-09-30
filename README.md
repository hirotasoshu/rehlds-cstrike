![banner](banner.png)

# ReHLDS Docker

# ReHLDS + ReUnion for CS 1.6

This started out from the docker setup for "Half-Life Dedicated Server as a Docker Image". Now, it serves as a Counter-Strike 1.6 Dedicated Server as a Docker image.
Aside from the difference from the original, this is using an updated version of Debian and changes to some of the modules and plugins.

## Half-Life Dedicated Server as a Docker image

Probably the fastest and easiest way to set up an old-school Counter-Strike 1.6 server.
The image includes ReUnion for mixed Steam/protocol 47/48 clients. Test actual
client compatibility before advertising the server. No game clients are shipped.

## Quick Start

Start a new server by running:

```bash
cp .env.example .env
# Set FASTDL_URL to the externally reachable URL of your nginx server.
docker compose up -d
```

The Compose stack starts the game and nginx on TCP 80 by default. Set
`FASTDL_PORT` in `.env` if TCP 80 is already occupied, and include that port in
`FASTDL_URL`. Forward that TCP port and UDP 27015 if players connect from
outside your LAN (and allow them in the host/provider firewall).
The FastDL URL must end in `/cstrike/`. The first game startup populates a
persistent Docker maps volume; nginx serves only its `/cstrike/maps/` contents.
The ReUnion Steam ID salt is generated on first startup and persisted in a
separate Docker volume. Keep that volume when upgrading the image or player IDs
will change. Do not publish the salt. Restart with `docker compose pull && docker
compose up -d`. When adding new maps to an existing installation, add the BSPs
to the maps volume too: Docker does not recopy updated image files into an
already-populated volume.

## What is included

* [ReHLDS Build](https://github.com/rehlds/ReHLDS) `3.15.0.896`.

  ```
    Protocol version 48
    Exe version 1.1.2.7/Stdio (cstrike)
    Exe build: 07:36:33 Jul 12 2023 (3378)

  ```

* [Metamod-r](https://github.com/rehlds/Metamod-R) version `1.3.0.149`

* [AMX Mod X](https://github.com/alliedmodders/amxmodx) version `1.9.0.5303`

* [ReAPI](https://github.com/rehlds/ReAPI) version `5.29.0.358`
* [ReGameDLL_CS](https://github.com/rehlds/ReGameDLL_CS) version `5.30.0.814`
* [ReUnion](https://github.com/rehlds/ReUnion) version `0.2.0.25`
* [ReVoice](https://github.com/rehlds/ReVoice) version `0.1.0.34` for voice chat between Steam and non-Steam clients.
* The nine custom maps and four plugins from
  [ars-anosov/docker-hlds16](https://github.com/ars-anosov/docker-hlds16),
  plus a small full-reserve-ammo plugin. No web stats or anti-double-duck.

* Patched list of master servers (official and unofficial master servers
  included), so your game server appear in game server browser of all the clients

* Minimal config present, such as `mp_timelimit` and mapcycle

## Default mapcycle

* de_dust2
* de_inferno
* de_dust2_2x2, awp_india, 35hp_2, aim_map, aim_headshot
* fy_snow, fy_pool_day, cs_deathmatch-final, cs_deathmatch_2005c

## Advanced

Check out the example under server-example. It allows adding maps and configurations by appending (and overwriting) the original cstrike folder.
The example contains an override for the mapcycle file.


The image is published by `.github/workflows/image.yml` to
`ghcr.io/hirotasoshu/rehlds-cstrike:latest` on pushes to `master`.
