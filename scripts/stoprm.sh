#!/bin/bash
docker stop $1 >/dev/null 2>/dev/null
docker rm $1 >/dev/null 2>/dev/null
