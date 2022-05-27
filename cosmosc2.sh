#!/usr/bin/env sh

set -e

usage() {
  echo "Usage: $1 [start, stop, cosmos, cleanup, util]" >&2
  echo "*  start: start the docker-compose cosmos" >&2
  echo "*  stop: stop the running dockers for cosmos" >&2
  echo "*  cosmos: run a cosmos command ('cosmos help' for more info)" 1>&2
  echo "*  cleanup: cleanup network and volumes for cosmos" >&2
  echo "*  util: various helper commands" >&2
  echo "*    encode: encode a string to base64" >&2
  echo "*    hash: hash a string using SHA-256" >&2
  echo "*    save: save images to tar files" >&2
  echo "*    load: load images to tar files" >&2
  echo "*    clean: remove node_modules, coverage, etc" >&2
  echo "*    hostsetup: configure host for redis" >&2
  echo "*    cacert: update cacert.pem file" >&2
  exit 1
}

if [ "$#" -eq 0 ]; then
  usage $0
fi

case $1 in
  start )
    docker-compose -f compose.yaml up -d
    ;;
  stop )
    docker-compose -f compose.yaml down
    ;;
  cosmos )
    # Start (and remove when done --rm) the cosmos-base container with the current working directory
    # mapped as volume (-v) /cosmos/local and container working directory (-w) also set to /cosmos/local.
    # This allows tools running in the container to have a consistent path to the current working directory.
    # Run the command "ruby /cosmos/bin/cosmos" with all parameters starting at 2 since the first is 'cosmos'
    args=`echo $@ | { read _ args; echo $args; }`
    docker run --rm -v `pwd`:/cosmos/local -w /cosmos/local ballaerospace/cosmosc2-base ruby /cosmos/bin/cosmos $args
    ;;
  cleanup )
    docker-compose -f compose.yaml down -v
    ;;
  util )
    scripts/linux/cosmos_util.sh $2 $3
    ;;
  * )
    usage $0
    ;;
esac
