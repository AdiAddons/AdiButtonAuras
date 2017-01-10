#!/bin/sh
exec curl -XPOST -sS "https://www.wowace.com/api/projects/$1/package?token=$WOWACE_API_TOKEN" -d '{"ping":1}'
