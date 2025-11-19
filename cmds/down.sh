#! /bin/bash


OPTION=${1:-''}

docker compose -p aggie-experts down $OPTION