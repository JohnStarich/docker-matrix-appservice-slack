FROM matrixdotorg/matrix-appservice-slack:release-1.8.0-rc1

COPY --from=johnstarich/env2config:v0.1.2 /env2config /
ENV E2C_CONFIGS=config,register

ENV CONFIG_OPTS_FILE=/config/config.yaml
ENV CONFIG_OPTS_FORMAT=yaml
ENV CONFIG_OPTS_TEMPLATE_FILE=/usr/src/app/config/config.sample.yaml
ENV CONFIG_OPTS_IN_db.connectionString=DB_URL
ENV CONFIG_db.engine=postgres
ENV CONFIG_OPTS_IN_homeserver.server_name=MATRIX_HOST
ENV CONFIG_OPTS_IN_homeserver.url=MATRIX_URL

ENV REGISTER_OPTS_FILE=/config/slack-bridge.yaml
ENV REGISTER_OPTS_FORMAT=yaml
ENV REGISTER_sender_localpart=slackbot
ENV REGISTER_OPTS_IN_url=BRIDGE_URL
ENV REGISTER_OPTS_IN_id=BRIDGE_ID
ENV REGISTER_OPTS_IN_hs_token=BRIDGE_HS_TOKEN
ENV REGISTER_OPTS_IN_as_token=BRIDGE_AS_TOKEN

ENTRYPOINT ["/env2config", "node", "lib/app.js", "-c", "/config/config.yaml", "-f", "/config/slack-bridge.yaml"]
