FROM matrixdotorg/matrix-appservice-slack:release-1.8.0-rc1

COPY --from=johnstarich/env2config:v0.1.2 /env2config /
ENV E2C_CONFIGS=config,slack

ENV CONFIG_OPTS_FILE=/config/config.yaml
ENV CONFIG_OPTS_FORMAT=yaml
ENV CONFIG_OPTS_TEMPLATE_FILE=/usr/src/app/config/config.sample.yaml
ENV CONFIG_OPTS_IN_db.connectionString=DB_URL
ENV CONFIG_db.engine=postgres
ENV CONFIG_OPTS_IN_homeserver.server_name=MATRIX_HOST
ENV CONFIG_OPTS_IN_homeserver.url=MATRIX_URL

ENV SLACK_OPTS_FILE=/config/slack-registration.yaml
ENV SLACK_OPTS_FORMAT=yaml
ENV SLACK_sender_localpart=slackbot
ENV SLACK_OPTS_IN_url=BIND_URL
ENV SLACK_OPTS_IN_id=REGISTER_ID
ENV SLACK_OPTS_IN_hs_token=REGISTER_HS_TOKEN
ENV SLACK_OPTS_IN_as_token=REGISTER_AS_TOKEN

ENTRYPOINT ["/env2config", "node", "lib/app.js", "-c", "/config/config.yaml", "-f", "/config/slack-registration.yaml"]
