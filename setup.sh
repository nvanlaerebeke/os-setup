#!/bin/bash

BASE_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. lib/functions.sh

bootstrap
createUser
addPubKey
sshdConfig
github
