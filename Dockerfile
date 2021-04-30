FROM matrixdotorg/matrix-appservice-slack:release-1.8.0

COPY --from=johnstarich/env2config:v0.1.5 /env2config /
ENV E2C_CONFIGS=config,register
RUN mkdir -p /config /register

ENV CONFIG_OPTS_FILE=/config/config.yaml
ENV CONFIG_OPTS_FORMAT=yaml
ENV CONFIG_OPTS_TEMPLATE_FILE=/usr/src/app/config/config.sample.yaml
ENV CONFIG_OPTS_IN_db.connectionString=DB_URL
ENV CONFIG_db.engine=postgres
ENV CONFIG_OPTS_IN_homeserver.server_name=MATRIX_HOST
ENV CONFIG_OPTS_IN_homeserver.url=MATRIX_URL
ENV CONFIG_puppeting.onboard_users=true
ENV CONFIG_rtm.enable=true
ENV CONFIG_rtm.log_level=silent
ENV CONFIG_slack_hook_port=9898

ENV REGISTER_OPTS_FILE=/register/slack-bridge.yaml
ENV REGISTER_OPTS_FORMAT=yaml
ENV REGISTER_sender_localpart=slackbot
ENV REGISTER_OPTS_IN_url=BRIDGE_URL
ENV REGISTER_OPTS_IN_id=BRIDGE_ID
ENV REGISTER_OPTS_IN_hs_token=BRIDGE_HS_TOKEN
ENV REGISTER_OPTS_IN_as_token=BRIDGE_AS_TOKEN
ENV REGISTER_namespaces.users.0.exclusive=true
ENV REGISTER_OPTS_IN_namespaces.users.0.regex=BRIDGE_USERS_REGEX
ENV REGISTER_namespaces.aliases.0.exclusive=true
ENV REGISTER_OPTS_IN_namespaces.aliases.0.regex=BRIDGE_USERS_REGEX

ENTRYPOINT ["/env2config", "node", "lib/app.js", "-c", "/config/config.yaml", "-f", "/register/slack-bridge.yaml"]
