#!/usr/bin/env bash

CMD=/sdm.linux

CURL_METADATA_TIMEOUT=${CURL_METADATA_TIMEOUT:-30}

# necessary to suppress stdout during token create
unset SDM_DOCKERIZED

# generate fresh relay token (depends on inheriting SDM_ADMIN_TOKEN)
if [[ "${ENABLE_SDM_GATEWAY}" == "false" ]] ; then \
  export SDM_RELAY_TOKEN=`$CMD relay create`
fi

# If we're a gateway, get our public ip and then create a gateway token
if [[ "${ENABLE_SDM_GATEWAY}" == "true" ]] ; then \
  echo "found public host $PUBLIC_HOST"
  CREATE_GATEWAY_TOKEN_COMMAND="$CMD relay create-gateway ${PUBLIC_HOST}:${SDM_GATEWAY_LISTEN_APP_PORT} 0.0.0.0:${SDM_GATEWAY_LISTEN_APP_PORT}"
  echo "running: $CREATE_GATEWAY_TOKEN_COMMAND"
  export SDM_RELAY_TOKEN=$(eval "$CREATE_GATEWAY_TOKEN_COMMAND")
fi

# temporary auth state is created by invoking `relay create` and must
# be cleared out prior to relay startup
unset SDM_ADMIN_TOKEN
rm /root/.sdm/*

# --daemon arg automatically respawns child relay process during
# version upgrades or abnormal termination
export SDM_DOCKERIZED=true # reinstate stdout logging
$CMD relay --daemon
