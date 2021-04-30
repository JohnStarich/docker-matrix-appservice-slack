# docker-matrix-appservice-slack
Wraps matrix-appservice-slack with an [env-based config][e2c].

[e2c]: https://github.com/JohnStarich/env2config

## Quick Start

Use the below Docker stack for environment variables, default volume locations, and ports. Once the `${YOUR_*}` and example.com variables are filled in, deployed, and you've got a [Synapse][] homserver running, then you're all set!

The below stack includes a [pantalaimon][] container to support end-to-end encrypted rooms. It does require 1 login to be made for initial setup, described below.

Once the bridge is up and running, it will generate a registration file and write it to the external `matrix_bridge` volume, which should be mounted to your Matrix homeserver (like this [Synapse][] container) and the file path included in the server's list of bridge files `app_service_config_files`.

[pantalaimon]: https://github.com/JohnStarich/docker-matrix-pantalaimon
[Synapse]: https://github.com/JohnStarich/docker-synapse

```yaml
version: "3.4"

services:
  # NOTE: To set up an E2EE bridge for the first time, you must log in once through pantalaimon.
  #
  # One method is to exec into the pantalaimon container, then install curl and run this with the slackbot user's credentials:
  # curl -XPOST -d '{"type":"m.login.password", "user":"slackbot", "password":"${BOT_PASS}"}' "http://localhost:8008/_matrix/client/r0/login"
  pantalaimon:
    image: johnstarich/matrix-pantalaimon:0.9.2_20210425
    environment:
    - MATRIX_URL=https://example.com
    volumes:
    - pantalaimon:/data

  slack:
    # Assuming we have a proxy set up, these are the host:port proxy settings this uses:
    # - example.com -> synapse homeserver
    # - https://matrix-slack.example.com -> slack:8090
    # - https://matrix-slack-auth.example.com -> slack:9898
    image: johnstarich/matrix-appservice-slack:1.8.0_20210429
    ports:  # Can use Traefik instead of publishing ports, too.
    - "8090:8090"
    - "9898:9898"
    environment:
    # Required:
    - DB_URL=postgresql://${YOUR_DB_USER}:${YOUR_DB_PASS}@slack_db/slack_bridge
    - MATRIX_HOST=example.com
    - MATRIX_URL=http://pantalaimon:8008
    - BRIDGE_URL=https://matrix-slack.example.com/
    - BRIDGE_AS_TOKEN=${YOUR_AS_TOKEN_HERE}
    - BRIDGE_HS_TOKEN=${YOUR_HS_TOKEN_HERE}
    - BRIDGE_ID=${YOUR_BRIDGE_ID_HERE}
    - BRIDGE_USERS_REGEX=@slack_.*:example.com
    # Optional. See the bridge docs for more info: https://github.com/matrix-org/matrix-appservice-slack/blob/1.8.0/config/config.sample.yaml
    - CONFIG_encryption.enabled=true
    - CONFIG_encryption.pantalaimon_url=http://pantalaimon:8008
    #- REGISTER_OPTS_FILE=/register/slack-bridge.yaml
    #- CONFIG_matrix_admin_room=${YOUR_MATRIX_ADMIN_ROOM}
    #- CONFIG_puppeting.enabled=true
    #- CONFIG_oauth2.client_id=${YOUR_SLACK_CLIENT_ID}
    #- CONFIG_oauth2.client_secret=${YOUR_SLACK_CLIENT_SECRET}
    #- CONFIG_oauth2.redirect_prefix=https://matrix-slack-auth.example.com/
    #- CONFIG_inbound_uri_prefix=https://matrix-slack-auth.example.com/
    volumes:
    - matrix_bridge:/register

  slack_db:
    image: postgres:12-alpine
    environment:
    - POSTGRES_USER=${YOUR_DB_USER}
    - POSTGRES_PASSWORD=${YOUR_DB_PASS}
    - POSTGRES_DB=slack_bridge
    volumes:
    - slack_db:/var/lib/postgresql/data

volumes:
  slack_db:
  pantalaimon:
  # This is the volume used by your Matrix server, like Synapse.
  # Load the bridge registration file at $REGISTER_OPTS_FILE. Default is /register/slack-bridge.yaml
  matrix_bridge:  
    external: true
```
