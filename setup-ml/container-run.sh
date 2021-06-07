#!/bin/bash

export user_id=$(id -u $USER)
export group_id=$(id -g $USER)
docker-compose -f docker-compose.yml up charlie
