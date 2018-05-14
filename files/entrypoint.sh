#!/usr/bin/env bash

CMD=/sdm.linux

# necessary to suppress stdout during token create
unset SDM_DOCKERIZED

# generate fresh relay token (depends on inheriting SDM_ADMIN_TOKEN)
export SDM_RELAY_TOKEN=`$CMD relay create`

# temporary auth state is created by invoking `relay create` and must
# be cleared out prior to relay startup
rm /root/.sdm/*
unset SDM_ADMIN_TOKEN

# --daemon arg automatically respawns child relay process during
# version upgrades or abnormal termination
export SDM_DOCKERIZED=true # reinstate stdout logging
$CMD relay --daemon
