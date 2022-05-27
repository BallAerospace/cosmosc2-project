@echo off
setlocal ENABLEDELAYEDEXPANSION

if "%1" == "" (
  GOTO usage
)
if "%1" == "start" (
  GOTO startup
)
if "%1" == "stop" (
  GOTO stop
)
if "%1" == "cosmos" (
  set params=%*
  call set params=%%params:*%1=%%
  REM Start (and remove when done --rm) the cosmos-base container with the current working directory
  REM mapped as volume (-v) /cosmos/local and container working directory (-w) also set to /cosmos/local.
  REM This allows tools running in the container to have a consistent path to the current working directory.
  REM Run the command "ruby /cosmos/bin/cosmos" with all parameters ignoring the first.
  docker run --rm -v %cd%:/cosmos/local -w /cosmos/local ballaerospace/cosmosc2-base ruby /cosmos/bin/cosmos !params!
  GOTO :EOF
)
if "%1" == "cleanup" (
  GOTO cleanup
)
if "%1" == "util" (
  GOTO util
)

GOTO usage

:startup
  CALL cosmos-control build || exit /b
  docker-compose -f compose.yaml up -d
  @echo off
GOTO :EOF

:stop
  docker-compose -f compose.yaml down
  @echo off
GOTO :EOF

:restart
  docker-compose -f compose.yaml restart
  @echo off
GOTO :EOF

:cleanup
  docker-compose -f compose.yaml down -v
  @echo off
GOTO :EOF

:util
  REM Send the remaining arguments to cosmos_util
  set args=%*
  call set args=%%args:*%1=%%
  CALL scripts\windows\cosmos_util %args% || exit /b
  @echo off
GOTO :EOF

:usage
  @echo Usage: %0 [start, stop, cosmos, cleanup, util] 1>&2
  @echo *  start: run the docker containers for cosmos 1>&2
  @echo *  stop: stop the running docker containers for cosmos 1>&2
  @echo *  cosmos: run a cosmos command ('cosmos help' for more info) 1>&2
  @echo *  cleanup: cleanup network and volumes for cosmos 1>&2
  @echo *  util: various helper commands 1>&2
  @echo *    encode: encode a string to base64 1>&2
  @echo *    hash: hash a string using SHA-256 1>&2
  @echo *    load: load docker images from tar files 1>&2
  @echo *    save: save docker images to tar files 1>&2
  @echo *    zip: create cosmos zipfile 1>&2
  @echo *    clean: remove node_modules, coverage, etc 1>&2
  @echo *    hostsetup: configure host for redis 1>&2
  @echo *    cacert: update cacert.pem file 1>&2

@echo on
